import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:fazt_order/src/features/profile/presentation/settings_view.dart';
import 'package:fazt_order/src/features/profile/presentation/wallet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/text_styles.dart';
import '../../auth/login/presentation/login_screen.dart';
import '../../home/presentation/edit_address.dart';
import '../../home/presentation/favorites_view.dart';
import '../data/controller/profile_controller.dart';
import 'customer_support_view.dart';
import 'edit_profile.dart';

class ProfileView extends HookConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetails =
        ref.watch(profileControllerProvider).userDetails.valueOrNull;

    Future<void> navigateToEditProfile() async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileView(
            firstName: userDetails?.user?.firstName ?? '',
            lastName: userDetails?.user?.lastName ?? '',
            phone: userDetails?.user?.phone ?? '',
            email: userDetails?.user?.email ?? '',
          ),
        ),
      );
      // if (result != null) {
      //   profileNotifier.updateProfile(
      //     name: result['name'],
      //     phone: result['phone'],
      //     email: result['email'],
      //   );
      // }
    }

    return Scaffold(
      backgroundColor: kcPrimaryNeutral950,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header Section
              Center(
                child: Column(
                  children: [
                    // Avatar
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage('asset/images/profile-picture.png'),
                      backgroundColor: kcPrimaryNeutral800,
                    ),
                    verticalSpaceSmall,
                    // User Name
                    Text(
                      '${userDetails?.user?.firstName ?? ''} ${userDetails?.user?.lastName ?? ''}'
                          .trim(),
                      style: ktBodySemiBoldSize20.copyWith(
                        fontSize: 16,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                    verticalSpaceTiny,
                    // Contact Details
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "Mobile: ",
                            style: TextStyle(
                              fontSize: 10,
                              color: kcPrimaryNeutral500,
                            ),
                          ),
                          TextSpan(
                            text: userDetails?.user?.phone ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: kcPrimaryNeutral200,
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpaceTiny,
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "Email: ",
                            style: TextStyle(
                              fontSize: 10,
                              color: kcPrimaryNeutral500,
                            ),
                          ),
                          TextSpan(
                            text: userDetails?.user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: kcPrimaryNeutral200,
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpaceSmall,
                    // Edit Button
                    GestureDetector(
                      onTap: navigateToEditProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: kcPrimary600, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.edit,
                              size: 16,
                              color: kcPrimary400,
                            ),
                            horizontalSpaceTiny,
                            Text(
                              "Edit",
                              style: TextStyle(
                                color: kcPrimary400,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              verticalSpaceMedium,
              // Options List
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                decoration: BoxDecoration(
                  color: kcWhite,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildListItem(
                      backgroundColor: kcPrimaryBlue900,
                      icon: Iconsax.location,
                      iconColor: kcPrimaryBlue200,
                      title: "Addresses",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddressesView()),
                        );
                      },
                    ),
                    verticalSpaceTiny,
                    SvgPicture.asset('asset/svgs/dotted_line.svg'),
                    verticalSpaceTiny,
                    _buildListItem(
                      backgroundColor: kcPrimaryYellow980,
                      icon: Iconsax.wallet,
                      iconColor: kcPrimaryNeutral200,
                      title: "Wallet",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const WalletView()),
                        );
                      },
                    ),
                    verticalSpaceTiny,
                    SvgPicture.asset('asset/svgs/dotted_line.svg'),
                    verticalSpaceTiny,
                    _buildListItem(
                      backgroundColor: kcPrimaryOrange900,
                      icon: Iconsax.folder_favorite,
                      iconColor: kcPrimaryOrange300,
                      title: "Favorites",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const FavoritesView()),
                        );
                      },
                    ),
                    verticalSpaceTiny,
                    SvgPicture.asset(
                        'asset/svgs/dotted_line.svg'), // Dashed divider
                    verticalSpaceTiny,
                    _buildListItem(
                      backgroundColor: kcPrimaryPurple900,
                      icon: Iconsax.setting,
                      iconColor: kcPrimaryPurple200,
                      title: "Settings",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsView()),
                        );
                      },
                    ),
                    verticalSpaceTiny,
                    SvgPicture.asset(
                        'asset/svgs/dotted_line.svg'), // Dashed divider
                    verticalSpaceTiny,
                    _buildListItem(
                      backgroundColor: kcPrimaryGreen950,
                      icon: Iconsax.messages,
                      iconColor: kcPrimaryNeutral200,
                      title: "Customer Support",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const CustomerSupportView()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Gap(100),
              FullButton(
                text: 'Log Out',
                width: 150,
                height: 48,
                onPressed: () {
                  var box = Hive.box('data');
                  box.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                color: Colors.red,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: 3,
      //   selectedItemColor: Colors.green,
      //   unselectedItemColor: Colors.grey,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Iconsax.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Iconsax.task), label: "Order"),
      //     BottomNavigationBarItem(icon: Icon(Iconsax.truck), label: "Courier"),
      //     BottomNavigationBarItem(icon: Icon(Iconsax.user), label: "Profile"),
      //   ],
      //   onTap: (index) {
      //     if (index == 0) {
      //       Navigator.pop(context); // Navigate back to HomeView
      //     }
      //     // TODO: Handle other tab navigation (Order, Courier)
      //   },
      // ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: SizedBox(
        width: 24,
        height: 24,
        child: CircleAvatar(
          backgroundColor: backgroundColor,
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}
