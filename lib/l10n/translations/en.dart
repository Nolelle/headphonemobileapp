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
  'faq_clean': 'How do I clean and maintain my headphones?',
  'faq_clean_answer':
      'Regular cleaning is essential. Use a soft, dry cloth to wipe the exterior daily, and follow the specific cleaning instructions provided in the app. We also recommend scheduling professional cleanings every few months.',
  'faq_adjust': 'How can I adjust the settings on my headphones?',
  'faq_adjust_answer':
      'You can adjust your headphone settings through the app. This includes changing the volume, selecting different listening programs. Just go to the equalizer and change according to your environment.',
  'faq_test': 'How can I perform a sound test?',
  'faq_test_answer':
      'The sound test is extremely easy to complete. A sound will be played at different frequencies. And the sound keep getting louder overtime. You have to click the button as soon as you hear the sound. You have to do this for every frequency. You responses will be recorded a preset will be made according to that. You can then use that preset in your headphones.',
  'faq_multiple': 'Can I do more than one test?',
  'faq_multiple_answer':
      'Yes of course! You can do as many Tests as you want, conducting every test creates a new preset in the app, you can then use that preset in your headphones. With this feature, you can use different presets for different environments such as listening to music, or sitting in transit vehicles.',

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

  // Presets List Page
  'no_presets': 'No presets available. Create a new preset to get started.',
  'edit': 'Edit',
  'delete': 'Delete',
  'confirm_delete': 'Confirm Delete',
  'confirm_delete_message': 'Are you sure you want to delete',
  'deleted_successfully': 'deleted successfully!',
  'sent_to_device': 'Successfully sent to device!',
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
  'hearing_level': 'Hearing Level (dB)',
  'normal_hearing': 'Normal',
  'mild_loss': 'Mild',
  'moderate_loss': 'Moderate',
  'severe_loss': 'Severe',
  'profound_loss': 'Profound',
};
