import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;

  final String _htmlContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Zeromedixine - Privacy Policy</title>
    <style>
        body {
            font-family: Arial, Helvetica, sans-serif;
            line-height: 1.6;
            background-color: #f9fafb;
            color: #333;
            padding: 20px;
        }
        h1, h2 {
            color: #0a7cff;
        }
        .container {
            max-width: 900px;
            margin: auto;
            background: #ffffff;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        ul {
            margin-left: 20px;
        }
        footer {
            margin-top: 30px;
            font-size: 14px;
            color: #666;
        }
    </style>
</head>
<body>

<div class="container">
    <h1>Privacy Policy</h1>
    <p><strong>Last updated:</strong> January 2026</p>

    <p>
        Zeromedixine ("we", "our", "us") is committed to protecting your privacy.
        This Privacy Policy explains how we collect, use, and safeguard your information
        when you use our mobile application.
    </p>

    <h2>1. Information We Collect</h2>
    <ul>
        <li>Personal details such as name, phone number, and email address</li>
        <li>Patient and doctor profile information</li>
        <li>Appointment and consultation data</li>
        <li>Device information and app usage data</li>
    </ul>

    <h2>2. How We Use Your Information</h2>
    <ul>
        <li>To manage doctor profiles and patient records</li>
        <li>To schedule and manage appointments</li>
        <li>To send notifications and reminders</li>
        <li>To improve app performance and user experience</li>
    </ul>

    <h2>3. Data Security</h2>
    <p>
        We implement industry-standard security measures to protect your data.
        However, no method of transmission over the internet is 100% secure.
    </p>

    <h2>4. Data Sharing</h2>
    <p>
        We do not sell or rent your personal information.
        Data may be shared only with authorized healthcare professionals
        and service providers necessary for app functionality.
    </p>

    <h2>5. User Rights</h2>
    <ul>
        <li>Access and update your personal information</li>
        <li>Request data deletion</li>
        <li>Withdraw consent at any time</li>
    </ul>

    <h2>6. Children’s Privacy</h2>
    <p>
        Zeromedixine does not knowingly collect personal data from children under 13.
        If you believe such data has been collected, please contact us.
    </p>

    <h2>7. Changes to This Policy</h2>
    <p>
        We may update this Privacy Policy from time to time.
        Changes will be reflected on this page.
    </p>

    <h2>8. Contact Us</h2>
    <p>
        If you have any questions about this Privacy Policy, contact us at:
        <br><strong>Email:</strong> support@zeromedixine.com
    </p>

    <footer>
        © 2026 Zeromedixine. All rights reserved.
    </footer>
</div>

</body>
</html>
''';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(_htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
