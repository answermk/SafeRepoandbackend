import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {
  bool _textToSpeech = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTextToSpeechSetting();
  }

  Future<void> _loadTextToSpeechSetting() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Text-to-speech is stored separately as it's not part of the main settings
      // For now, we'll load it from SharedPreferences
      // TODO: Add text-to-speech to AppSettingsProvider if needed
    } catch (e) {
      print('Error loading text-to-speech setting: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveTextToSpeechSetting() async {
    // Save text-to-speech setting
    // TODO: Add to AppSettingsProvider if needed
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettingsProvider>(
      builder: (context, appSettings, _) {
        final fontSize = appSettings.fontSize;
        final isDarkMode = appSettings.isDarkMode;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Accessibility Settings',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize + 2,
              ),
            ),
            backgroundColor: const Color(0xFF36599F),
            foregroundColor: Colors.white,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(24.0 * (fontSize / 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Card
                    Container(
                      padding: EdgeInsets.all(16 * (fontSize / 16)),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.accessibility_new, color: Color(0xFF36599F)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Customize the app to make it easier to use',
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Font Size Section
                    Text(
                      'Font Size',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize + 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: [
                          Slider(
                            value: fontSize,
                            min: 12,
                            max: 28,
                            divisions: 16,
                            label: '${fontSize.toInt()} px',
                            onChanged: (val) {
                              appSettings.setFontSize(val);
                            },
                            activeColor: const Color(0xFF36599F),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Small (12px)',
                                style: TextStyle(fontSize: fontSize - 2),
                              ),
                              Text(
                                'Large (28px)',
                                style: TextStyle(fontSize: fontSize - 2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Preview text
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Preview: This is how text will appear',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Dark Mode
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SwitchListTile(
                        value: isDarkMode,
                        onChanged: (val) {
                          appSettings.setDarkMode(val);
                        },
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                        subtitle: Text(
                          'Switch to dark theme for better visibility in low light',
                          style: TextStyle(fontSize: fontSize - 2),
                        ),
                        activeColor: const Color(0xFF36599F),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Text-to-Speech
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SwitchListTile(
                        value: _textToSpeech,
                        onChanged: (val) {
                          setState(() => _textToSpeech = val);
                          _saveTextToSpeechSetting();
                          if (val) {
                            _speakText('Text to speech enabled');
                          }
                        },
                        title: Text(
                          'Enable Text-to-Speech',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        ),
                        subtitle: Text(
                          'Reads text aloud when enabled',
                          style: TextStyle(fontSize: fontSize - 2),
                        ),
                        activeColor: const Color(0xFF36599F),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Settings are saved automatically',
                              style: TextStyle(
                                fontSize: fontSize - 2,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        );
      },
    );
  }

  void _speakText(String text) {
    // TODO: Implement text-to-speech functionality
    // Example with flutter_tts package:
    /*
    final FlutterTts flutterTts = FlutterTts();
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
    */
    print('Text-to-speech: $text');
  }
}