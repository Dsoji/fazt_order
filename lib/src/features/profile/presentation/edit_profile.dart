import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/text_styles.dart';
import '../data/controller/profile_controller.dart';

class EditProfileView extends HookConsumerWidget {
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  const EditProfileView({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using hooks for text controllers
    final firstNameController = useTextEditingController(text: firstName);
    final lastNameController = useTextEditingController(text: lastName);
    final phoneController = useTextEditingController(text: phone);
    final emailController = useTextEditingController(text: email);

    // Watch the profile controller state
    final profileState = ref.watch(profileControllerProvider);

    void saveProfile() async {
      // Extract first and last name from the name field

      // Call the update profile method
      final success =
          await ref.read(profileControllerProvider.notifier).updateNewProfile(
                firstName: firstNameController.text.trim(),
                lastName: lastNameController.text.trim(),
                phone: phoneController.text.trim(),
              );

      if (success) {
        // Refresh the profile data
        await ref.read(profileControllerProvider.notifier).fetchProfile();

        // Navigate back with updated data
        Navigator.pop(context, {
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
        });
      }
    }

    return Scaffold(
      backgroundColor: kcPrimaryNeutral950,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Edit Details",
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: kcPrimaryNeutral950,
        elevation: 0,
      ),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Form Fields (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Avatar Section
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[300],
                              child: const Icon(
                                Iconsax.camera,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(50),
                                  onTap: () {
                                    // TODO: Implement image picker functionality
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      verticalSpaceMedium,
                      // Form Fields
                      _buildTextField(
                        label: "First Name",
                        controller: firstNameController,
                        hintText: "e.g John",
                      ),
                      verticalSpaceMedium,
                      _buildTextField(
                        label: "Last Name",
                        controller: lastNameController,
                        hintText: "e.g  Doe",
                      ),
                      verticalSpaceMedium,
                      _buildTextField(
                        label: "Phone Number",
                        controller: phoneController,
                        hintText: "e.g 0812234567890",
                        keyboardType: TextInputType.phone,
                      ),
                      verticalSpaceMedium,
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Email cannot be edited"),
                              backgroundColor:
                                  Color.fromARGB(255, 169, 155, 26),
                            ),
                          );
                        },
                        child: AbsorbPointer(
                          absorbing: true,
                          child: _buildTextField(
                            label: "Email Address",
                            controller: emailController,
                            hintText: "e.g faztorder@gmail.com",
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Save Button (Fixed at Bottom)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        profileState.loader.isLoading ? null : saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kcPrimary400,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: profileState.loader.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kcWhite),
                            ),
                          )
                        : const Text(
                            "Save",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kcWhite,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField({
  required String label,
  required TextEditingController controller,
  required String hintText,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: ktBodyRegularSize12.copyWith(
          color: kcPrimaryNeutral200,
          letterSpacing: 1,
        ),
      ),
      verticalSpaceTiny,
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
            color: kcPrimaryNeutral200, letterSpacing: 1, fontSize: 12),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: kcPrimaryNeutral800,
            fontSize: 12,
          ),
          filled: true,
          fillColor: kcPrimaryNeutral900,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: kcPrimaryNeutral800),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: kcPrimaryNeutral800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: kcPrimary400),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    ],
  );
}
