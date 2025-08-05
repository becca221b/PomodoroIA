-- Page 3: Emotion Check-in Page
-- Interactive emotion tracking with visual feedback

PROMPT Creating Emotion Check-in Page (Page 3)...

-- Page Items
begin
    -- Selected Emotion ID
    wwv_flow_api.create_page_item(
        p_id => wwv_flow_api.id(1),
        p_name => 'P3_EMOTION_ID',
        p_item_sequence => 10,
        p_display_as => 'NATIVE_HIDDEN',
        p_protection_level => 'S'
    );
    
    -- Emotion Intensity Level
    wwv_flow_api.create_page_item(
        p_id => wwv_flow_api.id(2),
        p_name => 'P3_INTENSITY_LEVEL',
        p_item_sequence => 20,
        p_display_as => 'NATIVE_HIDDEN',
        p_protection_level => 'S'
    );
    
    -- Optional Notes
    wwv_flow_api.create_page_item(
        p_id => wwv_flow_api.id(3),
        p_name => 'P3_NOTES',
        p_item_sequence => 30,
        p_prompt => 'Notas adicionales (opcional)',
        p_display_as => 'NATIVE_TEXTAREA',
        p_cSize => 50,
        p_cMaxlength => 500,
        p_field_template => wwv_flow_api.id(1),
        p_item_template_options => 'large'
    );
end;
/

-- Page Regions
begin
    -- Header Region
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(1),
        p_plug_name => 'Emotion Check-in Header',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 10,
        p_plug_source => q'[
<div class="emotion-header" style="text-align: center; padding: 30px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 15px; margin-bottom: 30px;">
    <i class="fa fa-heart" style="font-size: 3rem; margin-bottom: 15px; opacity: 0.8;"></i>
    <h2 style="margin: 0 0 10px 0; font-weight: 300;">¿Cómo te sientes hoy?</h2>
    <p style="margin: 0; opacity: 0.9; font-size: 1.1rem;">Selecciona la emoción que mejor describe tu estado actual</p>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
    
    -- Emotion Selection Grid
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(2),
        p_plug_name => 'Emotion Selection',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 20,
        p_plug_source => q'[
<div class="emotion-grid" style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px;">
    <div class="emotion-card" data-emotion-id="1" data-emotion-name="Feliz" style="background: linear-gradient(45deg, #FFD700, #FFA000); color: white; padding: 25px; border-radius: 15px; text-align: center; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        <i class="fa fa-smile" style="font-size: 3rem; margin-bottom: 15px;"></i>
        <h4 style="margin: 0 0 10px 0;">Feliz</h4>
        <p style="margin: 0; opacity: 0.9; font-size: 0.9rem;">Estado de alegría y satisfacción</p>
    </div>
    
    <div class="emotion-card" data-emotion-id="2" data-emotion-name="Triste" style="background: linear-gradient(45deg, #4169E1, #1E3A8A); color: white; padding: 25px; border-radius: 15px; text-align: center; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        <i class="fa fa-frown" style="font-size: 3rem; margin-bottom: 15px;"></i>
        <h4 style="margin: 0 0 10px 0;">Triste</h4>
        <p style="margin: 0; opacity: 0.9; font-size: 0.9rem;">Estado de melancolía o pena</p>
    </div>
    
    <div class="emotion-card" data-emotion-id="3" data-emotion-name="Ansioso" style="background: linear-gradient(45deg, #FF6347, #DC143C); color: white; padding: 25px; border-radius: 15px; text-align: center; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        <i class="fa fa-exclamation-triangle" style="font-size: 3rem; margin-bottom: 15px;"></i>
        <h4 style="margin: 0 0 10px 0;">Ansioso</h4>
        <p style="margin: 0; opacity: 0.9; font-size: 0.9rem;">Estado de preocupación o nerviosismo</p>
    </div>
    
    <div class="emotion-card" data-emotion-id="4" data-emotion-name="Tranquilo" style="background: linear-gradient(45deg, #90EE90, #32CD32); color: white; padding: 25px; border-radius: 15px; text-align: center; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        <i class="fa fa-leaf" style="font-size: 3rem; margin-bottom: 15px;"></i>
        <h4 style="margin: 0 0 10px 0;">Tranquilo</h4>
        <p style="margin: 0; opacity: 0.9; font-size: 0.9rem;">Estado de paz y serenidad</p>
    </div>
    
    <div class="emotion-card" data-emotion-id="5" data-emotion-name="Confundido" style="background: linear-gradient(45deg, #DDA0DD, #9370DB); color: white; padding: 25px; border-radius: 15px; text-align: center; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        <i class="fa fa-question-circle" style="font-size: 3rem; margin-bottom: 15px;"></i>
        <h4 style="margin: 0 0 10px 0;">Confundido</h4>
        <p style="margin: 0; opacity: 0.9; font-size: 0.9rem;">Estado de desorientación mental</p>
    </div>
    
    <div class="emotion-card" data-emotion-id="6" data-emotion-name="Motivado" style="background: linear-gradient(45deg, #FF69B4, #FF1493); color: white; padding: 25px; border-radius: 15px; text-align: center; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        <i class="fa fa-rocket" style="font-size: 3rem; margin-bottom: 15px;"></i>
        <h4 style="margin: 0 0 10px 0;">Motivado</h4>
        <p style="margin: 0; opacity: 0.9; font-size: 0.9rem;">Estado de energía y determinación</p>
    </div>
    
    <div class="emotion-card" data-emotion-id="7" data-emotion-name="Frustrado" style="background: linear-gradient(45deg, #DC143C, #8B0000); color: white; padding: 25px; border-radius: 15px; text-align: center; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        <i class="fa fa-angry" style="font-size: 3rem; margin-bottom: 15px;"></i>
        <h4 style="margin: 0 0 10px 0;">Frustrado</h4>
        <p style="margin: 0; opacity: 0.9; font-size: 0.9rem;">Estado de irritación por obstáculos</p>
    </div>
    
    <div class="emotion-card" data-emotion-id="8" data-emotion-name="Relajado" style="background: linear-gradient(45deg, #20B2AA, #008B8B); color: white; padding: 25px; border-radius: 15px; text-align: center; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        <i class="fa fa-spa" style="font-size: 3rem; margin-bottom: 15px;"></i>
        <h4 style="margin: 0 0 10px 0;">Relajado</h4>
        <p style="margin: 0; opacity: 0.9; font-size: 0.9rem;">Estado de calma y descanso</p>
    </div>
    
    <div class="emotion-card" data-emotion-id="9" data-emotion-name="Nostálgico" style="background: linear-gradient(45deg, #F0E68C, #DAA520); color: #333; padding: 25px; border-radius: 15px; text-align: center; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        <i class="fa fa-clock" style="font-size: 3rem; margin-bottom: 15px;"></i>
        <h4 style="margin: 0 0 10px 0;">Nostálgico</h4>
        <p style="margin: 0; opacity: 0.8; font-size: 0.9rem;">Estado de añoranza por el pasado</p>
    </div>
    
    <div class="emotion-card" data-emotion-id="10" data-emotion-name="Enérgico" style="background: linear-gradient(45deg, #FF4500, #FF6347); color: white; padding: 25px; border-radius: 15px; text-align: center; cursor: pointer; transition: all 0.3s; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
        <i class="fa fa-bolt" style="font-size: 3rem; margin-bottom: 15px;"></i>
        <h4 style="margin: 0 0 10px 0;">Enérgico</h4>
        <p style="margin: 0; opacity: 0.9; font-size: 0.9rem;">Estado de vitalidad y dinamismo</p>
    </div>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
    
    -- Intensity Selection (Hidden initially)
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(3),
        p_plug_name => 'Intensity Selection',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 30,
        p_plug_source => q'[
<div id="intensity-section" style="display: none; background: white; padding: 30px; border-radius: 15px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); margin-bottom: 30px;">
    <h4 style="text-align: center; margin-bottom: 25px; color: #333;">
        ¿Qué tan intenso es este sentimiento?
    </h4>
    <div class="intensity-scale" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
        <span style="color: #666; font-size: 0.9rem;">Poco</span>
        <div class="intensity-buttons" style="display: flex; gap: 15px;">
            <button type="button" class="intensity-btn" data-intensity="1" style="width: 40px; height: 40px; border-radius: 50%; border: 2px solid #ddd; background: white; cursor: pointer; transition: all 0.3s; font-weight: bold;">1</button>
            <button type="button" class="intensity-btn" data-intensity="2" style="width: 40px; height: 40px; border-radius: 50%; border: 2px solid #ddd; background: white; cursor: pointer; transition: all 0.3s; font-weight: bold;">2</button>
            <button type="button" class="intensity-btn" data-intensity="3" style="width: 40px; height: 40px; border-radius: 50%; border: 2px solid #ddd; background: white; cursor: pointer; transition: all 0.3s; font-weight: bold;">3</button>
            <button type="button" class="intensity-btn" data-intensity="4" style="width: 40px; height: 40px; border-radius: 50%; border: 2px solid #ddd; background: white; cursor: pointer; transition: all 0.3s; font-weight: bold;">4</button>
            <button type="button" class="intensity-btn" data-intensity="5" style="width: 40px; height: 40px; border-radius: 50%; border: 2px solid #ddd; background: white; cursor: pointer; transition: all 0.3s; font-weight: bold;">5</button>
        </div>
        <span style="color: #666; font-size: 0.9rem;">Mucho</span>
    </div>
    <div id="selected-emotion-display" style="text-align: center; margin-bottom: 20px;">
        <span style="color: #666;">Has seleccionado: </span>
        <strong id="emotion-name-display" style="color: #333;"></strong>
    </div>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
    
    -- Notes Section
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(4),
        p_plug_name => 'Notes Section',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 40,
        p_plug_source => q'[
<div id="notes-section" style="display: none; background: white; padding: 30px; border-radius: 15px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); margin-bottom: 30px;">
    <h5 style="margin-bottom: 15px; color: #333;">
        <i class="fa fa-edit"></i> ¿Hay algo más que quieras compartir?
    </h5>
    <p style="color: #666; margin-bottom: 20px;">
        Puedes agregar notas sobre lo que te hace sentir así o cualquier detalle adicional (opcional).
    </p>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
    
    -- Action Buttons
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(5),
        p_plug_name => 'Action Buttons',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 50,
        p_plug_source => q'[
<div id="action-buttons" style="display: none; text-align: center; margin-top: 30px;">
    <button type="button" id="save-emotion-btn" class="btn btn-success btn-lg" style="margin-right: 15px; padding: 12px 30px;">
        <i class="fa fa-save"></i> Guardar Estado de Ánimo
    </button>
    <button type="button" id="cancel-btn" class="btn btn-secondary btn-lg" style="padding: 12px 30px;">
        <i class="fa fa-times"></i> Cancelar
    </button>
</div>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
end;
/

-- Dynamic Actions
begin
    -- Emotion Card Click
    wwv_flow_api.create_page_da_event(
        p_id => wwv_flow_api.id(1),
        p_name => 'Emotion Card Click',
        p_event_sequence => 10,
        p_triggering_element_type => 'JQUERY_SELECTOR',
        p_triggering_element => '.emotion-card',
        p_bind_type => 'live',
        p_bind_event_type => 'click'
    );
    
    wwv_flow_api.create_page_da_action(
        p_id => wwv_flow_api.id(1),
        p_event_id => wwv_flow_api.id(1),
        p_event_result => 'TRUE',
        p_action_sequence => 10,
        p_execute_on_page_init => 'N',
        p_action => 'NATIVE_JAVASCRIPT_CODE',
        p_attribute_01 => q'[
// Remove selection from all cards
$('.emotion-card').removeClass('selected').css({
    'transform': 'scale(1)',
    'box-shadow': '0 4px 6px rgba(0,0,0,0.1)'
});

// Add selection to clicked card
$(this.triggeringElement).addClass('selected').css({
    'transform': 'scale(1.05)',
    'box-shadow': '0 8px 15px rgba(0,0,0,0.2)'
});

// Get emotion data
var emotionId = $(this.triggeringElement).data('emotion-id');
var emotionName = $(this.triggeringElement).data('emotion-name');

// Set hidden items
apex.item('P3_EMOTION_ID').setValue(emotionId);
$('#emotion-name-display').text(emotionName);

// Show intensity section with animation
$('#intensity-section').slideDown(500);

// Scroll to intensity section
$('html, body').animate({
    scrollTop: $('#intensity-section').offset().top - 50
}, 500);]'
    );
    
    -- Intensity Button Click
    wwv_flow_api.create_page_da_event(
        p_id => wwv_flow_api.id(2),
        p_name => 'Intensity Button Click',
        p_event_sequence => 20,
        p_triggering_element_type => 'JQUERY_SELECTOR',
        p_triggering_element => '.intensity-btn',
        p_bind_type => 'live',
        p_bind_event_type => 'click'
    );
    
    wwv_flow_api.create_page_da_action(
        p_id => wwv_flow_api.id(2),
        p_event_id => wwv_flow_api.id(2),
        p_event_result => 'TRUE',
        p_action_sequence => 10,
        p_execute_on_page_init => 'N',
        p_action => 'NATIVE_JAVASCRIPT_CODE',
        p_attribute_01 => q'[
// Remove selection from all intensity buttons
$('.intensity-btn').css({
    'background': 'white',
    'border-color': '#ddd',
    'color': '#333'
});

// Get intensity value
var intensity = $(this.triggeringElement).data('intensity');

// Style selected button and previous ones
for (let i = 1; i <= intensity; i++) {
    $('.intensity-btn[data-intensity="' + i + '"]').css({
        'background': 'linear-gradient(45deg, #667eea, #764ba2)',
        'border-color': '#667eea',
        'color': 'white'
    });
}

// Set hidden item
apex.item('P3_INTENSITY_LEVEL').setValue(intensity);

// Show notes section and action buttons
$('#notes-section').slideDown(500);
$('#action-buttons').slideDown(500);

// Scroll to notes section
setTimeout(function() {
    $('html, body').animate({
        scrollTop: $('#notes-section').offset().top - 50
    }, 500);
}, 300);]'
    );
    
    -- Save Emotion Button Click
    wwv_flow_api.create_page_da_event(
        p_id => wwv_flow_api.id(3),
        p_name => 'Save Emotion Click',
        p_event_sequence => 30,
        p_triggering_element_type => 'BUTTON',
        p_triggering_button_id => 'save-emotion-btn',
        p_bind_type => 'bind',
        p_bind_event_type => 'click'
    );
    
    wwv_flow_api.create_page_da_action(
        p_id => wwv_flow_api.id(3),
        p_event_id => wwv_flow_api.id(3),
        p_event_result => 'TRUE',
        p_action_sequence => 10,
        p_execute_on_page_init => 'N',
        p_action => 'NATIVE_PLSQL',
        p_attribute_01 => q'[
begin
    -- Validate inputs
    if :P3_EMOTION_ID is null or :P3_INTENSITY_LEVEL is null then
        apex_error.add_error(
            p_message => 'Por favor selecciona una emoción e intensidad.',
            p_display_location => apex_error.c_inline_in_notification
        );
        return;
    end if;
    
    -- Insert emotion log
    insert into patient_emotions (
        patient_id,
        emotion_id,
        intensity_level,
        notes,
        session_id
    ) values (
        :G_PATIENT_ID,
        :P3_EMOTION_ID,
        :P3_INTENSITY_LEVEL,
        :P3_NOTES,
        :APP_SESSION
    );
    
    -- Update global emotion
    :G_CURRENT_EMOTION_ID := :P3_EMOTION_ID;
    
    -- Generate new emotion-based recommendations
    ai_recommendations_pkg.generate_emotion_based_recommendations(
        :G_PATIENT_ID, 
        :P3_EMOTION_ID
    );
    
    -- Update daily stats
    ai_recommendations_pkg.update_daily_stats(:G_PATIENT_ID);
    
    commit;
    
    -- Show success message
    apex_application.g_print_success_message := 'Estado emocional registrado exitosamente. ¡Gracias por compartir cómo te sientes!';
end;]'
    );
    
    wwv_flow_api.create_page_da_action(
        p_id => wwv_flow_api.id(4),
        p_event_id => wwv_flow_api.id(3),
        p_event_result => 'TRUE',
        p_action_sequence => 20,
        p_execute_on_page_init => 'N',
        p_action => 'NATIVE_JAVASCRIPT_CODE',
        p_attribute_01 => q'[
// Redirect to dashboard after short delay
setTimeout(function() {
    apex.navigation.redirect('f?p=&APP_ID.:2:&SESSION.');
}, 2000);]'
    );
    
    -- Cancel Button Click
    wwv_flow_api.create_page_da_event(
        p_id => wwv_flow_api.id(4),
        p_name => 'Cancel Click',
        p_event_sequence => 40,
        p_triggering_element_type => 'BUTTON',
        p_triggering_button_id => 'cancel-btn',
        p_bind_type => 'bind',
        p_bind_event_type => 'click'
    );
    
    wwv_flow_api.create_page_da_action(
        p_id => wwv_flow_api.id(5),
        p_event_id => wwv_flow_api.id(4),
        p_event_result => 'TRUE',
        p_action_sequence => 10,
        p_execute_on_page_init => 'N',
        p_action => 'NATIVE_JAVASCRIPT_CODE',
        p_attribute_01 => q'[
apex.navigation.redirect('f?p=&APP_ID.:2:&SESSION.');]'
    );
end;
/

-- Page CSS
begin
    wwv_flow_api.create_page_plug(
        p_id => wwv_flow_api.id(6),
        p_plug_name => 'Emotion Check-in CSS',
        p_region_template_id => wwv_flow_api.id(1),
        p_display_sequence => 1,
        p_plug_source => q'[
<style>
.emotion-card:hover {
    transform: translateY(-5px) !important;
    box-shadow: 0 8px 15px rgba(0,0,0,0.2) !important;
}

.emotion-card.selected {
    transform: scale(1.05) !important;
    box-shadow: 0 8px 15px rgba(0,0,0,0.2) !important;
}

.intensity-btn:hover {
    transform: scale(1.1);
    border-color: #667eea !important;
}

.btn {
    border: none;
    border-radius: 25px;
    font-weight: 500;
    transition: all 0.3s;
}

.btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.2);
}

@media (max-width: 768px) {
    .emotion-grid {
        grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)) !important;
        gap: 15px !important;
    }
    
    .emotion-card {
        padding: 20px !important;
    }
    
    .emotion-card i {
        font-size: 2rem !important;
    }
    
    .intensity-buttons {
        gap: 10px !important;
    }
    
    .intensity-btn {
        width: 35px !important;
        height: 35px !important;
        font-size: 0.9rem !important;
    }
}
</style>]',
        p_plug_source_type => 'STATIC_TEXT'
    );
end;
/

PROMPT Emotion Check-in page created successfully!