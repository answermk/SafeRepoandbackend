import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safereport_mobo/l10n/app_localizations.dart';
import '../services/language_service.dart';
import '../utils/language_controller.dart';
import '../controllers/language_controller_state.dart';

class MultiLanguageScreen extends StatefulWidget {
  const MultiLanguageScreen({Key? key}) : super(key: key);

  @override
  State<MultiLanguageScreen> createState() => _MultiLanguageScreenState();
}

class _MultiLanguageScreenState extends State<MultiLanguageScreen> {
  String? _selectedLanguageCode;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentCode = await LanguageService.getSavedLanguage();
      setState(() {
        _selectedLanguageCode = currentCode;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _selectedLanguageCode = 'en';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLanguage() async {
    if (_selectedLanguageCode == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Get language controller from provider
      final languageController = Provider.of<LanguageControllerState>(context, listen: false);
      
      // Change language using controller
      final result = await languageController.changeLanguage(_selectedLanguageCode!);

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)?.saveLanguage ?? 'Language saved successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Restart app to apply language change
          // Note: In a production app, you might want to use a state management solution
          // that allows hot reloading of locale without restart
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['error'] ?? 'Failed to save language',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final allLanguages = LanguageService.getAllLanguages();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations?.appLanguageTitle ?? 'App Language',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF36599F),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    localizations?.selectYourPreferredLanguage ?? 'Select your preferred language:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: allLanguages.entries.map((entry) {
                        final languageCode = entry.key;
                        final languageName = entry.value;
                        final isSelected = _selectedLanguageCode == languageCode;

                        return RadioListTile<String>(
                          value: languageCode,
                          groupValue: _selectedLanguageCode,
                          onChanged: (val) {
                            setState(() {
                              _selectedLanguageCode = val;
                            });
                          },
                          title: Text(
                            languageName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF36599F) : null,
                            ),
                          ),
                          activeColor: const Color(0xFF36599F),
                          selected: isSelected,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveLanguage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF36599F),
                      minimumSize: const Size.fromHeight(48),
                      disabledBackgroundColor: Colors.grey,
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
                            localizations?.saveLanguage ?? 'Save Language',
                            style: const TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
