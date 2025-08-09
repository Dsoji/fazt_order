import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Provider for managing WebViewController state

final logger = Logger();

class FaztWebViewScreen extends HookConsumerWidget {
  final String uri;
  final String? title;
  const FaztWebViewScreen({
    super.key,
    required this.uri,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useMemoized(() => WebViewController());

    useEffect(() {
      controller.loadRequest(Uri.parse(uri));
      return null;
    }, [uri]);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          title ?? 'Customer Support',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: WebViewStack(controller: controller),
    );
  }
}

//

class WebViewStack extends HookConsumerWidget {
  const WebViewStack({required this.controller, super.key});

  final WebViewController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingPercentage = useState<int>(0);
    final isLoading = useState(true);
    final hasError = useState(false);
    final currentUrl = useState<String>("");

    useEffect(() {
      controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            loadingPercentage.value = 0;
            currentUrl.value = url; // Update state with new URL
            debugPrint("🔄 Navigating to: $url");

            if (url.contains('dev.com')) {
              debugPrint("🚨 Blocked navigation to dev.com, closing WebView");
              if (context.mounted) Navigator.pop(context);
            }
          },
          onProgress: (progress) {
            loadingPercentage.value = progress;
          },
          onPageFinished: (url) {
            loadingPercentage.value = 100;
            debugPrint("✅ Finished loading: $url");
            final uri = Uri.parse(url);
            final txRef = uri.queryParameters['tx_ref'];
            final transactionId = uri.queryParameters['transaction_id'];
            logger.d("tx_ref: $txRef, transaction_id: $transactionId");
            if (txRef != null && transactionId != null) {
              // ref.read(verifyPaymentsProvider(txRef));
            }
            if (url.contains('dev.com')) {
              debugPrint("🚨 Blocked navigation to dev.com, closing WebView");
              if (context.mounted) Navigator.pop(context);
            }
          },
          onNavigationRequest: (navigation) {
            final host = Uri.parse(navigation.url).host;
            debugPrint("🔍 Navigation request to: ${navigation.url}");

            // Block specific sites
            if (host.contains('dev.com')) {
              debugPrint("🚨 Blocked navigation to dev.com");
              Navigator.pop(context);
              return NavigationDecision.prevent;
            }

            if (host.contains('youtube.com')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Blocking navigation to $host'),
                ),
              );
              debugPrint("🚨 Blocked navigation to YouTube");
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            hasError.value = true;
            isLoading.value = false;
            debugPrint("❌ Web resource error: ${error.description}");
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) Navigator.pop(context);
            });
          },
        ),
      );

      controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      controller.addJavaScriptChannel(
        'SnackBar',
        onMessageReceived: (message) {
          debugPrint('Message received: ${message.message}');
        },
      );

      return null; // Proper cleanup
    }, [
      controller
    ]); // Depend on controller to avoid multiple re-initializations

    return Stack(
      children: [
        WebViewWidget(controller: controller),
        if (loadingPercentage.value < 100)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey.shade400,
              value: loadingPercentage.value / 100.0,
            ),
          ),
      ],
    );
  }
}
