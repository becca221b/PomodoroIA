-- =============================================================================
-- MVP Alzheimer's Cognitive Training - Master Deployment Script
-- =============================================================================
-- This script deploys the complete application including database schema,
-- initial data, PL/SQL packages, and APEX application structure.
--
-- Prerequisites:
-- 1. Oracle Autonomous Database (ATP/ADW) with APEX 21.1+
-- 2. User ALZHEIMER_MVP created with appropriate privileges
-- 3. Connected as ALZHEIMER_MVP user
-- =============================================================================

PROMPT =========================================================================
PROMPT MVP Alzheimer's Cognitive Training Deployment
PROMPT =========================================================================
PROMPT Starting deployment process...
PROMPT 

-- Set session parameters
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-YYYY HH24:MI:SS';
SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF
SET FEEDBACK ON

PROMPT -------------------------------------------------------------------------
PROMPT Step 1: Creating Database Schema
PROMPT -------------------------------------------------------------------------

-- Create tables
@@database/01_create_tables.sql

PROMPT 
PROMPT ✓ Database schema created successfully
PROMPT 

PROMPT -------------------------------------------------------------------------
PROMPT Step 2: Loading Initial Data
PROMPT -------------------------------------------------------------------------

-- Insert initial data
@@database/02_insert_initial_data.sql

PROMPT 
PROMPT ✓ Initial data loaded successfully
PROMPT 

PROMPT -------------------------------------------------------------------------
PROMPT Step 3: Creating AI Recommendation Engine
PROMPT -------------------------------------------------------------------------

-- Create PL/SQL packages
@@database/03_ai_recommendation_package.sql

PROMPT 
PROMPT ✓ AI recommendation engine deployed successfully
PROMPT 

PROMPT -------------------------------------------------------------------------
PROMPT Step 4: Creating APEX Application Structure
PROMPT -------------------------------------------------------------------------

-- Create APEX application
@@apex/application_structure.sql

PROMPT 
PROMPT ✓ APEX application structure created successfully
PROMPT 

PROMPT -------------------------------------------------------------------------
PROMPT Step 5: Creating APEX Pages
PROMPT -------------------------------------------------------------------------

-- Create dashboard page
@@apex/pages/page_02_dashboard.sql

-- Create emotion check-in page
@@apex/pages/page_03_emotion_checkin.sql

-- Create statistics page
@@apex/pages/page_11_statistics.sql

PROMPT 
PROMPT ✓ APEX pages created successfully
PROMPT 

PROMPT -------------------------------------------------------------------------
PROMPT Step 6: Creating Demo User and Test Data
PROMPT -------------------------------------------------------------------------

-- Create demo patient
INSERT INTO patients (
    username, email, first_name, last_name, date_of_birth,
    diagnosis_date, severity_level, caregiver_contact
) VALUES (
    'demo_user', 'demo@alzheimer-mvp.com', 'María', 'González', 
    DATE '1955-03-15', DATE '2023-01-15', 'MILD', 'juan.gonzalez@email.com'
);

-- Get the patient ID for demo user
DECLARE
    v_patient_id NUMBER;
BEGIN
    SELECT patient_id INTO v_patient_id
    FROM patients 
    WHERE username = 'demo_user';
    
    -- Create initial statistics
    INSERT INTO patient_stats (
        patient_id, stat_date, total_points, games_played,
        total_time_minutes, average_score, streak_days,
        current_level, achievements_count, mood_average, cognitive_score
    ) VALUES (
        v_patient_id, TRUNC(SYSDATE), 0, 0, 0, 0, 0, 1, 0, 3, 0
    );
    
    -- Create some sample emotion logs
    INSERT INTO patient_emotions (patient_id, emotion_id, intensity_level, notes)
    VALUES (v_patient_id, 1, 4, 'Me siento bien hoy, listo para jugar');
    
    INSERT INTO patient_emotions (patient_id, emotion_id, intensity_level, notes)
    VALUES (v_patient_id, 4, 3, 'Estado tranquilo después del desayuno');
    
    -- Generate initial recommendations
    ai_recommendations_pkg.generate_emotion_based_recommendations(v_patient_id);
    ai_recommendations_pkg.generate_performance_based_recommendations(v_patient_id);
    ai_recommendations_pkg.generate_routine_recommendations(v_patient_id);
    
    DBMS_OUTPUT.PUT_LINE('✓ Demo user "demo_user" created with initial data');
    DBMS_OUTPUT.PUT_LINE('✓ Sample emotions and recommendations generated');
END;
/

COMMIT;

PROMPT 
PROMPT ✓ Demo user and test data created successfully
PROMPT 

PROMPT -------------------------------------------------------------------------
PROMPT Step 7: Validation and Health Check
PROMPT -------------------------------------------------------------------------

-- Validate installation
DECLARE
    v_table_count NUMBER;
    v_data_count NUMBER;
    v_package_count NUMBER;
    v_patient_count NUMBER;
BEGIN
    -- Check tables
    SELECT COUNT(*) INTO v_table_count
    FROM user_tables
    WHERE table_name IN ('PATIENTS', 'EMOTIONS', 'GAMES', 'GAME_SESSIONS', 
                        'PATIENT_STATS', 'AI_RECOMMENDATIONS', 'ACHIEVEMENTS');
    
    -- Check data
    SELECT COUNT(*) INTO v_data_count FROM emotions;
    
    -- Check packages
    SELECT COUNT(*) INTO v_package_count
    FROM user_objects
    WHERE object_type = 'PACKAGE' AND object_name = 'AI_RECOMMENDATIONS_PKG';
    
    -- Check demo patient
    SELECT COUNT(*) INTO v_patient_count FROM patients WHERE username = 'demo_user';
    
    DBMS_OUTPUT.PUT_LINE('=== INSTALLATION VALIDATION ===');
    DBMS_OUTPUT.PUT_LINE('Tables created: ' || v_table_count || '/11');
    DBMS_OUTPUT.PUT_LINE('Emotions loaded: ' || v_data_count || '/10');
    DBMS_OUTPUT.PUT_LINE('AI Package: ' || CASE WHEN v_package_count > 0 THEN 'OK' ELSE 'ERROR' END);
    DBMS_OUTPUT.PUT_LINE('Demo patient: ' || CASE WHEN v_patient_count > 0 THEN 'OK' ELSE 'ERROR' END);
    
    IF v_table_count = 11 AND v_data_count = 10 AND v_package_count > 0 AND v_patient_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('🎉 DEPLOYMENT SUCCESSFUL! 🎉');
    ELSE
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('⚠️  DEPLOYMENT INCOMPLETE - Please check errors above');
    END IF;
END;
/

PROMPT 
PROMPT -------------------------------------------------------------------------
PROMPT Step 8: Post-Deployment Information
PROMPT -------------------------------------------------------------------------

PROMPT 
PROMPT ==========================================================================
PROMPT DEPLOYMENT COMPLETED SUCCESSFULLY!
PROMPT ==========================================================================
PROMPT 
PROMPT Next Steps:
PROMPT 1. Access your APEX workspace
PROMPT 2. Navigate to Application 100 - "Alzheimer's Cognitive Training"
PROMPT 3. Run the application
PROMPT 4. Login with username: demo_user
PROMPT 
PROMPT Demo Credentials:
PROMPT   Username: demo_user
PROMPT   Patient: María González
PROMPT   Email: demo@alzheimer-mvp.com
PROMPT 
PROMPT Application Features Available:
PROMPT   ✓ Emotion tracking (10 emotions with intensity levels)
PROMPT   ✓ AI-powered game recommendations
PROMPT   ✓ Comprehensive statistics dashboard
PROMPT   ✓ Gamification system (points, levels, achievements)
PROMPT   ✓ 18 cognitive games across 8 categories
PROMPT   ✓ Progress tracking and analytics
PROMPT 
PROMPT Technical Details:
PROMPT   • Database Schema: ALZHEIMER_MVP
PROMPT   • APEX Application ID: 100
PROMPT   • AI Engine: PL/SQL Package (ai_recommendations_pkg)
PROMPT   • Charts: Chart.js integration
PROMPT   • Responsive Design: Bootstrap-based
PROMPT 
PROMPT For support and documentation:
PROMPT   • README.md - Complete setup and usage guide
PROMPT   • Database documentation in /database/ folder
PROMPT   • APEX page source in /apex/pages/ folder
PROMPT 
PROMPT ==========================================================================
PROMPT Thank you for using the Alzheimer's Cognitive Training MVP!
PROMPT ==========================================================================

-- Reset session parameters
SET VERIFY ON
SET FEEDBACK OFF

PROMPT 
PROMPT Deployment script completed at: 
SELECT TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') as deployment_time FROM dual;
PROMPT