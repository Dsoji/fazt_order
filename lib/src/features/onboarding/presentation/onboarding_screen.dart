import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../../common/res/app_assets.dart';
import '../../../common/res/app_colors.dart';

class OnboardingScreen extends HookWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Page Controller
    final pageController = usePageController();
    final currentPage = useState(0);

    useEffect(() {
      pageController.addListener(() {
        currentPage.value = pageController.page?.round() ?? 0;
      });
      return null;
    }, []);

    final pages = [
      {
        "title":
            "Connect with local customers and expand your market reach effortlessly!",
        "image": GifAssets.onboardOne, // Add your asset path here
      },
      {
        "title":
            "Manage orders efficiently with real-time updates and scheduling tools.",
        "image": GifAssets.onboardTwo, // Add your asset path here
      },
      {
        "title":
            "Deliver your products quickly with our reliable logistics support.",
        "image": GifAssets.onboardThree, // Add your asset path here
      },
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppColors.brand200,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: AppColors.brand200, // Dark green background
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 60), // Space for indicator alignment
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(
                    pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentPage.value == index ? 40 : 12,
                      height: 4,
                      decoration: BoxDecoration(
                        color: currentPage.value == index
                            ? AppColors.brand700
                            : AppColors.brand100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const Gap(40),
                // PageView for onboarding slides
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      return OnboardingPage(
                        title: page["title"] as String,
                        imagePath: page["image"] as String,
                      );
                    },
                  ),
                ),
                // Get Started Button
                CustomGetStartedButton(
                  onPressed: () {
                    if (currentPage.value == pages.length - 1) {
                      context.go('/login');
                    } else {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String imagePath;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ),
        // Title Section
        const Gap(24),
      ],
    );
  }
}

class CustomGetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;

  // ignore: use_super_parameters
  const CustomGetStartedButton({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3BE).withOpacity(0.3),
        borderRadius: BorderRadius.circular(30), // Rounded edges
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.only(
            left: 16,
            top: 8,
            bottom: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Button Text
              Text(
                "Get Started",
                style: TextStyle(
                  color: Colors.white, // White text color
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              // Arrow Icon with Circle
              CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.brand200,
                child: Icon(
                  IconsaxPlusLinear.arrow_right,
                  color: Colors.white, // White arrow color
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
