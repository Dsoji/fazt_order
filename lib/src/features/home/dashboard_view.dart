import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../providers/navigation_provider.dart';
import '../../common/app_colors.dart';
import 'courier.dart';
import 'home_view.dart';
import 'order_view.dart';
import 'profile.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({Key? key}) : super(key: key);

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
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                items: [
                  _buildNavItem(
                    icon: Icon(Iconsax.home),
                    label: "Home",
                    isSelected: currentIndex == 0,
                  ),
                  _buildNavItem(
                    icon: Icon(Iconsax.shopping_bag),
                    label: "Order",
                    isSelected: currentIndex == 1,
                  ),
                  _buildNavItem(
                    icon: Icon(Iconsax.group_1),
                    label: "Courier",
                    isSelected: currentIndex == 2,
                  ),
                  _buildNavItem(
                    icon: Icon(Iconsax.profile_circle),
                    label: "Profile",
                    isSelected: currentIndex == 3,
                  ),
                ],
                currentIndex: currentIndex,
                selectedItemColor: kcPrimary400,
                unselectedItemColor: kcPrimaryNeutral500,
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                onTap: (index) {
                  ref.read(navigationProvider.notifier).state = index;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BottomNavigationBarItem _buildNavItem({
  required Widget icon,
  required String label,
  required bool isSelected,
}) {
  return BottomNavigationBarItem(
    icon: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: icon,
        ),
      ],
    ),
    label: label,
  );
}