import 'package:fazt_order/src/common/widgets/reusable_buttons.dart';
import 'package:fazt_order/src/features/home/presentation/customer_support.dart';
import 'package:fazt_order/src/features/profile/presentation/settings_view.dart';
import 'package:fazt_order/src/features/profile/presentation/wallet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/text_styles.dart';
import '../../auth/login/presentation/login_screen.dart';
import '../../home/presentation/favorites_view.dart';
import '../data/controller/profile_controller.dart';
import 'edit_profile.dart';

class ProfileView extends HookConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDetails = ref.watch(profileControllerProvider).userDetails;
    final String? link = dotenv.env['CHAT_LINK'];
    Widget buildUserProfileSection(dynamic userDetails,
        {bool isLoading = false, bool hasError = false}) {
      final opacity = isLoading ? 0.7 : (hasError ? 0.8 : 1.0);
      final nameColor = hasError ? Colors.red.shade300 : Colors.black;

      // Get user initials for avatar fallback
      final firstName = userDetails?.user?.firstName ?? '';
      final lastName = userDetails?.user?.lastName ?? '';
      final initials = firstName.isNotEmpty || lastName.isNotEmpty
          ? '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
              .toUpperCase()
          : 'U';

      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: kcWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Avatar Section
            // User Name
            Opacity(
              opacity: opacity,
              child: Text(
                '${userDetails?.user?.firstName ?? ''} ${userDetails?.user?.lastName ?? ''}'
                    .trim(),
                style: ktBodySemiBoldSize20.copyWith(
                  fontSize: 22,
                  color: nameColor,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            verticalSpaceSmall,

            // Contact Details Card
            Opacity(
              opacity: opacity,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: kcPrimaryNeutral950,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Mobile Number
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kcPrimary600.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Iconsax.call,
                            size: 16,
                            color: kcPrimary400,
                          ),
                        ),
                        horizontalSpaceSmall,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Mobile",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: kcPrimaryNeutral500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userDetails?.user?.phone ?? 'Not provided',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: hasError
                                      ? Colors.red.shade300
                                      : kcPrimaryNeutral200,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Divider
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: kcPrimaryNeutral800.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    // Email
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kcPrimary600.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Iconsax.sms,
                            size: 16,
                            color: kcPrimary400,
                          ),
                        ),
                        horizontalSpaceSmall,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Email",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: kcPrimaryNeutral500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userDetails?.user?.email ?? 'Not provided',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: hasError
                                      ? Colors.red.shade300
                                      : kcPrimaryNeutral200,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            verticalSpaceMedium,

            // Edit Button
            Opacity(
              opacity: opacity,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileView(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        kcPrimary400,
                        kcPrimary600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kcPrimary400.withOpacity(0.3),
                        spreadRadius: 0,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.edit,
                        size: 18,
                        color: kcWhite,
                      ),
                      horizontalSpaceSmall,
                      Text(
                        "Edit Profile",
                        style: TextStyle(
                          color: kcWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
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
                child: userDetails.maybeWhen(
                  loading: () => userDetails.hasValue
                      ? buildUserProfileSection(userDetails.value!,
                          isLoading: true)
                      : _buildLoadingProfileSection(),
                  error: (error, stackTrace) => userDetails.hasValue
                      ? buildUserProfileSection(userDetails.value!,
                          hasError: true)
                      : _buildErrorProfileSection(ref),
                  orElse: () => buildUserProfileSection(
                      userDetails.valueOrNull ?? userDetails.value!),
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
                    SvgPicture.asset('asset/svgs/dotted_line.svg'),
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
                    SvgPicture.asset('asset/svgs/dotted_line.svg'),
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
                                  CustomerSupportWebViewScreen(
                                      uri: link ?? '')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Gap(24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 232, 199, 197),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildListItem(
                  backgroundColor: Colors.red,
                  icon: Iconsax.trash,
                  iconColor: Colors.white,
                  title: "Delete Account",
                  onTap: () async {
                    final result = await ref
                        .read(profileControllerProvider.notifier)
                        .deleteUser(
                          userId: userDetails.value?.user?.id ?? '',
                        );
                    if (result == true) {
                      var box = Hive.box('data');
                      box.clear();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                      Fluttertoast.showToast(
                        msg: "Account deleted successfully",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.yellow.shade700,
                        textColor: Colors.black,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "Failed to delete account",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  },
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
              const Gap(100),
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

  Widget _buildLoadingProfileSection() {
    return Column(
      children: [
        // Loading Avatar
        const CircleAvatar(
          radius: 50,
          backgroundColor: kcPrimaryNeutral800,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        verticalSpaceSmall,
        // Loading Name
        Container(
          width: 120,
          height: 16,
          decoration: BoxDecoration(
            color: kcPrimaryNeutral800,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        verticalSpaceTiny,
        // Loading Mobile
        Container(
          width: 150,
          height: 12,
          decoration: BoxDecoration(
            color: kcPrimaryNeutral800,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        verticalSpaceTiny,
        // Loading Email
        Container(
          width: 180,
          height: 12,
          decoration: BoxDecoration(
            color: kcPrimaryNeutral800,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        verticalSpaceSmall,
        // Edit Button (disabled)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: kcPrimaryNeutral600, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.edit,
                size: 16,
                color: kcPrimaryNeutral600,
              ),
              horizontalSpaceTiny,
              Text(
                "Edit",
                style: TextStyle(
                  color: kcPrimaryNeutral600,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorProfileSection(WidgetRef ref) {
    return Column(
      children: [
        // Error Avatar
        const CircleAvatar(
          radius: 50,
          backgroundColor: kcPrimaryNeutral800,
          child: Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 30,
          ),
        ),
        verticalSpaceSmall,
        const Text(
          'Failed to load profile',
          style: TextStyle(
            fontSize: 16,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        verticalSpaceTiny,
        const Text(
          'Please check your connection',
          style: TextStyle(
            fontSize: 12,
            color: kcPrimaryNeutral500,
          ),
        ),
        verticalSpaceSmall,
        // Retry Button
        GestureDetector(
          onTap: () {
            // Trigger profile fetch
            ref.read(profileControllerProvider.notifier).fetchProfile();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh,
                  size: 16,
                  color: Colors.red,
                ),
                horizontalSpaceTiny,
                Text(
                  "Retry",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
