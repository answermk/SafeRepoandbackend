import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {
  double _fontSize = 16;
  bool _highContrast = false;
  bool _textToSpeech = false;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAccessibilitySettings();
  }

  Future<void> _loadAccessibilitySettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _fontSize = prefs.getDouble('accessibility_font_size') ?? 16.0;
        _highContrast = prefs.getBool('accessibility_high_contrast') ?? false;
        _textToSpeech = prefs.getBool('accessibility_text_to_speech') ?? false;
      });
    } catch (e) {
      print('Error loading accessibility settings: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAccessibilitySettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('accessibility_font_size', _fontSize);
      await prefs.setBool('accessibility_high_contrast', _highContrast);
      await prefs.setBool('accessibility_text_to_speech', _textToSpeech);

      // TODO: Also save to backend when available
      /*
      await UserService.updateAccessibilitySettings({
        'fontSize': _fontSize,
        'highContrast': _highContrast,
        'textToSpeech': _textToSpeech,
      });
      */

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Accessibility settings saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Apply high contrast theme if enabled
    final theme = _highContrast
        ? ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.white,
            scaffoldBackgroundColor: Colors.black,
            colorScheme: const ColorScheme.dark(
              primary: Colors.white,
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
          )
        : Theme.of(context);

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Accessibility Settings',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _fontSize + 2,
            ),
          ),
          backgroundColor: const Color(0xFF36599F),
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(24.0 * (_fontSize / 16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Card
                    Container(
                      padding: EdgeInsets.all(16 * (_fontSize / 16)),
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
                                fontSize: _fontSize,
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
                        fontSize: _fontSize + 2,
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
                            value: _fontSize,
                            min: 12,
                            max: 28,
                            divisions: 16,
                            label: '${_fontSize.toInt()} px',
                            onChanged: (val) {
                              setState(() => _fontSize = val);
                              // Auto-save font size changes
                              _saveAccessibilitySettings();
                            },
                            activeColor: const Color(0xFF36599F),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Small (12px)',
                                style: TextStyle(fontSize: _fontSize - 2),
                              ),
                              Text(
                                'Large (28px)',
                                style: TextStyle(fontSize: _fontSize - 2),
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
                              style: TextStyle(fontSize: _fontSize),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // High Contrast Mode
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SwitchListTile(
                        value: _highContrast,
                        onChanged: (val) {
                          setState(() => _highContrast = val);
                          _saveAccessibilitySettings();
                        },
                        title: Text(
                          'High Contrast Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _fontSize,
                          ),
                        ),
                        subtitle: Text(
                          'Increases contrast for better visibility',
                          style: TextStyle(fontSize: _fontSize - 2),
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
                          _saveAccessibilitySettings();
                          if (val) {
                            _speakText('Text to speech enabled');
                          }
                        },
                        title: Text(
                          'Enable Text-to-Speech',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: _fontSize,
                          ),
                        ),
                        subtitle: Text(
                          'Reads text aloud when enabled',
                          style: TextStyle(fontSize: _fontSize - 2),
                        ),
                        activeColor: const Color(0xFF36599F),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveAccessibilitySettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF36599F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Save Settings',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: _fontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
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