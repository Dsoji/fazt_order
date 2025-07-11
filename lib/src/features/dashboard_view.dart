import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../providers/navigation_provider.dart';
import '../common/app_colors.dart';
import 'courier/courier.dart';
import 'home/presentation/home_view.dart';
import 'order/order_view.dart';
import 'profile/presentation/profile.dart';

class DashboardView extends HookConsumerWidget {
  const DashboardView({super.key});

  static final List<Widget> _pages = <Widget>[
    const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: kcPrimaryNeutral950,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: HomeView(),
    ),
    const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: kcPrimaryNeutral950,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: OrderView(),
    ),
    const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: kcPrimaryNeutral950,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: CourierView(),
    ),
    const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: kcPrimaryNeutral950,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: ProfileView(),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final navItems = [
      {'icon': Iconsax.home, 'label': 'Home'},
      {'icon': Iconsax.shopping_bag, 'label': 'Order'},
      {'icon': Iconsax.group_1, 'label': 'Courier'},
      {'icon': Iconsax.profile_circle, 'label': 'Profile'},
    ];

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: _pages[currentIndex],
          ),
          Positioned(
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(navItems.length, (index) {
                  final isSelected = currentIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () async {
                        if (currentIndex != index) {
                          HapticFeedback.lightImpact();
                          ref.read(navigationProvider.notifier).state = index;
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  height: isSelected ? 36 : 0,
                                  width: isSelected ? 48 : 0,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? kcPrimary400.withOpacity(0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                Icon(
                                  navItems[index]['icon'] as IconData,
                                  size: isSelected ? 28 : 24,
                                  color: isSelected
                                      ? kcPrimary400
                                      : kcPrimaryNeutral500,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              style: TextStyle(
                                fontSize: isSelected ? 14 : 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? kcPrimary400
                                    : kcPrimaryNeutral500,
                              ),
                              child: Text(navItems[index]['label'] as String),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.only(top: 4),
                              height: 4,
                              width: isSelected ? 16 : 0,
                              decoration: BoxDecoration(
                                color: kcPrimary400,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
