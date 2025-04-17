// English translations
final Map<String, String> enTranslations = {
  // General
  'app_name': 'Headphone App',

  // Language Demo
  'language_demo_title': 'Language Demo',
  'sample_text':
      'This is a sample text that will be displayed in the selected language.',
  'greeting': 'Hello, welcome to our app!',

  // Navigation
  'nav_hearing_test': 'Hearing Test',
  'nav_presets': 'Presets',
  'nav_settings': 'Settings',

  // Settings Page
  'settings': 'Settings',
  'app_settings': 'App Settings',
  'app_theme': 'App Theme',
  'dark_mode': 'Dark Mode',
  'light_mode': 'Light Mode',
  'language': 'Language',
  'english': 'English',
  'french': 'French',
  'select_theme': 'Select Theme',
  'select_language': 'Select Language',
  'apply': 'Apply',
  'cancel': 'Cancel',
  'theme_changed': 'Theme changed to',
  'language_changed': 'Language changed to',

  // FAQ Section
  'faq': 'Frequently Asked Questions',
  'faq_clean': 'What do the values on the audiogram mean?',
  'faq_clean_answer':
      'The audiogram shows your hearing thresholds measured in dB HL (Hearing Level). During testing, sounds are played at different dB SPL (Sound Pressure Level) values, which are then converted to dB HL using standard reference values. The dB HL scale is used by audiologists where 0-20 dB represents normal hearing, 20-40 dB mild loss, 40-70 dB moderate loss, 70-90 dB severe loss, and >90 dB profound loss.',
  'faq_adjust': 'How can I adjust the settings on my headphones?',
  'faq_adjust_answer':
      'Connect your headphones via Bluetooth, then go to the Presets tab. You can adjust volume levels, bass, mid, and treble frequencies, and enable features like background noise reduction. Changes are sent to your headphones when you apply a preset.',
  'faq_test': 'How can I perform a hearing test?',
  'faq_test_answer':
      'Go to the Hearing Test tab and tap BEGIN SOUND TEST. You\'ll hear sounds at different frequencies that gradually get louder. Tap the button as soon as you hear each sound. The test evaluates both ears and creates a personalized preset based on your hearing profile that can be applied to your headphones.',
  'faq_multiple': 'Can I save multiple hearing test results?',
  'faq_multiple_answer':
      'You can perform the hearing test multiple times, but the app only saves your most recent test result. Each new test will replace your previous test result. This allows you to update your hearing profile as needed, but the app doesn\'t maintain a history of past test results. Each test evaluates both ears across different frequencies (250Hz, 500Hz, 1kHz, 2kHz, and 4kHz) and displays these results in your audiogram.',

  // About
  'about': 'About',
  'app_version': 'App Version',
  'app_description':
      'A mobile application for controlling headphone settings via Bluetooth.',

  // Preset Page
  'edit_preset': 'Edit Preset',
  'preset_name': 'Preset Name',
  'overall_volume': 'Overall Volume',
  'softer': 'Softer',
  'louder': 'Louder',
  'sound_balance': 'Sound Balance',
  'bass': 'Bass',
  'bass_description':
      'Enhances low frequencies like bass drums and deep voices',
  'mid': 'Mid',
  'mid_description': 'Enhances vocals and most speech frequencies',
  'treble': 'Treble',
  'treble_description':
      'Enhances high frequencies like cymbals and consonant sounds',
  'sound_enhancement': 'Sound Enhancement',
  'reduce_background_noise': 'Reduce Background Noise',
  'reduce_background_noise_description': 'Minimizes constant background sounds',
  'reduce_wind_noise': 'Reduce Wind Noise',
  'reduce_wind_noise_description': 'Helps in outdoor environments',
  'soften_sudden_sounds': 'Soften Sudden Sounds',
  'soften_sudden_sounds_description': 'Reduces unexpected loud noises',
  'updated': 'updated',
  'successfully_updated': 'Successfully Updated!',
  'updating': 'Updating',
  'value_is_saved': 'Value is saved',

  // Presets List Page
  'no_presets': 'No presets available. Create a new preset to get started.',
  'edit': 'Edit',
  'delete': 'Delete',
  'confirm_delete': 'Confirm Delete',
  'confirm_delete_message': 'Are you sure you want to delete',
  'deleted_successfully': 'deleted successfully!',
  'sent_to_device': 'Successfully sent to device!',
  'preset_applied': 'applied successfully!',
  'presets_count': 'Presets:',
  'max_presets': 'You can only have a maximum of 10 presets!',

  // Sound Test Page
  'sound_test': 'Sound Test',
  'hearing_test': 'Hearing Test',
  'begin_sound_test': 'BEGIN SOUND TEST',
  'some_instructions_before_starting':
      'Some instructions before starting the test:',
  'sit_in_quiet_environment': 'Sit in a quiet environment.',
  'set_max_volume': 'Set your device volume to maximum.',
  'wear_headphones_properly':
      'Wear your headphones correctly and comfortably so that it completely fits in your ears.',
  'test_duration_minutes': 'This will take only take ~5 minutes',
  'instructions': 'A few instructions before starting the test:',
  'audio_profiles': 'Audio Profiles:',
  'max_profiles': 'You can only have a maximum of 3 audio profiles!',
  'successfully_applied': 'Successfully Applied!',
  'retake_test': 'Retake Test',
  'reset_to_baseline': 'Reset to Baseline',
  'reset_successful': 'Reset successful',

  // Test Page - New additions
  'hearing_test_in_progress': 'Hearing Test In Progress',
  'prepare_for_hearing_test': 'Prepare for Hearing Test',
  'test_instructions': 'Find a quiet place for this test.\n\n'
      'How the test works:\n'
      '1. You will hear tones in each ear at different frequencies\n'
      '2. Press "I can hear it!" when you first hear a sound\n'
      '3. The volume will decrease and you should keep pressing "I can hear it!" until you can\'t hear it anymore\n'
      '4. When you can\'t hear the sound anymore, press "I cannot hear it!"\n'
      '5. If you press "I cannot hear it!" and then hear it again, press "I can hear it!"\n'
      '6. This will record your hearing threshold for that frequency\n'
      '7. The test will automatically move to the next frequency\n'
      '8. This process repeats for all frequencies in both ears',
  'start_test': 'Start Test',
  'i_can_hear_it': 'I can hear it!',
  'i_cannot_hear_it': 'I cannot hear it!',
  'no_bluetooth': 'No Bluetooth',
  'test_complete': 'Test Complete',
  'test_complete_message': 'Your hearing test has been completed and saved.',
  'testing_sound_playback':
      'Testing sound playback - you should hear a 1kHz tone',
  'error_testing_audio': 'Error testing audio:',
  'cancel_test': 'Cancel Test?',
  'cancel_test_message':
      'Are you sure you want to cancel the hearing test? Your progress will be lost.',
  'no_continue_test': 'No, Continue Test',
  'yes_cancel': 'Yes, Cancel',
  'welcome_hearing_test': 'Welcome to the Hearing Test',
  'take_hearing_test_message': 'Take a hearing test to see your audiogram.',
  'bluetooth_warning':
      'Please connect Bluetooth headphones for accurate test results',
  'ok': 'OK',
  'your_audiogram': 'Your Audiogram',
  'audiogram_description':
      'The audiogram below shows your hearing threshold at different frequencies. Each point represents the softest sound you can hear at that frequency.',
  'test_completed': 'Test Completed',
  'test_completed_message':
      'Your hearing test has been completed successfully. The results have been saved.',
  'values_saved': 'Values Saved',
  'values_saved_message': 'Your test values have been saved successfully.',
  'confirm_reset': 'Confirm Reset',
  'confirm_reset_message': 'Are you sure you want to reset to default values?',
  'reset': 'Reset',
  'audio_profile': 'Audio Profile',
  'default_audio_profile': 'Default Audio Profile',
  'left_ear': 'Left Ear',
  'right_ear': 'Right Ear',
  'test_results_saved': 'Test results saved successfully',

  // Audiogram labels
  'frequency': 'Frequency (Hz)',
  'hearing_level': 'Hearing Level',
  'normal_hearing': 'Normal',
  'mild_loss': 'Mild',
  'moderate_loss': 'Moderate',
  'severe_loss': 'Severe',
  'profound_loss': 'Profound Loss (>90 dB)',

  // Add new translations for Bluetooth file sharing
  'share_via_bluetooth': 'Send to Device',
  'file_sent_successfully': 'Hearing test file prepared for sharing',
  'file_send_failed': 'Failed to prepare hearing test file',

  // New translations for preset sharing
  'share_preset': 'Share Preset',
  'preset_prepared_for_sharing': 'Preset prepared for sharing',
  'preset_share_failed': 'Failed to prepare preset file',

  // Combined hearing test and preset sharing
  'no_active_sound_test':
      'No active hearing test available. Please complete a hearing test first.',
  'combined_data_prepared_for_sharing':
      'Hearing profile with preset settings prepared for sharing',
  'combined_data_share_failed': 'Failed to prepare combined hearing profile',

  // Demo Reset
  'demo_reset': 'Demo Reset',
  'demo_reset_description': 'Reset app for demonstration',
  'demo_reset_confirmation': 'Reset App for Demo?',
  'demo_reset_message':
      'This will clear all hearing tests and presets. This action cannot be undone.',
  'demo_reset_success': 'App has been reset for demonstration',

  // Hearing test toast notifications
  'press_hear_to_confirm':
      'Press "I can hear it" if you can hear the tone to confirm your threshold.',
  'threshold_for_ear':
      'Threshold for {ear} ear at {frequency}Hz: {db_hl} dB HL ({db_spl} dB SPL)',
  'left': 'Left',
  'right': 'Right',
  'value_recorded': 'Value recorded',
  'error_setting_up_audio':
      'Error setting up audio. Please check your earphones connection.',
  'please_connect_bluetooth':
      'Please connect Bluetooth headphones for accurate test results',
  'error_playing_audio': 'Error playing audio. Please check your headphones.',
};
