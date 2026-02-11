import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'terms_html.dart';

class TermsWebViewPage extends StatefulWidget {
  const TermsWebViewPage({super.key});

  @override
  State<TermsWebViewPage> createState() => _TermsWebViewPageState();
}

class _TermsWebViewPageState extends State<TermsWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(termsHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Refund Policy'),
        backgroundColor: const Color(0xFF0A6E6A),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
