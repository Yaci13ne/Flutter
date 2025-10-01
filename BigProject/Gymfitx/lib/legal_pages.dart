import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Updated: April 19, 2025',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('1. Introduction'),
            const Text(
              'GymfitX ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('2. Information We Collect'),
            _buildBulletPoint('Personal Information: Name, email, age, weight, height'),
            _buildBulletPoint('Health Data: Workout routines, nutrition information'),
            _buildBulletPoint('Usage Data: App interactions, features used'),
            _buildBulletPoint('Device Information: Device type, operating system'),
            const SizedBox(height: 16),
            _buildSectionTitle('3. How We Use Your Information'),
            const Text(
              'We use the information we collect to:\n'
              '- Provide and maintain our service\n'
              '- Personalize your experience\n'
              '- Improve our app\n'
              '- Monitor usage patterns\n'
              '- Provide customer support\n'
              '- Send you updates and promotional materials',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('4. Data Sharing and Disclosure'),
            const Text(
              'We do not sell your personal information. We may share data with:\n'
              '- Service providers who assist in app operations\n'
              '- Legal authorities when required by law\n'
              '- Business partners in anonymized, aggregated form',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('5. Data Security'),
            const Text(
              'We implement appropriate technical and organizational measures to protect your personal data. However, no method of transmission over the Internet is 100% secure.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('6. Your Rights'),
            const Text(
              'You have the right to:\n'
              '- Access your personal data\n'
              '- Request correction of inaccurate data\n'
              '- Request deletion of your data\n'
              '- Object to processing of your data\n'
              '- Request data portability',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('7. Children\'s Privacy'),
            const Text(
              'Our app is not intended for users under 13. We do not knowingly collect personal information from children under 13.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('8. Changes to This Policy'),
            const Text(
              'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('9. Contact Us'),
            const Text(
              'If you have questions about this Privacy Policy, please contact us at privacy@gymfitx.com.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Updated: April 19, 2025',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('1. Acceptance of Terms'),
            const Text(
              'By accessing or using the GymfitX mobile application, you agree to be bound by these Terms of Service. If you do not agree, do not use our app.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('2. Description of Service'),
            const Text(
              'GymfitX provides fitness tracking, nutrition planning, and workout guidance services through our mobile application.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('3. User Accounts'),
            const Text(
              'You must create an account to access certain features. You are responsible for maintaining the confidentiality of your account credentials.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('4. User Responsibilities'),
            const Text(
              'You agree to:\n'
              '- Provide accurate information\n'
              '- Not share your account\n'
              '- Not use the app for illegal purposes\n'
              '- Not attempt to disrupt the service\n'
              '- Comply with all applicable laws',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('5. Health Disclaimer'),
            const Text(
              'The content provided in GymfitX is for informational purposes only and is not medical advice. Consult with a healthcare professional before beginning any fitness or nutrition program.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('6. Intellectual Property'),
            const Text(
              'All content in the app, including text, graphics, logos, and software, is our property or our licensors and is protected by copyright laws.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('7. Subscription and Payments'),
            const Text(
              'Certain features may require payment. You agree to pay all fees and charges associated with your account.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('8. Termination'),
            const Text(
              'We may terminate or suspend your account immediately for violation of these terms without prior notice.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('9. Limitation of Liability'),
            const Text(
              'GymfitX shall not be liable for any indirect, incidental, special, or consequential damages resulting from your use of the app.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('10. Changes to Terms'),
            const Text(
              'We reserve the right to modify these terms at any time. Your continued use constitutes acceptance of the modified terms.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('11. Governing Law'),
            const Text(
              'These terms shall be governed by the laws of the State of California without regard to its conflict of law provisions.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('12. Contact Information'),
            const Text(
              'For questions about these Terms of Service, please contact us at legal@gymfitx.com.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}