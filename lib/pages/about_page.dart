import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:naseej/core/constant/links.dart';
import '../l10n/generated/app_localizations.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutCreator),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 40),

            // Profile Image
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage("images/profile.jpg"),
              backgroundColor: Colors.transparent,
            ),

            SizedBox(height: 20),
            Text(
              l10n.myName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 10),
            Text(
              l10n.subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(FontAwesomeIcons.linkedin, linkedinUrl, context),
                SizedBox(width: 20),
                _buildSocialIcon(FontAwesomeIcons.globe, websiteUrl, context),
                SizedBox(width: 20),
                _buildSocialIcon(FontAwesomeIcons.whatsapp, whatsappUrl, context),
                SizedBox(width: 20),
                _buildSocialIcon(FontAwesomeIcons.envelope, gmailUrl, context),
              ],
            ),

            SizedBox(height: 30),

            // About App Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                  l10n.aboutThisApp,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    l10n.appDescription,
                    style: TextStyle(height: 1.5),
                  ),
                  SizedBox(height: 10),
                  _buildFeatureItem("${l10n.feature1}"),
                  _buildFeatureItem("${l10n.feature2}"),
                  _buildFeatureItem("${l10n.feature3}"),
                  _buildFeatureItem("${l10n.feature4}"),
                  _buildFeatureItem("${l10n.feature5}"),
                ],
              ),
            ),

            SizedBox(height: 30),

            // Contact Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.code,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    l10n.madeWith,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Feature List Item
  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, height: 1.4),
      ),
    );
  }

  // 🔹 Social Icon Widget with Hyperlink
  Widget _buildSocialIcon(IconData icon, String url, BuildContext context) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: FaIcon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 26,
        ),
      ),
    );
  }

  // 🔹 Open URL using url_launcher
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("Could not launch $url");
    }
  }
}
