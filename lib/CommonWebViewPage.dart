import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';


class CommonWebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const CommonWebViewPage({
    super.key,
    required this.url,
    this.title = "Video Call",
  });

  @override
  State<CommonWebViewPage> createState() => _CommonWebViewPageState();
}

class _CommonWebViewPageState extends State<CommonWebViewPage> {
  WebViewController? _controller;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  /// 🔥 INIT
  Future<void> _initWebView() async {
    final cam = await Permission.camera.request();
    final mic = await Permission.microphone.request();

    if (!cam.isGranted || !mic.isGranted) {
      _showPermissionSettingsDialog();
      return;
    }

    _controller = WebViewController.fromPlatformCreationParams(
      _platformParams(),
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            if (_isWhatsAppUrl(request.url)) {
              await _openWhatsApp(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) => setState(() => isLoading = true),
          onPageFinished: (_) => setState(() => isLoading = false),
        ),
      );

    _setupAndroidWebView();

    await _controller?.loadRequest(Uri.parse(widget.url));
  }

  /// ================= PLATFORM PARAMS =================
  PlatformWebViewControllerCreationParams _platformParams() {
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      return WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const {},
      );
    }
    return const PlatformWebViewControllerCreationParams();
  }

  void _setupAndroidWebView() {
    if (_controller?.platform is AndroidWebViewController) {
      final android = _controller?.platform as AndroidWebViewController;

      android
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnPlatformPermissionRequest(
              (request) => request.grant(),
        );
    }
  }

  /// ================= PERMISSION DIALOG =================
  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Camera and Microphone permission are required for video calls.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  /// ================= WHATSAPP =================
  bool _isWhatsAppUrl(String url) {
    return url.contains("wa.me") ||
        url.contains("whatsapp://") ||
        url.contains("api.whatsapp.com");
  }

  Future<void> _openWhatsApp(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// ================= BACK =================
  Future<bool> _onWillPop() async {
    if (_controller != null && await _controller!.canGoBack()) {
      await _controller!.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Stack(
          children: [
            if (_controller != null)
              WebViewWidget(controller: _controller!)
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            if (isLoading && _controller != null)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

}


