import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'src/features/home/data/controller/shop_controller.dart';
import 'src/features/profile/data/controller/profile_controller.dart';

// Provider for managing WebViewController state

final logger = Logger();

class FaztWebViewScreen extends HookConsumerWidget {
  final String uri;
  final String? title;
  final String? reference;
  const FaztWebViewScreen({
    super.key,
    required this.uri,
    this.title,
    this.reference,
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
            ref
                .read(profileControllerProvider.notifier)
                .verifyPayment(paymentId: reference ?? '');

            ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
            ref.read(shopControllerProvider.notifier).fetchCart();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          title ?? 'Payment',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: WebViewStack(
        controller: controller,
        reference: reference,
        title: title,
      ),
    );
  }
}

//

class WebViewStack extends HookConsumerWidget {
  const WebViewStack(
      {required this.controller, this.reference, super.key, this.title});

  final WebViewController controller;
  final String? reference;
  final String? title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingPercentage = useState<int>(0);
    final isLoading = useState(true);
    final hasError = useState(false);
    final currentUrl = useState<String>("");
    logger.d("title: $title");

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
              if (context.mounted) {
                if (title == 'Parcel Payment') {
                  ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
                  ref.read(shopControllerProvider.notifier).fetchCart();
                  ref
                      .read(profileControllerProvider.notifier)
                      .verifyPayment(paymentId: reference ?? '');
                  Navigator.pop(context);
                  Navigator.pop(context);
                  logger.d("Lalalalalalalal");
                } else {
                  ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
                  ref.read(shopControllerProvider.notifier).fetchCart();
                  ref
                      .read(profileControllerProvider.notifier)
                      .verifyPayment(paymentId: reference ?? '');
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  logger.d("zeeeeeee");
                }
              }
            }
          },
          onNavigationRequest: (navigation) {
            final host = Uri.parse(navigation.url).host;
            debugPrint("🔍 Navigation request to: ${navigation.url}");

            // Block specific sites
            if (host.contains('dev.com')) {
              debugPrint("🚨 Blocked navigation to dev.com");
              if (context.mounted) {
                if (title == 'Parcel Payment') {
                  ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
                  ref.read(shopControllerProvider.notifier).fetchCart();
                  ref
                      .read(profileControllerProvider.notifier)
                      .verifyPayment(paymentId: reference ?? '');
                  Navigator.pop(context);
                  Navigator.pop(context);
                  logger.d("Lalalalalalalal");
                } else {
                  ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
                  ref.read(shopControllerProvider.notifier).fetchCart();
                  ref
                      .read(profileControllerProvider.notifier)
                      .verifyPayment(paymentId: reference ?? '');
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  logger.d("zeeeeeee");
                }
              }
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
              if (title == 'Parcel Payment') {
                ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
                ref.read(shopControllerProvider.notifier).fetchCart();
                ref
                    .read(profileControllerProvider.notifier)
                    .verifyPayment(paymentId: reference ?? '');
                Navigator.pop(context);
                Navigator.pop(context);
                logger.d("Lalalalalalalal");
              } else {
                ref.read(shopControllerProvider.notifier).fetchMyOrdersList();
                ref.read(shopControllerProvider.notifier).fetchCart();
                ref
                    .read(profileControllerProvider.notifier)
                    .verifyPayment(paymentId: reference ?? '');
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                logger.d("zeeeeeee");
              }
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
