import 'package:fazt_order/src/features/auth/register/presentation/account_verification.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../common/res/app_assets.dart';
import '../../../../common/res/app_colors.dart';
import '../../../../common/utils/validator.dart';
import '../../../../common/widgets/custom_textfield.dart';
import '../../../../common/widgets/or_divider.dart';
import '../../../../common/widgets/reusable_buttons.dart';
import '../../data/controller/authentication_controller.dart';
import '../../login/presentation/login_screen.dart';

final logger = Logger();

class RegistrationScreen extends HookConsumerWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using hooks for controllers and state
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final createPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final numberController = useTextEditingController();
    // State hooks for password visibility
    final isCreatePasswordVisible = useState(false);
    final isConfirmPasswordVisible = useState(false);
//
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.brand900,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.brand900,
        automaticallyImplyLeading: false,
        title: const Text(
          'Sign Up',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 25),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(100),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Gap(24),
                const Text(
                  'Let get you onboarded by creating an account with us',
                  style: TextStyle(color: AppColors.neutral300, fontSize: 16),
                ),
                const Gap(24),
                CustomFormTextField(
                  fillColor: AppColors.brand980,
                  labelText: 'First name',
                  hintText: "First name",
                  fieldName: "First name",
                  keyboardType: TextInputType.text,
                  controller: firstNameController, // First name controller
                  validator: (value) =>
                      Validators.requiredField(value, "First name"),
                ),
                const Gap(16),
                CustomFormTextField(
                  fillColor: AppColors.brand980,
                  labelText: 'Last name',
                  hintText: "Last name",
                  fieldName: "Last name",
                  keyboardType: TextInputType.text,
                  controller: lastNameController, // Last name controller
                  validator: (value) =>
                      Validators.requiredField(value, "Last name"),
                ),
                const Gap(16),
                CustomFormTextField(
                  fillColor: AppColors.brand980,
                  labelText: 'Phone number',
                  hintText: "08012345678",
                  fieldName: "Phone number",
                  keyboardType: TextInputType.phone,
                  controller: numberController, // Last name controller
                  validator: (value) =>
                      Validators.requiredField(value, "Phone number"),
                ),
                const Gap(16),
                CustomFormTextField(
                  fillColor: AppColors.neutral950,
                  labelText: 'Email Address',
                  hintText: "Email Address",
                  fieldName: "Email Address",
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController, // Email address controller
                  validator: Validators.emailValidator,
                ),
                const Gap(16),
                CustomFormTextField(
                  fillColor: AppColors.neutral950,
                  labelText: 'Create Password',
                  hintText: "*******",
                  fieldName: "Create Password",
                  keyboardType: TextInputType.text,
                  controller:
                      createPasswordController, // Create password controller
                  isPassword: true,
                  validator: Validators.passwordValidator,
                ),
                const Gap(16),
                CustomFormTextField(
                  fillColor: AppColors.neutral950,
                  labelText: 'Confirm Password',
                  hintText: "*******",
                  fieldName: "Confirm Password",
                  keyboardType: TextInputType.text,
                  controller:
                      confirmPasswordController, // Confirm password controller
                  isPassword: true,
                  validator: Validators.passwordValidator,
                ),
                const Gap(48),
                FullButton(
                  text: "Continue",
                  width: double.infinity,
                  isLoading: ref
                      .watch(authenticationControllerProvider)
                      .signUp
                      .isLoading,
                  height: 48,
                  onPressed: () async {
                    // final authService =
                    //     ref.read(authenticationControllerProvider.notifier);

                    // if (!formKey.currentState!.validate()) {
                    //   return;
                    // }
                    // final result = await authService.signUp(
                    //   email: emailController.text.trim(),
                    //   password: createPasswordController.text.trim(),
                    //   firstName: firstNameController.text.trim(),
                    //   lastName: lastNameController.text.trim(),
                    //   phone: numberController.text.trim(),
                    // );
                    // logger.d(result);
                    // if (result == true) {
                    //   logger.d('Navigating...');
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountVerificationScreen(
                          email: emailController.text.trim(),
                        ),
                      ),
                    );
                    // }
                  },
                  color: AppColors.brand400,
                  textColor: Colors.white,
                ),
                const Gap(8),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: const TextStyle(
                        color: Colors.black, // Normal text color
                        fontSize: 12, // Normal text size
                      ),
                      children: [
                        TextSpan(
                          text: 'Log In',
                          style: const TextStyle(
                            color:
                                AppColors.brand400, // Green color for "Log In"
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            decoration:
                                TextDecoration.underline, // Underline "Log In"
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to login screen or handle login action
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(16),
                const OrDivider(),
                const Gap(16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ImgBton(
                      width: 160,
                      height: 48,
                      onPressed: () {},
                      color: AppColors.brand800,
                      image: ImageAssets.google,
                      bgColor: AppColors.brand980,
                      radius: 50,
                    ),
                    const Gap(24),
                    ImgBton(
                      width: 160,
                      height: 48,
                      onPressed: () {},
                      color: AppColors.brand800,
                      image: ImageAssets.apple,
                      bgColor: AppColors.brand980,
                      radius: 50,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
