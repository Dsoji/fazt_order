// // import 'dart:async';
// //
// // import 'package:fazt_order/src/common/ui_helpers.dart';
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_svg/svg.dart';
// // import 'package:iconsax/iconsax.dart';
// //
// // import '../../common/app_colors.dart';
// // import '../../common/widgets/text_styles.dart';
// //
// // class DashboardView extends StatelessWidget {
// //   const DashboardView({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xffd9d9d980),
// //       appBar: AppBar(
// //         backgroundColor: const Color(0xffd9d9d980),
// //         title: Row(
// //           children: [
// //             const Icon(Iconsax.location, color: kcPrimary400,),
// //             horizontalSpaceTiny,
// //             const Text('Computer Village', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
// //             horizontalSpaceTiny,
// //             SvgPicture.asset('asset/svgs/arrow-down.svg', color: kcPrimaryNeutral200,),
// //           ],
// //         ),
// //         actions: [
// //           GestureDetector(
// //             behavior: HitTestBehavior.translucent,
// //             child: Row(
// //               children: [
// //                 const Icon(Iconsax.document_filter, color: kcPrimary300, size: 16,),
// //                 horizontalSpaceTiny,
// //                 Text("Filter", style: ktBodyRegularSize14.copyWith(color: kcPrimary300),),
// //                 horizontalSpaceTiny,
// //               ],
// //             ),
// //           )
// //         ],
// //         ),
// //       body: Column(
// //         children: [
// //           _buildSearchMarket(),
// //           const Text('Welcome to the Dashboard!'),
// //         ],
// //       )
// //     );
// //   }
// // }
// //
// // Widget _buildSearchMarket() {
// //   return Padding(
// //     padding: const EdgeInsets.only(left: 10.0, right: 10),
// //     child: Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         TextField(
// //           onChanged: (value) {},
// //           decoration: InputDecoration(
// //             contentPadding: const EdgeInsets.symmetric(horizontal: 20),
// //             hintText: 'Search',
// //             hintStyle: ktBodyRegularSize14.copyWith(color: kcPrimaryNeutral500),
// //             suffixIcon: const Icon(
// //               Iconsax.search_normal_1,
// //               color: kcPrimaryNeutral500,
// //               size: 20,
// //             ),
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(50),
// //               borderSide: BorderSide.none,
// //             ),
// //             filled: true,
// //             fillColor: kcPrimaryNeutral900,
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
//
//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
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

  static final List<Widget> _pages = [
    // HomeView: Use the global status bar color (Colors.pink[50])
    const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: kcPrimaryNeutral950,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: HomeView(),
    ),
    // OrderView: Custom status bar color (Colors.blue[50])
    const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: kcPrimaryNeutral950,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: OrderView(),
    ),
    // CourierView: Use the global status bar color (Colors.pink[50])
    const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: kcPrimaryNeutral950,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: CourierView(),
    ),
    // ProfileView: Use the global status bar color (Colors.pink[50])
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
              padding: const EdgeInsets.symmetric(vertical: 8),
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
        // Icon
        SizedBox(
          height: 24,
          width: 24,
          child: icon,
           // Adjust icon size to match the design
        ),
        // Green dot indicator above the icon when selected
        if (isSelected)
          Positioned(
            top: -4, // Position the dot above the icon
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    ),
    label: label,
  );
}






// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../providers/navigation_provider.dart';
// import '../../common/components/triangular_indicator.dart';
// import 'courier.dart';
// import 'home_view.dart';
// import 'order_view.dart';
// import 'profile.dart';
//
// class DashboardView extends ConsumerWidget {
//   const DashboardView({Key? key}) : super(key: key);
//
//   static final List<Widget> _pages = [
//     const AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: Colors.pink,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//       child: HomeView(),
//     ),
//     const AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: Colors.blue,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//       child: OrderView(),
//     ),
//     const AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: Colors.pink,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//       child: CourierView(),
//     ),
//     const AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle(
//         statusBarColor: Colors.pink,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//       child: ProfileView(),
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final currentIndex = ref.watch(navigationProvider);
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             color: Colors.pink[50],
//             child: SafeArea(
//               bottom: false,
//               child: IndexedStack(
//                 index: currentIndex,
//                 children: _pages,
//               ),
//             ),
//           ),
//           Positioned(
//             left: 16.0,
//             right: 16.0,
//             bottom: 16.0,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 0),
//                 child: BottomNavigationBar(
//                   type: BottomNavigationBarType.fixed,
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
//                   items: [
//                     _buildNavItem(
//                       icon: Icons.home,
//                       label: "Home",
//                       isSelected: currentIndex == 0,
//                     ),
//                     _buildNavItem(
//                       icon: Icons.receipt,
//                       label: "Order",
//                       isSelected: currentIndex == 1,
//                     ),
//                     _buildNavItem(
//                       icon: Icons.local_shipping,
//                       label: "Courier",
//                       isSelected: currentIndex == 2,
//                     ),
//                     _buildNavItem(
//                       icon: Icons.person,
//                       label: "Profile",
//                       isSelected: currentIndex == 3,
//                     ),
//                   ],
//                   currentIndex: currentIndex,
//                   selectedItemColor: Colors.green,
//                   unselectedItemColor: Colors.grey,
//                   showUnselectedLabels: true,
//                   selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                   unselectedLabelStyle: const TextStyle(fontSize: 12),
//                   onTap: (index) {
//                     ref.read(navigationProvider.notifier).state = index;
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   BottomNavigationBarItem _buildNavItem({
//     required IconData icon,
//     required String label,
//     required bool isSelected,
//   }) {
//     return BottomNavigationBarItem(
//       icon: SizedBox(
//         height: 48,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 12.0),
//               child: Icon(
//                 icon,
//                 size: 24,
//               ),
//             ),
//             if (isSelected)
//               const Positioned(
//                 top: -4, // Keep the indicator at the top edge
//                 child: TriangleCircleIndicator(
//                   size: 20, // Adjust size of the triangle
//                   triangleColor: Colors.green,
//                   circleColor: Colors.white,
//                 ),
//               ),
//           ],
//         ),
//       ),
//       label: label,
//     );
//   }
// }