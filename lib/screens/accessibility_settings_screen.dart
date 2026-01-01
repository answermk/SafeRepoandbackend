import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_settings_provider.dart';
import '../utils/translation_helper.dart';
import '../utils/theme_helper.dart';

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
        final t = TranslationHelper.of(context);

        final scaffoldColor = ThemeHelper.getScaffoldBackgroundColor(context);
        final cardColor = ThemeHelper.getCardColor(context);
        final primaryColor = ThemeHelper.getPrimaryColor(context);
        final textColor = ThemeHelper.getTextColor(context);

        return Scaffold(
          backgroundColor: scaffoldColor,
          appBar: AppBar(
            title: Text(
              t.accessibilitySettingsTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize + 2,
              ),
            ),
            backgroundColor: primaryColor,
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
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: primaryColor.withOpacity(0.25)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.accessibility_new, color: primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                t.accessibilityCustomize,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: ThemeHelper.getSecondaryTextColor(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Font Size Section
                      Text(
                        t.fontSizeLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize + 2,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ThemeHelper.getDividerColor(context)),
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
                              activeColor: primaryColor,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.fontSizeSmall,
                                  style: TextStyle(fontSize: fontSize - 2, color: ThemeHelper.getSecondaryTextColor(context)),
                                ),
                                Text(
                                  t.fontSizeLarge,
                                  style: TextStyle(fontSize: fontSize - 2, color: ThemeHelper.getSecondaryTextColor(context)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Preview text
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: ThemeHelper.getDividerColor(context).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.fontSizePreview,
                                style: TextStyle(fontSize: fontSize, color: textColor),
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
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ThemeHelper.getDividerColor(context)),
                        ),
                        child: SwitchListTile(
                          value: isDarkMode,
                          onChanged: (val) {
                            appSettings.setDarkMode(val);
                          },
                          title: Text(
                            t.darkModeTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            t.darkModeSubtitle,
                            style: TextStyle(fontSize: fontSize - 2, color: ThemeHelper.getSecondaryTextColor(context)),
                          ),
                          activeColor: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Text-to-Speech
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ThemeHelper.getDividerColor(context)),
                        ),
                        child: SwitchListTile(
                          value: _textToSpeech,
                          onChanged: (val) {
                            setState(() => _textToSpeech = val);
                            _saveTextToSpeechSetting();
                            if (val) {
                              _speakText(t.ttsEnabledToast);
                            }
                          },
                          title: Text(
                            t.ttsTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            t.ttsSubtitle,
                            style: TextStyle(fontSize: fontSize - 2, color: ThemeHelper.getSecondaryTextColor(context)),
                          ),
                          activeColor: primaryColor,
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
                                t.settingsSavedAutomatically,
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