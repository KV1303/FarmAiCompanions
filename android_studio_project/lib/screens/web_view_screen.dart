import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../constants/app_colors.dart';

class WebViewScreen extends StatefulWidget {
  final String initialUrl;
  final String title;
  final bool isLocalHtml;

  const WebViewScreen({
    Key? key,
    required this.initialUrl,
    required this.title,
    this.isLocalHtml = false,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _isOffline = false;
  bool _hasError = false;
  String _errorMessage = '';
  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    // Initialize connectivity checking
    _checkConnectivity();
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          _isOffline = true;
        });
      } else {
        setState(() {
          _isOffline = false;
        });
        _reloadWebView();
      }
    });

    // Set up WebView controller
    _setupWebViewController();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _setupWebViewController() {
    final WebViewController controller = WebViewController();
    
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
            if (progress < 100) {
              setState(() {
                _isLoading = true;
              });
            } else {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Error: ${error.description}';
              _isLoading = false;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (JavaScriptMessage message) {
          // Handle messages from webview
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      );

    if (widget.isLocalHtml) {
      // Load local HTML
      controller.loadHtmlString(_getLocalHtml());
    } else {
      // Load remote URL
      controller.loadRequest(Uri.parse(widget.initialUrl));
    }

    _webViewController = controller;
  }

  String _getLocalHtml() {
    // In a real implementation, you would load your HTML file from assets
    // For now, we'll use a placeholder
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>FarmAssist AI</title>
      <style>
        body { 
          font-family: 'Roboto', sans-serif; 
          margin: 0; 
          padding: 20px; 
          background-color: #f5f5f5;
        }
        h1 { color: #2e7d32; }
      </style>
    </head>
    <body>
      <h1>FarmAssist AI</h1>
      <p>Loading local content...</p>
    </body>
    </html>
    ''';
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isOffline = connectivityResult == ConnectivityResult.none;
    });
  }

  void _reloadWebView() {
    if (!_isOffline && _webViewController != null) {
      _webViewController.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadWebView,
          ),
        ],
      ),
      body: _isOffline
          ? _buildOfflineUI()
          : _hasError
              ? _buildErrorUI()
              : Stack(
                  children: [
                    WebViewWidget(controller: _webViewController),
                    if (_isLoading)
                      Container(
                        color: Colors.white,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildOfflineUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'आप ऑफलाइन हैं',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('पुनः प्रयास करें'),
            onPressed: () {
              _checkConnectivity();
              if (!_isOffline) {
                _reloadWebView();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'कुछ गलत हो गया',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('पुनः प्रयास करें'),
            onPressed: _reloadWebView,
          ),
        ],
      ),
    );
  }
}