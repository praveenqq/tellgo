import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Payment WebView Screen for handling MyFatoorah payment
/// 
/// This screen displays the payment URL in a WebView and handles
/// the redirect callback to extract the transactionId
class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String? transactionId;
  final Function(String transactionId)? onPaymentComplete;
  /// Callback to extract payment status from the callback URL
  final Function(String status)? onStatusExtracted;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    this.transactionId,
    this.onPaymentComplete,
    this.onStatusExtracted,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  bool _callbackHandled = false; // Flag to prevent duplicate callback handling

  // Callback URL pattern - adjust based on your backend configuration
  // Common patterns: your-app://payment-callback, https://yourapp.com/payment-callback
  static const String callbackUrlPattern = 'ProcessTransaction';
  static const String transactionIdParam = 'transactionId';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
            
            // Check if this is the callback URL
            if (_isCallbackUrl(url)) {
              _handleCallbackUrl(url);
            }
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            // Also check on page finish in case navigation happened
            if (_isCallbackUrl(url)) {
              _handleCallbackUrl(url);
            }
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _error = error.description;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Check if navigation is to callback URL
            if (_isCallbackUrl(request.url)) {
              _handleCallbackUrl(request.url);
              return NavigationDecision.prevent; // Prevent navigation, handle it ourselves
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_ensureHttps(widget.paymentUrl)));
  }

  /// Ensure URL uses HTTPS instead of HTTP
  String _ensureHttps(String url) {
    if (url.toLowerCase().startsWith('http://')) {
      return 'https://${url.substring(7)}';
    }
    return url;
  }

  bool _isCallbackUrl(String url) {
    try {
      final uri = Uri.parse(url);
      // Check if URL contains the callback pattern
      final isCallback = uri.toString().contains(callbackUrlPattern) ||
          uri.queryParameters.containsKey(transactionIdParam);
      
      if (kDebugMode) {
        debugPrint('🔍 Checking URL for callback: $url');
        debugPrint('🔍 Query params: ${uri.queryParameters}');
        debugPrint('🔍 Is callback URL: $isCallback');
      }
      
      return isCallback;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error checking callback URL: $e');
      }
      return false;
    }
  }

  void _handleCallbackUrl(String url) {
    // Prevent duplicate handling
    if (_callbackHandled) {
      if (kDebugMode) {
        debugPrint('⚠️ Callback already handled, ignoring duplicate');
      }
      return;
    }
    _callbackHandled = true;
    
    if (kDebugMode) {
      debugPrint('🎯 Callback URL detected: $url');
    }
    
    try {
      final uri = Uri.parse(url);
      final transactionId = uri.queryParameters[transactionIdParam] ??
          uri.queryParameters['transaction_id'] ??
          uri.queryParameters['TransactionId'] ??
          widget.transactionId;

      // Extract payment status from callback URL
      final status = uri.queryParameters['status'] ??
          uri.queryParameters['Status'] ??
          uri.queryParameters['paymentStatus'];
      
      if (kDebugMode) {
        debugPrint('📋 Extracted transactionId: $transactionId');
        debugPrint('📋 Extracted status: $status');
        debugPrint('📋 Widget transactionId (fallback): ${widget.transactionId}');
      }

      // Notify about the extracted status
      if (status != null && status.isNotEmpty) {
        widget.onStatusExtracted?.call(status);
      }

      if (transactionId != null && transactionId.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('✅ Valid transactionId found, calling onPaymentComplete');
        }
        
        // Call the callback with the transaction ID
        widget.onPaymentComplete?.call(transactionId);
        
        // Close the screen after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop(transactionId);
          }
        });
      } else {
        // If no transactionId found, show error
        if (kDebugMode) {
          debugPrint('⚠️ No transactionId found in callback URL');
        }
        _callbackHandled = false; // Reset flag so user can retry
        setState(() {
          _error = 'Transaction ID not found in callback URL';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error parsing callback URL: $e');
      }
      _callbackHandled = false; // Reset flag so user can retry
      setState(() {
        _error = 'Error parsing callback URL: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Show confirmation dialog before closing
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Cancel Payment?'),
                content: const Text('Are you sure you want to cancel this payment?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Close payment screen
                    },
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Payment Error',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                          _isLoading = true;
                        });
                        _controller.reload();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading && _error == null)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

