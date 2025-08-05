-- Page 11: Progress Statistics Dashboard
-- Comprehensive analytics and progress tracking

PROMPT Creating Statistics Dashboard Page (Page 11)...

-- Page Regions
begin
    -- Header Region
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(1),
        p_plug_name => 'Statistics Header',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 10,
        p_plug_source => q'[
<div class="stats-header" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 25px; border-radius: 15px; margin-bottom: 25px;">
    <div class="row align-items-center">
        <div class="col-md-8">
            <h2 style="margin: 0 0 10px 0; font-weight: 300;">
                <i class="fa fa-chart-line"></i> Tu Progreso Cognitivo
            </h2>
            <p style="margin: 0; opacity: 0.9;">Análisis detallado de tu rendimiento y evolución</p>
        </div>
        <div class="col-md-4 text-right">
            <div class="cognitive-score-badge" style="background: rgba(255,255,255,0.2); padding: 15px; border-radius: 10px; display: inline-block;">
                <div style="font-size: 2rem; font-weight: bold; margin-bottom: 5px;">
                    <span id="current-cognitive-score">--</span>
                </div>
                <small style="opacity: 0.8;">Puntuación Cognitiva</small>
            </div>
        </div>
    </div>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
    
    -- Key Metrics Cards
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(2),
        p_plug_name => 'Key Metrics',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 20,
        p_plug_source => q'[
SELECT 
    '<div class="col-md-3 mb-4">
        <div class="metric-card" style="background: white; border-radius: 15px; padding: 25px; text-align: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1); border-left: 4px solid ' || color || ';">
            <div class="metric-icon" style="width: 60px; height: 60px; background: ' || color || '; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 15px;">
                <i class="' || icon || '" style="font-size: 1.8rem; color: white;"></i>
            </div>
            <h3 style="margin: 0 0 10px 0; color: #333; font-weight: 600;">' || value || '</h3>
            <p style="margin: 0 0 5px 0; color: #666; font-size: 0.9rem;">' || label || '</p>
            <small style="color: ' || trend_color || '; font-weight: 500;">
                <i class="fa fa-' || trend_icon || '"></i> ' || trend_text || '
            </small>
        </div>
    </div>' as metric_html
FROM (
    -- Total Games Played
    SELECT 
        'fa-gamepad' as icon,
        '#4CAF50' as color,
        TO_CHAR(NVL(SUM(games_played), 0)) as value,
        'Juegos Completados' as label,
        CASE 
            WHEN LAG(SUM(games_played), 7) OVER (ORDER BY MAX(stat_date)) < SUM(games_played) THEN '#4CAF50'
            ELSE '#666'
        END as trend_color,
        CASE 
            WHEN LAG(SUM(games_played), 7) OVER (ORDER BY MAX(stat_date)) < SUM(games_played) THEN 'arrow-up'
            ELSE 'minus'
        END as trend_icon,
        CASE 
            WHEN LAG(SUM(games_played), 7) OVER (ORDER BY MAX(stat_date)) < SUM(games_played) THEN '+' || TO_CHAR(SUM(games_played) - LAG(SUM(games_played), 7) OVER (ORDER BY MAX(stat_date))) || ' esta semana'
            ELSE 'Sin cambios'
        END as trend_text,
        1 as sort_order
    FROM patient_stats 
    WHERE patient_id = :G_PATIENT_ID
    AND stat_date >= SYSDATE - 30
    
    UNION ALL
    
    -- Total Points
    SELECT 
        'fa-trophy' as icon,
        '#FFD700' as color,
        TO_CHAR(NVL(MAX(total_points), 0)) as value,
        'Puntos Totales' as label,
        '#4CAF50' as trend_color,
        'arrow-up' as trend_icon,
        'Nivel ' || NVL(MAX(current_level), 1) as trend_text,
        2 as sort_order
    FROM patient_stats 
    WHERE patient_id = :G_PATIENT_ID
    AND stat_date = TRUNC(SYSDATE)
    
    UNION ALL
    
    -- Current Streak
    SELECT 
        'fa-fire' as icon,
        '#FF5722' as color,
        TO_CHAR(NVL(MAX(streak_days), 0)) as value,
        'Días Consecutivos' as label,
        CASE WHEN MAX(streak_days) > 0 THEN '#4CAF50' ELSE '#666' END as trend_color,
        CASE WHEN MAX(streak_days) > 0 THEN 'fire' ELSE 'minus' END as trend_icon,
        CASE WHEN MAX(streak_days) > 0 THEN '¡Sigue así!' ELSE 'Comienza hoy' END as trend_text,
        3 as sort_order
    FROM patient_stats 
    WHERE patient_id = :G_PATIENT_ID
    AND stat_date = TRUNC(SYSDATE)
    
    UNION ALL
    
    -- Average Score
    SELECT 
        'fa-percentage' as icon,
        '#2196F3' as color,
        TO_CHAR(NVL(ROUND(AVG(average_score), 1), 0)) || '%' as value,
        'Puntuación Promedio' as label,
        CASE 
            WHEN AVG(average_score) >= 80 THEN '#4CAF50'
            WHEN AVG(average_score) >= 60 THEN '#FF9800'
            ELSE '#F44336'
        END as trend_color,
        CASE 
            WHEN AVG(average_score) >= 80 THEN 'star'
            WHEN AVG(average_score) >= 60 THEN 'thumbs-up'
            ELSE 'arrow-up'
        END as trend_icon,
        CASE 
            WHEN AVG(average_score) >= 80 THEN 'Excelente'
            WHEN AVG(average_score) >= 60 THEN 'Bien'
            ELSE 'Mejorando'
        END as trend_text,
        4 as sort_order
    FROM patient_stats 
    WHERE patient_id = :G_PATIENT_ID
    AND stat_date >= SYSDATE - 7
) ORDER BY sort_order]',
        p_plug_source_type => 'NATIVE_SQL_REPORT'
    );
    
    -- Cognitive Score Trend Chart
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(3),
        p_plug_name => 'Cognitive Score Trend',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 30,
        p_plug_source => q'[
<div class="card" style="border: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); border-radius: 15px; margin-bottom: 25px;">
    <div class="card-header" style="background: linear-gradient(45deg, #2196F3, #21CBF3); color: white; border-radius: 15px 15px 0 0;">
        <h5 style="margin: 0;"><i class="fa fa-line-chart"></i> Evolución de tu Puntuación Cognitiva</h5>
    </div>
    <div class="card-body">
        <canvas id="cognitiveScoreChart" style="max-height: 300px;"></canvas>
    </div>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
    
    -- Category Performance Radar Chart
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(4),
        p_plug_name => 'Category Performance',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 40,
        p_plug_source => q'[
<div class="row">
    <div class="col-md-6">
        <div class="card" style="border: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); border-radius: 15px; margin-bottom: 25px;">
            <div class="card-header" style="background: linear-gradient(45deg, #4CAF50, #45A049); color: white; border-radius: 15px 15px 0 0;">
                <h5 style="margin: 0;"><i class="fa fa-radar-chart"></i> Rendimiento por Categoría</h5>
            </div>
            <div class="card-body">
                <canvas id="categoryRadarChart" style="max-height: 300px;"></canvas>
            </div>
        </div>
    </div>
    <div class="col-md-6">
        <div class="card" style="border: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); border-radius: 15px; margin-bottom: 25px;">
            <div class="card-header" style="background: linear-gradient(45deg, #FF6B6B, #FF8E8E); color: white; border-radius: 15px 15px 0 0;">
                <h5 style="margin: 0;"><i class="fa fa-heart"></i> Estado Emocional</h5>
            </div>
            <div class="card-body">
                <canvas id="emotionChart" style="max-height: 300px;"></canvas>
            </div>
        </div>
    </div>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
    
    -- Weekly Activity Heatmap
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(5),
        p_plug_name => 'Weekly Activity',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 50,
        p_plug_source => q'[
<div class="card" style="border: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); border-radius: 15px; margin-bottom: 25px;">
    <div class="card-header" style="background: linear-gradient(45deg, #9C27B0, #BA68C8); color: white; border-radius: 15px 15px 0 0;">
        <h5 style="margin: 0;"><i class="fa fa-calendar"></i> Actividad de las Últimas 4 Semanas</h5>
    </div>
    <div class="card-body">
        <div id="activityHeatmap" style="overflow-x: auto;">
            <!-- Heatmap will be generated by JavaScript -->
        </div>
    </div>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
    
    -- Detailed Statistics Table
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(6),
        p_plug_name => 'Detailed Statistics',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 60,
        p_plug_source => q'[
SELECT 
    TO_CHAR(ps.stat_date, 'DD/MM/YYYY') as "Fecha",
    ps.games_played as "Juegos",
    ps.total_points as "Puntos",
    ROUND(ps.average_score, 1) || '%' as "Puntuación Media",
    ROUND(ps.total_time_minutes, 0) || ' min' as "Tiempo Total",
    ps.current_level as "Nivel",
    ROUND(ps.cognitive_score, 1) as "Puntuación Cognitiva",
    CASE 
        WHEN ps.mood_average >= 4 THEN '<span style="color: #4CAF50;"><i class="fa fa-smile"></i> Muy Bien</span>'
        WHEN ps.mood_average >= 3 THEN '<span style="color: #FF9800;"><i class="fa fa-meh"></i> Bien</span>'
        ELSE '<span style="color: #F44336;"><i class="fa fa-frown"></i> Regular</span>'
    END as "Estado de Ánimo"
FROM patient_stats ps
WHERE ps.patient_id = :G_PATIENT_ID
AND ps.stat_date >= SYSDATE - 30
ORDER BY ps.stat_date DESC]',
        p_plug_source_type => 'NATIVE_SQL_REPORT',
        p_plug_query_options => 'DERIVED_REPORT_COLUMNS'
    );
end;
/

-- JavaScript for Charts
begin
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(7),
        p_plug_name => 'Charts JavaScript',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 1,
        p_plug_source => q'[
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
// Chart.js configuration
Chart.defaults.font.family = "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif";
Chart.defaults.color = '#666';

// Initialize charts when page loads
$(document).ready(function() {
    initializeCognitiveScoreChart();
    initializeCategoryRadarChart();
    initializeEmotionChart();
    initializeActivityHeatmap();
    updateCurrentCognitiveScore();
});

function initializeCognitiveScoreChart() {
    const ctx = document.getElementById('cognitiveScoreChart').getContext('2d');
    
    // Get data from server
    apex.server.process('GET_COGNITIVE_TREND', {}, {
        success: function(data) {
            new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.labels,
                    datasets: [{
                        label: 'Puntuación Cognitiva',
                        data: data.values,
                        borderColor: '#2196F3',
                        backgroundColor: 'rgba(33, 150, 243, 0.1)',
                        borderWidth: 3,
                        fill: true,
                        tension: 0.4,
                        pointBackgroundColor: '#2196F3',
                        pointBorderColor: '#ffffff',
                        pointBorderWidth: 2,
                        pointRadius: 6
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            max: 100,
                            grid: {
                                color: 'rgba(0,0,0,0.1)'
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });
        }
    });
}

function initializeCategoryRadarChart() {
    const ctx = document.getElementById('categoryRadarChart').getContext('2d');
    
    apex.server.process('GET_CATEGORY_PERFORMANCE', {}, {
        success: function(data) {
            new Chart(ctx, {
                type: 'radar',
                data: {
                    labels: data.categories,
                    datasets: [{
                        label: 'Rendimiento',
                        data: data.scores,
                        backgroundColor: 'rgba(76, 175, 80, 0.2)',
                        borderColor: '#4CAF50',
                        borderWidth: 2,
                        pointBackgroundColor: '#4CAF50',
                        pointBorderColor: '#ffffff',
                        pointBorderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        r: {
                            beginAtZero: true,
                            max: 100,
                            grid: {
                                color: 'rgba(0,0,0,0.1)'
                            },
                            pointLabels: {
                                font: {
                                    size: 12
                                }
                            }
                        }
                    }
                }
            });
        }
    });
}

function initializeEmotionChart() {
    const ctx = document.getElementById('emotionChart').getContext('2d');
    
    apex.server.process('GET_EMOTION_DISTRIBUTION', {}, {
        success: function(data) {
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: data.emotions,
                    datasets: [{
                        data: data.counts,
                        backgroundColor: data.colors,
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: {
                                padding: 20,
                                usePointStyle: true
                            }
                        }
                    }
                }
            });
        }
    });
}

function initializeActivityHeatmap() {
    apex.server.process('GET_ACTIVITY_HEATMAP', {}, {
        success: function(data) {
            let heatmapHTML = '<div class="heatmap-container" style="display: flex; flex-direction: column; gap: 5px;">';
            
            const days = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
            
            // Add day labels
            heatmapHTML += '<div style="display: flex; gap: 3px; margin-left: 30px;">';
            for (let i = 0; i < 7; i++) {
                heatmapHTML += '<div style="width: 15px; text-align: center; font-size: 10px; color: #666;">' + days[i] + '</div>';
            }
            heatmapHTML += '</div>';
            
            // Add weeks
            data.weeks.forEach(function(week, weekIndex) {
                heatmapHTML += '<div style="display: flex; align-items: center; gap: 3px;">';
                heatmapHTML += '<div style="width: 25px; font-size: 10px; color: #666;">S' + (weekIndex + 1) + '</div>';
                
                week.forEach(function(day) {
                    const intensity = Math.min(day.games_played / 5, 1); // Normalize to 0-1
                    const opacity = 0.1 + (intensity * 0.9);
                    const color = day.games_played > 0 ? '#4CAF50' : '#e0e0e0';
                    
                    heatmapHTML += '<div style="width: 15px; height: 15px; background-color: ' + color + '; opacity: ' + opacity + '; border-radius: 2px; cursor: pointer;" title="' + day.date + ': ' + day.games_played + ' juegos"></div>';
                });
                
                heatmapHTML += '</div>';
            });
            
            heatmapHTML += '</div>';
            
            $('#activityHeatmap').html(heatmapHTML);
        }
    });
}

function updateCurrentCognitiveScore() {
    apex.server.process('GET_CURRENT_COGNITIVE_SCORE', {}, {
        success: function(data) {
            $('#current-cognitive-score').text(data.score || '--');
        }
    });
}
</script>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
end;
/

-- Server-side processes for chart data
begin
    -- Cognitive Score Trend Data
    wwv_flow_api.create_page_process(
        p_id => wwv_flow_api.id(1),
        p_process_sequence => 10,
        p_process_point => 'ON_DEMAND',
        p_process_type => 'NATIVE_PLSQL',
        p_process_name => 'GET_COGNITIVE_TREND',
        p_process_sql_clob => q'[
declare
    l_labels apex_json.t_values;
    l_values apex_json.t_values;
begin
    for rec in (
        select to_char(stat_date, 'DD/MM') as label,
               nvl(cognitive_score, 0) as score
        from patient_stats
        where patient_id = :G_PATIENT_ID
        and stat_date >= sysdate - 14
        order by stat_date
    ) loop
        apex_json.push(l_labels, rec.label);
        apex_json.push(l_values, rec.score);
    end loop;
    
    apex_json.open_object;
    apex_json.write('labels', l_labels);
    apex_json.write('values', l_values);
    apex_json.close_object;
end;]'
    );
    
    -- Category Performance Data
    wwv_flow_api.create_page_process(
        p_id => wwv_flow_api.id(2),
        p_process_sequence => 20,
        p_process_point => 'ON_DEMAND',
        p_process_type => 'NATIVE_PLSQL',
        p_process_name => 'GET_CATEGORY_PERFORMANCE',
        p_process_sql_clob => q'[
declare
    l_categories apex_json.t_values;
    l_scores apex_json.t_values;
begin
    for rec in (
        select gc.category_name,
               nvl(avg(gs.score / nullif(gs.max_possible_score, 0)) * 100, 0) as avg_score
        from game_categories gc
        left join games g on gc.category_id = g.category_id
        left join game_sessions gs on g.game_id = gs.game_id 
                                   and gs.patient_id = :G_PATIENT_ID
                                   and gs.completion_status = 'COMPLETED'
                                   and gs.start_time >= sysdate - 30
        group by gc.category_id, gc.category_name
        order by gc.category_id
    ) loop
        apex_json.push(l_categories, rec.category_name);
        apex_json.push(l_scores, round(rec.avg_score, 1));
    end loop;
    
    apex_json.open_object;
    apex_json.write('categories', l_categories);
    apex_json.write('scores', l_scores);
    apex_json.close_object;
end;]'
    );
    
    -- Emotion Distribution Data
    wwv_flow_api.create_page_process(
        p_id => wwv_flow_api.id(3),
        p_process_sequence => 30,
        p_process_point => 'ON_DEMAND',
        p_process_type => 'NATIVE_PLSQL',
        p_process_name => 'GET_EMOTION_DISTRIBUTION',
        p_process_sql_clob => q'[
declare
    l_emotions apex_json.t_values;
    l_counts apex_json.t_values;
    l_colors apex_json.t_values;
begin
    for rec in (
        select e.emotion_name,
               count(*) as emotion_count,
               e.emotion_color
        from patient_emotions pe
        join emotions e on pe.emotion_id = e.emotion_id
        where pe.patient_id = :G_PATIENT_ID
        and pe.logged_date >= sysdate - 14
        group by e.emotion_id, e.emotion_name, e.emotion_color
        order by count(*) desc
    ) loop
        apex_json.push(l_emotions, rec.emotion_name);
        apex_json.push(l_counts, rec.emotion_count);
        apex_json.push(l_colors, rec.emotion_color);
    end loop;
    
    apex_json.open_object;
    apex_json.write('emotions', l_emotions);
    apex_json.write('counts', l_counts);
    apex_json.write('colors', l_colors);
    apex_json.close_object;
end;]'
    );
    
    -- Activity Heatmap Data
    wwv_flow_api.create_page_process(
        p_id => wwv_flow_api.id(4),
        p_process_sequence => 40,
        p_process_point => 'ON_DEMAND',
        p_process_type => 'NATIVE_PLSQL',
        p_process_name => 'GET_ACTIVITY_HEATMAP',
        p_process_sql_clob => q'[
declare
    l_weeks apex_json.t_values;
begin
    apex_json.open_object;
    apex_json.open_array('weeks');
    
    for week_num in 1..4 loop
        apex_json.open_array;
        
        for day_num in 0..6 loop
            declare
                l_date date := trunc(sysdate) - ((week_num - 1) * 7) - day_num;
                l_games_played number := 0;
            begin
                select nvl(games_played, 0)
                into l_games_played
                from patient_stats
                where patient_id = :G_PATIENT_ID
                and stat_date = l_date;
                
                apex_json.open_object;
                apex_json.write('date', to_char(l_date, 'DD/MM'));
                apex_json.write('games_played', l_games_played);
                apex_json.close_object;
            exception
                when no_data_found then
                    apex_json.open_object;
                    apex_json.write('date', to_char(l_date, 'DD/MM'));
                    apex_json.write('games_played', 0);
                    apex_json.close_object;
            end;
        end loop;
        
        apex_json.close_array;
    end loop;
    
    apex_json.close_array;
    apex_json.close_object;
end;]'
    );
    
    -- Current Cognitive Score
    wwv_flow_api.create_page_process(
        p_id => wwv_flow_api.id(5),
        p_process_sequence => 50,
        p_process_point => 'ON_DEMAND',
        p_process_type => 'NATIVE_PLSQL',
        p_process_name => 'GET_CURRENT_COGNITIVE_SCORE',
        p_process_sql_clob => q'[
declare
    l_score number;
begin
    select nvl(cognitive_score, 0)
    into l_score
    from patient_stats
    where patient_id = :G_PATIENT_ID
    and stat_date = trunc(sysdate);
    
    apex_json.open_object;
    apex_json.write('score', round(l_score, 0));
    apex_json.close_object;
exception
    when no_data_found then
        apex_json.open_object;
        apex_json.write('score', 0);
        apex_json.close_object;
end;]'
    );
end;
/

PROMPT Statistics Dashboard page created successfully!