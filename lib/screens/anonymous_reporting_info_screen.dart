import 'package:flutter/material.dart';
import '../utils/translation_helper.dart';
import '../utils/theme_helper.dart';
import '../l10n/app_localizations.dart';

class AnonymousReportingInfoScreen extends StatelessWidget {
  const AnonymousReportingInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = TranslationHelper.of(context);
    final scaffold = ThemeHelper.getScaffoldBackgroundColor(context);
    final card = ThemeHelper.getCardColor(context);
    final shadow = ThemeHelper.getShadowColor(context);
    final divider = ThemeHelper.getDividerColor(context);
    final primary = ThemeHelper.getPrimaryColor(context);
    final textColor = ThemeHelper.getTextColor(context);
    final secondary = ThemeHelper.getSecondaryTextColor(context);

    return Scaffold(
      backgroundColor: scaffold,
      appBar: AppBar(
        title: Text(t.anonymousReportingTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(t),
            _buildWhatIsHiddenSection(t, card, shadow, textColor),
            _buildWhatIsSharedSection(t, card, shadow, divider, textColor),
            _buildBenefitsSection(t, card, shadow, primary),
            _buildLegalProtectionSection(t, primary, secondary),
            _buildFAQSection(t, card, shadow, textColor, secondary, primary),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(AppLocalizations t) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.privacy_tip, color: Color(0xFF8B5CF6), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.reportSafely,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.identityProtected,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIsHiddenSection(AppLocalizations t, Color card, Color shadow, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_off, color: Colors.green[700]),
              const SizedBox(width: 8),
              Text(
                t.whatsHiddenTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.person_off, t.hiddenName, Colors.green, textColor),
          _buildInfoItem(Icons.email_outlined, t.hiddenEmail, Colors.green, textColor),
          _buildInfoItem(Icons.phone_disabled, t.hiddenPhone, Colors.green, textColor),
          _buildInfoItem(Icons.account_circle_outlined, t.hiddenAccountId, Colors.green, textColor),
          _buildInfoItem(Icons.fingerprint, t.hiddenPersonalIdentifiers, Colors.green, textColor),
        ],
      ),
    );
  }

  Widget _buildWhatIsSharedSection(AppLocalizations t, Color card, Color shadow, Color divider, Color textColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                t.whatsSharedTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.location_on, t.sharedLocation, Colors.orange, textColor),
          _buildInfoItem(Icons.access_time, t.sharedTime, Colors.orange, textColor),
          _buildInfoItem(Icons.description, t.sharedDescription, Colors.orange, textColor),
          _buildInfoItem(Icons.camera_alt, t.sharedEvidence, Colors.orange, textColor),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: divider),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t.helpsPolice,
                    style: TextStyle(fontSize: 13, color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(AppLocalizations t, Color card, Color shadow, Color primary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: primary),
              const SizedBox(width: 8),
              Text(
                t.benefitsAnonymousTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(t.benefit1),
          _buildBenefitItem(t.benefit2),
          _buildBenefitItem(t.benefit3),
          _buildBenefitItem(t.benefit4),
        ],
      ),
    );
  }

  Widget _buildLegalProtectionSection(AppLocalizations t, Color primary, Color secondary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, color: primary),
              const SizedBox(width: 8),
              Text(
                t.legalProtectionTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            t.legalProtectionText,
            style: TextStyle(fontSize: 14, height: 1.5, color: secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection(AppLocalizations t, Color card, Color shadow, Color textColor, Color secondary, Color primary) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, color: primary),
              const SizedBox(width: 8),
              Text(
                t.faqTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFAQItem(t.faqQ1, t.faqA1, textColor, secondary),
          _buildFAQItem(t.faqQ2, t.faqA2, textColor, secondary),
          _buildFAQItem(t.faqQ3, t.faqA3, textColor, secondary),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 14, color: textColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, Color textColor, Color secondary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: secondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}