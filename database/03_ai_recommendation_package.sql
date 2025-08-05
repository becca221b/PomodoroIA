-- AI Recommendation Engine Package
CREATE OR REPLACE PACKAGE ai_recommendations_pkg AS
    -- Generate recommendations based on patient's current emotion and performance
    PROCEDURE generate_emotion_based_recommendations(
        p_patient_id IN NUMBER,
        p_current_emotion_id IN NUMBER DEFAULT NULL,
        p_limit IN NUMBER DEFAULT 3
    );
    
    -- Generate recommendations based on performance patterns
    PROCEDURE generate_performance_based_recommendations(
        p_patient_id IN NUMBER,
        p_limit IN NUMBER DEFAULT 3
    );
    
    -- Generate routine-based recommendations
    PROCEDURE generate_routine_recommendations(
        p_patient_id IN NUMBER,
        p_limit IN NUMBER DEFAULT 3
    );
    
    -- Calculate cognitive score based on recent performance
    FUNCTION calculate_cognitive_score(
        p_patient_id IN NUMBER,
        p_days_back IN NUMBER DEFAULT 7
    ) RETURN NUMBER;
    
    -- Get personalized difficulty level
    FUNCTION get_recommended_difficulty(
        p_patient_id IN NUMBER,
        p_category_id IN NUMBER
    ) RETURN NUMBER;
    
    -- Update patient statistics
    PROCEDURE update_daily_stats(
        p_patient_id IN NUMBER,
        p_stat_date IN DATE DEFAULT TRUNC(SYSDATE)
    );
END ai_recommendations_pkg;
/

CREATE OR REPLACE PACKAGE BODY ai_recommendations_pkg AS

    PROCEDURE generate_emotion_based_recommendations(
        p_patient_id IN NUMBER,
        p_current_emotion_id IN NUMBER DEFAULT NULL,
        p_limit IN NUMBER DEFAULT 3
    ) IS
        v_emotion_id NUMBER;
        v_is_positive VARCHAR2(1);
        v_confidence NUMBER;
        v_reasoning CLOB;
    BEGIN
        -- Get current emotion or latest logged emotion
        IF p_current_emotion_id IS NULL THEN
            SELECT emotion_id INTO v_emotion_id
            FROM (
                SELECT pe.emotion_id
                FROM patient_emotions pe
                WHERE pe.patient_id = p_patient_id
                ORDER BY pe.logged_date DESC
            ) WHERE ROWNUM = 1;
        ELSE
            v_emotion_id := p_current_emotion_id;
        END IF;
        
        -- Get emotion characteristics
        SELECT is_positive INTO v_is_positive
        FROM emotions
        WHERE emotion_id = v_emotion_id;
        
        -- Clear old recommendations for this patient
        DELETE FROM ai_recommendations 
        WHERE patient_id = p_patient_id 
        AND recommendation_type = 'EMOTION_BASED'
        AND recommended_date < SYSDATE - 1;
        
        -- Generate recommendations based on emotion
        FOR game_rec IN (
            SELECT g.game_id, g.game_name, g.category_id, gc.category_name,
                   CASE 
                       WHEN v_is_positive = 'Y' THEN 0.8 + (DBMS_RANDOM.VALUE * 0.2)
                       ELSE 0.6 + (DBMS_RANDOM.VALUE * 0.3)
                   END as confidence_score
            FROM games g
            JOIN game_categories gc ON g.category_id = gc.category_id
            WHERE g.is_active = 'Y'
            AND (
                -- If positive emotion, recommend engaging games
                (v_is_positive = 'Y' AND g.category_id IN (1, 2, 4)) OR
                -- If negative emotion, recommend calming activities
                (v_is_positive = 'N' AND g.category_id IN (8, 5, 6)) OR
                -- Always include games that match emotional recommendations
                (',' || g.recommended_emotions || ',' LIKE '%,' || v_emotion_id || ',%')
            )
            AND g.game_id NOT IN (
                -- Exclude recently played games
                SELECT gs.game_id
                FROM game_sessions gs
                WHERE gs.patient_id = p_patient_id
                AND gs.start_time > SYSDATE - 1
            )
            ORDER BY confidence_score DESC
        ) LOOP
            EXIT WHEN SQL%ROWCOUNT >= p_limit;
            
            -- Create reasoning text
            v_reasoning := 'Recomendado basado en tu estado emocional actual. ';
            IF v_is_positive = 'Y' THEN
                v_reasoning := v_reasoning || 'Te sientes bien, ¡es un gran momento para desafiarte con actividades estimulantes!';
            ELSE
                v_reasoning := v_reasoning || 'Actividad relajante recomendada para ayudarte a sentirte mejor.';
            END IF;
            
            INSERT INTO ai_recommendations (
                patient_id, recommended_game_id, recommendation_type,
                confidence_score, reasoning
            ) VALUES (
                p_patient_id, game_rec.game_id, 'EMOTION_BASED',
                game_rec.confidence_score, v_reasoning
            );
        END LOOP;
        
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- No emotion data found, generate general recommendations
            NULL;
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END generate_emotion_based_recommendations;

    PROCEDURE generate_performance_based_recommendations(
        p_patient_id IN NUMBER,
        p_limit IN NUMBER DEFAULT 3
    ) IS
        v_avg_score NUMBER;
        v_preferred_category NUMBER;
        v_confidence NUMBER;
    BEGIN
        -- Find patient's strongest category
        SELECT category_id, avg_score INTO v_preferred_category, v_avg_score
        FROM (
            SELECT g.category_id, AVG(gs.score / gs.max_possible_score) as avg_score
            FROM game_sessions gs
            JOIN games g ON gs.game_id = g.game_id
            WHERE gs.patient_id = p_patient_id
            AND gs.completion_status = 'COMPLETED'
            AND gs.start_time > SYSDATE - 30
            GROUP BY g.category_id
            ORDER BY avg_score DESC
        ) WHERE ROWNUM = 1;
        
        -- Clear old performance-based recommendations
        DELETE FROM ai_recommendations 
        WHERE patient_id = p_patient_id 
        AND recommendation_type = 'PERFORMANCE_BASED'
        AND recommended_date < SYSDATE - 1;
        
        -- Recommend games from preferred category with progressive difficulty
        FOR game_rec IN (
            SELECT g.game_id, g.game_name, g.difficulty_level,
                   0.7 + (v_avg_score * 0.3) as confidence_score
            FROM games g
            WHERE g.category_id = v_preferred_category
            AND g.is_active = 'Y'
            AND g.difficulty_level <= LEAST(5, FLOOR(v_avg_score * 5) + 1)
            AND g.game_id NOT IN (
                SELECT gs.game_id
                FROM game_sessions gs
                WHERE gs.patient_id = p_patient_id
                AND gs.start_time > SYSDATE - 3
            )
            ORDER BY g.difficulty_level
        ) LOOP
            EXIT WHEN SQL%ROWCOUNT >= p_limit;
            
            INSERT INTO ai_recommendations (
                patient_id, recommended_game_id, recommendation_type,
                confidence_score, reasoning
            ) VALUES (
                p_patient_id, game_rec.game_id, 'PERFORMANCE_BASED',
                game_rec.confidence_score,
                'Recomendado basado en tu excelente rendimiento en esta categoría. ¡Sigue desafiándote!'
            );
        END LOOP;
        
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END generate_performance_based_recommendations;

    PROCEDURE generate_routine_recommendations(
        p_patient_id IN NUMBER,
        p_limit IN NUMBER DEFAULT 3
    ) IS
        v_last_play_time TIMESTAMP;
        v_routine_hour NUMBER;
    BEGIN
        -- Find patient's preferred playing time
        SELECT EXTRACT(HOUR FROM start_time) INTO v_routine_hour
        FROM (
            SELECT start_time, COUNT(*) as frequency
            FROM game_sessions
            WHERE patient_id = p_patient_id
            AND start_time > SYSDATE - 30
            GROUP BY EXTRACT(HOUR FROM start_time)
            ORDER BY frequency DESC
        ) WHERE ROWNUM = 1;
        
        -- Clear old routine recommendations
        DELETE FROM ai_recommendations 
        WHERE patient_id = p_patient_id 
        AND recommendation_type = 'ROUTINE_BASED'
        AND recommended_date < SYSDATE - 1;
        
        -- Recommend games for routine maintenance
        FOR game_rec IN (
            SELECT g.game_id, g.game_name,
                   CASE 
                       WHEN EXTRACT(HOUR FROM SYSDATE) = v_routine_hour THEN 0.9
                       ELSE 0.6
                   END as confidence_score
            FROM games g
            WHERE g.is_active = 'Y'
            AND g.estimated_duration <= 15 -- Short games for routine
            AND g.game_id NOT IN (
                SELECT gs.game_id
                FROM game_sessions gs
                WHERE gs.patient_id = p_patient_id
                AND gs.start_time > SYSDATE - 1
            )
            ORDER BY DBMS_RANDOM.VALUE
        ) LOOP
            EXIT WHEN SQL%ROWCOUNT >= p_limit;
            
            INSERT INTO ai_recommendations (
                patient_id, recommended_game_id, recommendation_type,
                confidence_score, reasoning
            ) VALUES (
                p_patient_id, game_rec.game_id, 'ROUTINE_BASED',
                game_rec.confidence_score,
                'Actividad recomendada para mantener tu rutina diaria de ejercicios cognitivos.'
            );
        END LOOP;
        
        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            NULL;
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END generate_routine_recommendations;

    FUNCTION calculate_cognitive_score(
        p_patient_id IN NUMBER,
        p_days_back IN NUMBER DEFAULT 7
    ) RETURN NUMBER IS
        v_score NUMBER := 0;
        v_completion_rate NUMBER;
        v_avg_performance NUMBER;
        v_consistency NUMBER;
    BEGIN
        -- Calculate completion rate
        SELECT 
            NVL(SUM(CASE WHEN completion_status = 'COMPLETED' THEN 1 ELSE 0 END) / 
                NULLIF(COUNT(*), 0), 0)
        INTO v_completion_rate
        FROM game_sessions
        WHERE patient_id = p_patient_id
        AND start_time > SYSDATE - p_days_back;
        
        -- Calculate average performance
        SELECT NVL(AVG(score / NULLIF(max_possible_score, 0)), 0)
        INTO v_avg_performance
        FROM game_sessions
        WHERE patient_id = p_patient_id
        AND completion_status = 'COMPLETED'
        AND start_time > SYSDATE - p_days_back;
        
        -- Calculate consistency (days played out of total days)
        SELECT COUNT(DISTINCT TRUNC(start_time)) / p_days_back
        INTO v_consistency
        FROM game_sessions
        WHERE patient_id = p_patient_id
        AND start_time > SYSDATE - p_days_back;
        
        -- Weighted cognitive score
        v_score := (v_completion_rate * 0.3) + (v_avg_performance * 0.5) + (v_consistency * 0.2);
        
        RETURN ROUND(v_score * 100, 2);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END calculate_cognitive_score;

    FUNCTION get_recommended_difficulty(
        p_patient_id IN NUMBER,
        p_category_id IN NUMBER
    ) RETURN NUMBER IS
        v_avg_score NUMBER;
        v_recommended_difficulty NUMBER := 2; -- Default medium difficulty
    BEGIN
        -- Get average score in this category
        SELECT NVL(AVG(gs.score / NULLIF(gs.max_possible_score, 0)), 0.5)
        INTO v_avg_score
        FROM game_sessions gs
        JOIN games g ON gs.game_id = g.game_id
        WHERE gs.patient_id = p_patient_id
        AND g.category_id = p_category_id
        AND gs.completion_status = 'COMPLETED'
        AND gs.start_time > SYSDATE - 14; -- Last 2 weeks
        
        -- Adjust difficulty based on performance
        IF v_avg_score >= 0.8 THEN
            v_recommended_difficulty := LEAST(5, v_recommended_difficulty + 1);
        ELSIF v_avg_score <= 0.4 THEN
            v_recommended_difficulty := GREATEST(1, v_recommended_difficulty - 1);
        END IF;
        
        RETURN v_recommended_difficulty;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 2;
    END get_recommended_difficulty;

    PROCEDURE update_daily_stats(
        p_patient_id IN NUMBER,
        p_stat_date IN DATE DEFAULT TRUNC(SYSDATE)
    ) IS
        v_stats_record patient_stats%ROWTYPE;
    BEGIN
        -- Calculate daily statistics
        SELECT 
            p_patient_id,
            p_stat_date,
            NVL(SUM(g.points_base), 0),
            COUNT(*),
            NVL(SUM(gs.time_spent_seconds), 0) / 60,
            NVL(AVG(gs.score / NULLIF(gs.max_possible_score, 0)) * 100, 0),
            0, -- streak_days calculated separately
            CASE 
                WHEN NVL(SUM(g.points_base), 0) < 50 THEN 1
                WHEN NVL(SUM(g.points_base), 0) < 150 THEN 2
                WHEN NVL(SUM(g.points_base), 0) < 300 THEN 3
                WHEN NVL(SUM(g.points_base), 0) < 500 THEN 4
                ELSE 5
            END,
            (SELECT COUNT(*) FROM patient_achievements WHERE patient_id = p_patient_id),
            NVL(AVG(pe.intensity_level), 3),
            ai_recommendations_pkg.calculate_cognitive_score(p_patient_id, 1)
        INTO 
            v_stats_record.patient_id,
            v_stats_record.stat_date,
            v_stats_record.total_points,
            v_stats_record.games_played,
            v_stats_record.total_time_minutes,
            v_stats_record.average_score,
            v_stats_record.streak_days,
            v_stats_record.current_level,
            v_stats_record.achievements_count,
            v_stats_record.mood_average,
            v_stats_record.cognitive_score
        FROM game_sessions gs
        JOIN games g ON gs.game_id = g.game_id
        LEFT JOIN patient_emotions pe ON pe.patient_id = gs.patient_id 
            AND TRUNC(pe.logged_date) = p_stat_date
        WHERE gs.patient_id = p_patient_id
        AND TRUNC(gs.start_time) = p_stat_date
        AND gs.completion_status = 'COMPLETED';
        
        -- Update or insert daily stats
        MERGE INTO patient_stats ps
        USING (SELECT 
                v_stats_record.patient_id as patient_id,
                v_stats_record.stat_date as stat_date,
                v_stats_record.total_points as total_points,
                v_stats_record.games_played as games_played,
                v_stats_record.total_time_minutes as total_time_minutes,
                v_stats_record.average_score as average_score,
                v_stats_record.current_level as current_level,
                v_stats_record.achievements_count as achievements_count,
                v_stats_record.mood_average as mood_average,
                v_stats_record.cognitive_score as cognitive_score
               FROM dual) src
        ON (ps.patient_id = src.patient_id AND ps.stat_date = src.stat_date)
        WHEN MATCHED THEN
            UPDATE SET
                total_points = src.total_points,
                games_played = src.games_played,
                total_time_minutes = src.total_time_minutes,
                average_score = src.average_score,
                current_level = src.current_level,
                achievements_count = src.achievements_count,
                mood_average = src.mood_average,
                cognitive_score = src.cognitive_score
        WHEN NOT MATCHED THEN
            INSERT (patient_id, stat_date, total_points, games_played, 
                   total_time_minutes, average_score, current_level,
                   achievements_count, mood_average, cognitive_score)
            VALUES (src.patient_id, src.stat_date, src.total_points, 
                   src.games_played, src.total_time_minutes, src.average_score,
                   src.current_level, src.achievements_count, src.mood_average,
                   src.cognitive_score);
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_daily_stats;

END ai_recommendations_pkg;
/