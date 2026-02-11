import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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
  final ScreenshotController _screenshotController = ScreenshotController();

  bool isLoading = true;
  bool isMicOn = true;
  bool isCameraOn = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  /// ================= INIT =================
  Future<void> _initWebView() async {
    await _requestPermissions();

    _controller =
        WebViewController.fromPlatformCreationParams(_platformParams())
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
              onWebResourceError: (error) {
                debugPrint("❌ WebView error: ${error.description}");
              },
            ),
          );
    _setupAndroidWebView();
    await _controller!.loadRequest(Uri.parse(widget.url));
  }

  /// ================= PERMISSIONS =================
  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.camera.request();

    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.photos.request();
    }
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
      final android = _controller!.platform as AndroidWebViewController;
      android
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnPlatformPermissionRequest((request) => request.grant());
    }
  }

  /// ================= MIC TOGGLE (REAL) =================

  Future<void> _toggleMic() async {
    if (_controller == null) return;

    if (isMicOn) {
      await _controller!.runJavaScript("window.ZMVideo.muteAudio()");
    } else {
      await _controller!.runJavaScript("window.ZMVideo.unmuteAudio()");
    }

    setState(() => isMicOn = !isMicOn);
  }


  /* ---------------- CAMERA ---------------- */

  Future<void> _toggleCamera() async {
    if (_controller == null) return;

    if (isCameraOn) {
      await _controller!.runJavaScript("window.ZMVideo.muteVideo()");
    } else {
      await _controller!.runJavaScript("window.ZMVideo.unmuteVideo()");
    }

    setState(() => isCameraOn = !isCameraOn);
  }


  Future<void> _endCall() async {
    if (_controller == null) return;

    await _controller!.runJavaScript("window.ZMVideo.endCall()");
    if (!mounted) return;
    Navigator.pop(context);
  }



  /// ================= SCREENSHOT =================
  Future<void> _captureScreenshot() async {
    try {
      final Uint8List? image = await _screenshotController.capture(
        delay: const Duration(milliseconds: 300),
      );
      if (image == null) return;

      const MethodChannel channel = MethodChannel('media_store_channel');
      await channel.invokeMethod('saveImage', {
        "bytes": image,
        "fileName": "webview_${DateTime.now().millisecondsSinceEpoch}.png",
        "folder": "Zeromedixine",
      });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Screenshot saved")));
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Screenshot failed")));
    }
  }

  /// ================= WHATSAPP =================
  bool _isWhatsAppUrl(String url) =>
      url.contains("wa.me") ||
      url.contains("whatsapp://") ||
      url.contains("api.whatsapp.com");

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

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // ✅ IMPORTANT
        extendBody: true,
        extendBodyBehindAppBar: true,

        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,

          iconTheme: const IconThemeData(
            color: Colors.white, // 👈 back arrow color
          ),

          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),

        body: Screenshot(
          controller: _screenshotController,
          child: Stack(
            children: [
              /// 🔹 WEBVIEW FULL SCREEN
              Positioned.fill(child: WebViewWidget(controller: _controller!)),

              /// 🔹 LOADING
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),

              /// 🔻 CONTROL BAR (ONLY THIS IS TRANSPARENT)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      // ✅ semi-transparent
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _circleButton(
                          icon: isMicOn ? Icons.mic : Icons.mic_off,
                          color: isMicOn ? Colors.green : Colors.grey,
                          onTap: _toggleMic,
                        ),
                        const SizedBox(width: 15),
                        _circleButton(
                          icon: isCameraOn
                              ? Icons.videocam
                              : Icons.videocam_off,
                          color: isCameraOn ? Colors.blue : Colors.grey,
                          onTap: _toggleCamera,
                        ),
                        const SizedBox(width: 20),
                        _circleButton(
                          icon: Icons.call_end,
                          color: Colors.red,
                          onTap: () async {
                            _endCall();
                          },
                        ),
                        const SizedBox(width: 15),
                        _circleButton(
                          icon: Icons.camera_alt,
                          color: Colors.orange,
                          onTap: _captureScreenshot,
                        ),
                      ],
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
}

/// ================= BUTTON =================
Widget _circleButton({
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white),
    ),
  );
}
