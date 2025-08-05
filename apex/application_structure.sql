-- Oracle APEX Application Structure for Alzheimer's MVP
-- Application ID: 100 (change as needed)

-- Application Definition
PROMPT Creating Application 100 - Alzheimer's Cognitive Training...

-- Application Settings
begin
    apex_application_install.set_application_id(100);
    apex_application_install.set_schema('ALZHEIMER_MVP');
    apex_application_install.set_application_name('Alzheimer''s Cognitive Training');
    apex_application_install.set_application_alias('ALZHEIMER_MVP');
    apex_application_install.set_auto_install_sup_obj(true);
end;
/

-- Authentication Scheme
PROMPT Creating Authentication Scheme...
begin
    wwv_flow_api.create_authentication(
        p_id => wwv_flow_api.id(1),
        p_name => 'Patient Authentication',
        p_scheme_type => 'NATIVE_CUSTOM',
        p_attribute_01 => 'ALZHEIMER_MVP',
        p_attribute_02 => 'authenticate_patient',
        p_attribute_03 => 'N',
        p_attribute_04 => 'N',
        p_attribute_05 => 'N',
        p_invalid_session_type => 'LOGIN',
        p_use_secure_cookie_yn => 'Y',
        p_ras_mode => 0
    );
end;
/

-- Application Pages Structure
PROMPT Creating Application Pages...

-- Page 0: Global Page (Navigation)
begin
    wwv_flow_api.create_page(
        p_id => 0,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Global Page',
        p_step_title => 'Global Page',
        p_page_template_id => wwv_flow_api.id(1),
        p_nav_list_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 1: Login Page
begin
    wwv_flow_api.create_page(
        p_id => 1,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Login',
        p_step_title => 'Iniciar Sesión - Entrenamiento Cognitivo',
        p_page_template_id => wwv_flow_api.id(2),
        p_page_is_public_y_n => 'Y'
    );
end;
/

-- Page 2: Dashboard/Home
begin
    wwv_flow_api.create_page(
        p_id => 2,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Dashboard',
        p_step_title => 'Mi Panel Principal',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 3: Emotion Check-in
begin
    wwv_flow_api.create_page(
        p_id => 3,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Emotion Check-in',
        p_step_title => '¿Cómo te sientes hoy?',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 4: Game Categories
begin
    wwv_flow_api.create_page(
        p_id => 4,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Game Categories',
        p_step_title => 'Categorías de Juegos',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 5: Memory Games
begin
    wwv_flow_api.create_page(
        p_id => 5,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Memory Games',
        p_step_title => 'Juegos de Memoria',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 6: Attention Games
begin
    wwv_flow_api.create_page(
        p_id => 6,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Attention Games',
        p_step_title => 'Juegos de Atención',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 7: Language Games
begin
    wwv_flow_api.create_page(
        p_id => 7,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Language Games',
        p_step_title => 'Juegos de Lenguaje',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 8: Executive Function Games
begin
    wwv_flow_api.create_page(
        p_id => 8,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Executive Function Games',
        p_step_title => 'Juegos de Función Ejecutiva',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 9: Relaxation Activities
begin
    wwv_flow_api.create_page(
        p_id => 9,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Relaxation Activities',
        p_step_title => 'Actividades de Relajación',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 10: Game Session
begin
    wwv_flow_api.create_page(
        p_id => 10,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Game Session',
        p_step_title => 'Jugando',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 11: Progress Statistics
begin
    wwv_flow_api.create_page(
        p_id => 11,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Progress Statistics',
        p_step_title => 'Mi Progreso',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 12: Achievements
begin
    wwv_flow_api.create_page(
        p_id => 12,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Achievements',
        p_step_title => 'Mis Logros',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 13: AI Recommendations
begin
    wwv_flow_api.create_page(
        p_id => 13,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'AI Recommendations',
        p_step_title => 'Recomendaciones Personalizadas',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 14: Profile Settings
begin
    wwv_flow_api.create_page(
        p_id => 14,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Profile Settings',
        p_step_title => 'Mi Perfil',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Page 15: Caregiver Dashboard
begin
    wwv_flow_api.create_page(
        p_id => 15,
        p_user_interface_id => wwv_flow_api.id(1),
        p_name => 'Caregiver Dashboard',
        p_step_title => 'Panel del Cuidador',
        p_page_template_id => wwv_flow_api.id(1)
    );
end;
/

-- Navigation Menu
PROMPT Creating Navigation Menu...
begin
    wwv_flow_api.create_list(
        p_id => wwv_flow_api.id(1),
        p_name => 'Navigation Menu',
        p_list_type => 'STATIC'
    );
    
    -- Dashboard
    wwv_flow_api.create_list_item(
        p_id => wwv_flow_api.id(1),
        p_list_id => wwv_flow_api.id(1),
        p_list_item_display_sequence => 10,
        p_list_item_link_text => 'Inicio',
        p_list_item_link_target => 'f?p=&APP_ID.:2:&SESSION.',
        p_list_item_icon => 'fa-home'
    );
    
    -- Emotion Check-in
    wwv_flow_api.create_list_item(
        p_id => wwv_flow_api.id(2),
        p_list_id => wwv_flow_api.id(1),
        p_list_item_display_sequence => 20,
        p_list_item_link_text => 'Mi Estado de Ánimo',
        p_list_item_link_target => 'f?p=&APP_ID.:3:&SESSION.',
        p_list_item_icon => 'fa-heart'
    );
    
    -- Games
    wwv_flow_api.create_list_item(
        p_id => wwv_flow_api.id(3),
        p_list_id => wwv_flow_api.id(1),
        p_list_item_display_sequence => 30,
        p_list_item_link_text => 'Juegos',
        p_list_item_link_target => 'f?p=&APP_ID.:4:&SESSION.',
        p_list_item_icon => 'fa-gamepad'
    );
    
    -- AI Recommendations
    wwv_flow_api.create_list_item(
        p_id => wwv_flow_api.id(4),
        p_list_id => wwv_flow_api.id(1),
        p_list_item_display_sequence => 40,
        p_list_item_link_text => 'Recomendaciones',
        p_list_item_link_target => 'f?p=&APP_ID.:13:&SESSION.',
        p_list_item_icon => 'fa-magic'
    );
    
    -- Progress
    wwv_flow_api.create_list_item(
        p_id => wwv_flow_api.id(5),
        p_list_id => wwv_flow_api.id(1),
        p_list_item_display_sequence => 50,
        p_list_item_link_text => 'Mi Progreso',
        p_list_item_link_target => 'f?p=&APP_ID.:11:&SESSION.',
        p_list_item_icon => 'fa-chart-line'
    );
    
    -- Achievements
    wwv_flow_api.create_list_item(
        p_id => wwv_flow_api.id(6),
        p_list_id => wwv_flow_api.id(1),
        p_list_item_display_sequence => 60,
        p_list_item_link_text => 'Mis Logros',
        p_list_item_link_target => 'f?p=&APP_ID.:12:&SESSION.',
        p_list_item_icon => 'fa-trophy'
    );
    
    -- Profile
    wwv_flow_api.create_list_item(
        p_id => wwv_flow_api.id(7),
        p_list_id => wwv_flow_api.id(1),
        p_list_item_display_sequence => 70,
        p_list_item_link_text => 'Mi Perfil',
        p_list_item_link_target => 'f?p=&APP_ID.:14:&SESSION.',
        p_list_item_icon => 'fa-user'
    );
end;
/

-- Application Items (Global Variables)
PROMPT Creating Application Items...
begin
    -- Current Patient ID
    wwv_flow_api.create_flow_item(
        p_id => wwv_flow_api.id(1),
        p_name => 'G_PATIENT_ID',
        p_scope => 'GLOBAL',
        p_protection_level => 'I'
    );
    
    -- Current Game Session ID
    wwv_flow_api.create_flow_item(
        p_id => wwv_flow_api.id(2),
        p_name => 'G_CURRENT_SESSION_ID',
        p_scope => 'GLOBAL',
        p_protection_level => 'I'
    );
    
    -- Current Emotion ID
    wwv_flow_api.create_flow_item(
        p_id => wwv_flow_api.id(3),
        p_name => 'G_CURRENT_EMOTION_ID',
        p_scope => 'GLOBAL',
        p_protection_level => 'I'
    );
    
    -- Patient Level
    wwv_flow_api.create_flow_item(
        p_id => wwv_flow_api.id(4),
        p_name => 'G_PATIENT_LEVEL',
        p_scope => 'GLOBAL',
        p_protection_level => 'I'
    );
    
    -- Total Points
    wwv_flow_api.create_flow_item(
        p_id => wwv_flow_api.id(5),
        p_name => 'G_TOTAL_POINTS',
        p_scope => 'GLOBAL',
        p_protection_level => 'I'
    );
end;
/

-- Application Processes
PROMPT Creating Application Processes...

-- Login Process
begin
    wwv_flow_api.create_flow_process(
        p_id => wwv_flow_api.id(1),
        p_process_sequence => 10,
        p_process_point => 'AFTER_SUBMIT',
        p_process_type => 'NATIVE_PLSQL',
        p_process_name => 'Login Process',
        p_process_sql_clob => q'[
begin
    -- Authenticate patient and set session variables
    declare
        v_patient_id number;
        v_patient_level number;
        v_total_points number;
    begin
        select p.patient_id, 
               nvl(ps.current_level, 1),
               nvl(ps.total_points, 0)
        into v_patient_id, v_patient_level, v_total_points
        from patients p
        left join patient_stats ps on p.patient_id = ps.patient_id 
                                   and ps.stat_date = trunc(sysdate)
        where upper(p.username) = upper(:P1_USERNAME)
        and p.is_active = 'Y';
        
        :G_PATIENT_ID := v_patient_id;
        :G_PATIENT_LEVEL := v_patient_level;
        :G_TOTAL_POINTS := v_total_points;
        
        -- Generate AI recommendations
        ai_recommendations_pkg.generate_emotion_based_recommendations(v_patient_id);
        ai_recommendations_pkg.generate_performance_based_recommendations(v_patient_id);
        ai_recommendations_pkg.generate_routine_recommendations(v_patient_id);
        
    exception
        when no_data_found then
            raise_application_error(-20001, 'Usuario no válido');
    end;
end;]',
        p_process_when_button_id => wwv_flow_api.id(1)
    );
end;
/

-- Daily Stats Update Process
begin
    wwv_flow_api.create_flow_process(
        p_id => wwv_flow_api.id(2),
        p_process_sequence => 10,
        p_process_point => 'BEFORE_HEADER',
        p_process_type => 'NATIVE_PLSQL',
        p_process_name => 'Update Daily Stats',
        p_process_sql_clob => q'[
begin
    if :G_PATIENT_ID is not null then
        ai_recommendations_pkg.update_daily_stats(:G_PATIENT_ID);
    end if;
end;]'
    );
end;
/

PROMPT Application structure created successfully!