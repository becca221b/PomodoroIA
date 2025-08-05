-- Page 2: Dashboard/Home Page
-- Main dashboard with gamification elements and progress tracking

PROMPT Creating Dashboard Page (Page 2)...

-- Dashboard Page Regions
begin
    -- Welcome Region
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(1),
        p_plug_name => 'Welcome Message',
        p_region_template_id => wwv_flow_api.id(1),
        p_plug_template => wwv_flow_api.id(1),
        p_display_sequence => 10,
        p_include_in_reg_disp_sel_yn => 'Y',
        p_plug_source => q'[
<div class="welcome-container" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 15px; margin-bottom: 20px;">
    <div class="row">
        <div class="col-md-8">
            <h2 style="margin: 0; font-weight: 300;">¡Hola, &PATIENT_NAME.!</h2>
            <p style="margin: 10px 0 0 0; opacity: 0.9;">Bienvenido a tu entrenamiento cognitivo diario</p>
        </div>
        <div class="col-md-4 text-right">
            <div class="level-badge" style="background: rgba(255,255,255,0.2); padding: 10px; border-radius: 10px; display: inline-block;">
                <i class="fa fa-star" style="color: #FFD700;"></i>
                <span style="font-size: 18px; font-weight: bold;">Nivel &G_PATIENT_LEVEL.</span>
            </div>
        </div>
    </div>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
    
    -- Daily Progress Cards
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(2),
        p_plug_name => 'Daily Progress',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 20,
        p_plug_source => q'[
SELECT 
    '<div class="col-md-3 mb-3">
        <div class="card text-center" style="border: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); border-radius: 15px;">
            <div class="card-body">
                <i class="' || icon_class || '" style="font-size: 2.5rem; color: ' || color || '; margin-bottom: 10px;"></i>
                <h3 style="margin: 0; color: #333;">' || value || '</h3>
                <p style="margin: 5px 0 0 0; color: #666; font-size: 0.9rem;">' || label || '</p>
            </div>
        </div>
    </div>' as card_html
FROM (
    SELECT 'fa-gamepad' as icon_class, '#4CAF50' as color, 
           NVL(games_played, 0) as value, 'Juegos Hoy' as label, 1 as sort_order
    FROM patient_stats 
    WHERE patient_id = :G_PATIENT_ID AND stat_date = TRUNC(SYSDATE)
    UNION ALL
    SELECT 'fa-trophy' as icon_class, '#FFD700' as color,
           NVL(:G_TOTAL_POINTS, 0) as value, 'Puntos Totales' as label, 2 as sort_order
    FROM dual
    UNION ALL
    SELECT 'fa-fire' as icon_class, '#FF5722' as color,
           NVL(streak_days, 0) as value, 'Días Seguidos' as label, 3 as sort_order
    FROM patient_stats 
    WHERE patient_id = :G_PATIENT_ID AND stat_date = TRUNC(SYSDATE)
    UNION ALL
    SELECT 'fa-chart-line' as icon_class, '#2196F3' as color,
           NVL(ROUND(cognitive_score, 0), 0) as value, 'Puntuación Cognitiva' as label, 4 as sort_order
    FROM patient_stats 
    WHERE patient_id = :G_PATIENT_ID AND stat_date = TRUNC(SYSDATE)
) ORDER BY sort_order]',
        p_plug_source_type => 'NATIVE_SQL_REPORT',
        p_plug_query_options => 'DERIVED_REPORT_COLUMNS'
    );
    
    -- Emotion Check-in Card
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(3),
        p_plug_name => 'Emotion Check-in',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 30,
        p_plug_source => q'[
<div class="card" style="border: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); border-radius: 15px; margin-bottom: 20px;">
    <div class="card-header" style="background: linear-gradient(45deg, #FF6B6B, #FF8E8E); color: white; border-radius: 15px 15px 0 0;">
        <h5 style="margin: 0;"><i class="fa fa-heart"></i> ¿Cómo te sientes hoy?</h5>
    </div>
    <div class="card-body">
        <p>Registra tu estado emocional para recibir recomendaciones personalizadas.</p>
        <a href="f?p=&APP_ID.:3:&SESSION." class="btn btn-primary btn-lg">
            <i class="fa fa-heart"></i> Registrar Estado de Ánimo
        </a>
    </div>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
    
    -- AI Recommendations
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(4),
        p_plug_name => 'AI Recommendations',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 40,
        p_plug_source => q'[
SELECT 
    '<div class="recommendation-card" style="background: white; border-radius: 15px; padding: 20px; margin-bottom: 15px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); border-left: 4px solid ' || 
    CASE recommendation_type 
        WHEN 'EMOTION_BASED' THEN '#FF6B6B'
        WHEN 'PERFORMANCE_BASED' THEN '#4CAF50'
        ELSE '#2196F3'
    END || ';">
        <div class="row">
            <div class="col-md-8">
                <h6 style="margin: 0 0 10px 0; color: #333;">' || g.game_name || '</h6>
                <p style="margin: 0 0 10px 0; color: #666; font-size: 0.9rem;">' || g.description || '</p>
                <small style="color: #999;">
                    <i class="fa fa-clock"></i> ' || g.estimated_duration || ' min | 
                    <i class="fa fa-star"></i> ' || g.points_base || ' puntos |
                    <i class="fa fa-brain"></i> ' || g.cognitive_benefits || '
                </small>
                <br><br>
                <small style="color: #666; font-style: italic;">' || ar.reasoning || '</small>
            </div>
            <div class="col-md-4 text-right">
                <div style="margin-bottom: 10px;">
                    <span class="badge" style="background: ' || 
                    CASE recommendation_type 
                        WHEN 'EMOTION_BASED' THEN '#FF6B6B'
                        WHEN 'PERFORMANCE_BASED' THEN '#4CAF50'
                        ELSE '#2196F3'
                    END || '; color: white;">' || 
                    CASE recommendation_type 
                        WHEN 'EMOTION_BASED' THEN 'Basado en Emociones'
                        WHEN 'PERFORMANCE_BASED' THEN 'Basado en Rendimiento'
                        ELSE 'Rutina Diaria'
                    END || '</span>
                </div>
                <div style="margin-bottom: 10px;">
                    <small style="color: #999;">Confianza: ' || ROUND(ar.confidence_score * 100) || '%</small>
                </div>
                <a href="f?p=&APP_ID.:10:&SESSION.::NO::P10_GAME_ID:' || g.game_id || '" 
                   class="btn btn-primary">
                    <i class="fa fa-play"></i> Jugar
                </a>
            </div>
        </div>
    </div>' as recommendation_html
FROM ai_recommendations ar
JOIN games g ON ar.recommended_game_id = g.game_id
WHERE ar.patient_id = :G_PATIENT_ID
AND ar.recommended_date >= TRUNC(SYSDATE)
AND ar.is_accepted IS NULL
ORDER BY ar.confidence_score DESC, ar.recommended_date DESC]',
        p_plug_source_type => 'NATIVE_SQL_REPORT'
    );
    
    -- Recent Achievements
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(5),
        p_plug_name => 'Recent Achievements',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 50,
        p_plug_source => q'[
<div class="card" style="border: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); border-radius: 15px;">
    <div class="card-header" style="background: linear-gradient(45deg, #FFD700, #FFA000); color: white; border-radius: 15px 15px 0 0;">
        <h5 style="margin: 0;"><i class="fa fa-trophy"></i> Logros Recientes</h5>
    </div>
    <div class="card-body">]' || 
    (SELECT LISTAGG(
        '<div class="achievement-item" style="display: flex; align-items: center; padding: 10px; margin-bottom: 10px; background: #f8f9fa; border-radius: 10px;">
            <div style="width: 50px; height: 50px; background: ' || a.badge_color || '; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-right: 15px;">
                <i class="' || a.icon_class || '" style="color: white; font-size: 1.5rem;"></i>
            </div>
            <div style="flex: 1;">
                <h6 style="margin: 0; color: #333;">' || a.achievement_name || '</h6>
                <small style="color: #666;">' || a.description || '</small>
                <br><small style="color: #999;">Obtenido: ' || TO_CHAR(pa.earned_date, 'DD/MM/YYYY') || '</small>
            </div>
            <div>
                <span class="badge badge-success">+' || pa.points_earned || ' pts</span>
            </div>
        </div>', CHR(10)) WITHIN GROUP (ORDER BY pa.earned_date DESC)
     FROM patient_achievements pa
     JOIN achievements a ON pa.achievement_id = a.achievement_id
     WHERE pa.patient_id = :G_PATIENT_ID
     AND pa.earned_date >= SYSDATE - 7
     AND ROWNUM <= 3) || 
    q'[
        <div class="text-center" style="margin-top: 15px;">
            <a href="f?p=&APP_ID.:12:&SESSION." class="btn btn-outline-primary">
                Ver Todos los Logros <i class="fa fa-arrow-right"></i>
            </a>
        </div>
    </div>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
    
    -- Quick Game Access
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(6),
        p_plug_name => 'Quick Game Access',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 60,
        p_plug_source => q'[
SELECT 
    '<div class="col-md-4 mb-3">
        <div class="card game-category-card" style="border: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); border-radius: 15px; cursor: pointer; transition: transform 0.3s;">
            <div class="card-body text-center">
                <div style="width: 60px; height: 60px; background: linear-gradient(45deg, #667eea, #764ba2); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 15px;">
                    <i class="' || icon_class || '" style="color: white; font-size: 1.8rem;"></i>
                </div>
                <h6 style="margin: 0 0 10px 0; color: #333;">' || category_name || '</h6>
                <small style="color: #666;">' || description || '</small>
                <br><br>
                <a href="f?p=&APP_ID.:' || (4 + category_id) || ':&SESSION." class="btn btn-primary btn-sm">
                    Explorar <i class="fa fa-arrow-right"></i>
                </a>
            </div>
        </div>
    </div>' as category_html
FROM game_categories
WHERE category_id <= 6
ORDER BY category_id]',
        p_plug_source_type => 'NATIVE_SQL_REPORT'
    );
end;
/

-- Page Items
begin
    -- Patient Name (computed)
    wwv_flow_api.create_page_item(
        p_id => wwv_flow_api.id(1),
        p_name => 'PATIENT_NAME',
        p_item_sequence => 10,
        p_item_plug_id => wwv_flow_api.id(1),
        p_source => q'[
SELECT first_name || ' ' || last_name
FROM patients 
WHERE patient_id = :G_PATIENT_ID]',
        p_source_type => 'QUERY',
        p_display_as => 'NATIVE_HIDDEN'
    );
end;
/

-- Dynamic Actions
begin
    -- Auto-refresh recommendations every 5 minutes
    wwv_flow_api.create_page_da_event(
        p_id => wwv_flow_api.id(1),
        p_name => 'Auto Refresh Recommendations',
        p_event_sequence => 10,
        p_triggering_element_type => 'JAVASCRIPT_EXPRESSION',
        p_triggering_element => 'window',
        p_bind_type => 'bind',
        p_bind_event_type => 'ready'
    );
    
    wwv_flow_api.create_page_da_action(
        p_id => wwv_flow_api.id(1),
        p_event_id => wwv_flow_api.id(1),
        p_event_result => 'TRUE',
        p_action_sequence => 10,
        p_execute_on_page_init => 'N',
        p_action => 'NATIVE_JAVASCRIPT_CODE',
        p_attribute_01 => q'[
// Auto-refresh recommendations every 5 minutes
setInterval(function() {
    apex.region("AI Recommendations").refresh();
}, 300000);

// Add hover effects to game category cards
$('.game-category-card').hover(
    function() { $(this).css('transform', 'translateY(-5px)'); },
    function() { $(this).css('transform', 'translateY(0)'); }
);]'
    );
end;
/

PROMPT Dashboard page created successfully!