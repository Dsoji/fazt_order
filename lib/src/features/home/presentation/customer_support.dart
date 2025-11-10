import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Provider for managing WebViewController state
class CustomerSupportWebViewScreen extends HookConsumerWidget {
  final String uri;
  const CustomerSupportWebViewScreen({
    super.key,
    required this.uri,
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
          icon: const Icon(
            Icons.arrow_back,
            size: 20,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Customer Support',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
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

    useEffect(() {
      controller.setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            loadingPercentage.value = 0;
          },
          onProgress: (progress) {
            loadingPercentage.value = progress;
          },
          onPageFinished: (url) {
            loadingPercentage.value = 100;
          },
          onNavigationRequest: (navigation) {
            final host = Uri.parse(navigation.url).host;

            // Block navigation to specific URLs
            if (host.contains('dev.com')) {
              Navigator.pop(context);

              return NavigationDecision.prevent;
            }

            if (host.contains('youtube.com')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Blocking navigation to $host'),
                ),
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
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
