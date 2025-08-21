import 'package:fazt_order/src/features/auth/data/controller/authentication_controller.dart';
import 'package:fazt_order/src/features/dashboard_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/res/app_assets.dart';
import '../../../../common/res/app_colors.dart';
import '../../../../common/utils/validator.dart';
import '../../../../common/widgets/custom_textfield.dart';
import '../../../../common/widgets/or_divider.dart';
import '../../../../common/widgets/reusable_buttons.dart';
import '../../register/presentation/registration_screen.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using hooks for controllers and state
    final emailController =
        useTextEditingController(text: 'map@mailinator.com');
    final passwordController = useTextEditingController(text: 'Test123.');

    // State hooks for password visibility
    final isPasswordVisible = useState(false);

    return Scaffold(
      backgroundColor: AppColors.brand900,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.brand900,
        automaticallyImplyLeading: false,
        title: const Text(
          'Log In',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Image Banner
          Container(
            height: 222,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(GifAssets.onboardFour),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 25),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  topRight: Radius.circular(100),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Gap(24),
                    const Text(
                      'Let’s continue from where you stopped',
                      style: TextStyle(
                        color: AppColors.neutral300,
                        fontSize: 16,
                      ),
                    ),
                    const Gap(24),

                    // Email Field
                    CustomFormTextField(
                      fillColor: AppColors.neutral950,
                      labelText: 'Email Address',
                      hintText: "Email Address",
                      fieldName: "email",
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      validator: Validators.emailValidator,
                    ),
                    const Gap(16),

                    // Password Field
                    CustomFormTextField(
                      fillColor: AppColors.neutral950,
                      labelText: 'Password',
                      hintText: "*******",
                      fieldName: "password",
                      keyboardType: TextInputType.text,
                      controller: passwordController,
                      isPassword: true,
                      validator: Validators.passwordValidator,
                    ),
                    const Gap(48),

                    // Continue Button
                    FullButton(
                      text: "Continue",
                      width: double.infinity,
                      height: 48,
                      isLoading: ref
                          .watch(authenticationControllerProvider)
                          .login
                          .isLoading,
                      onPressed: () async {
                        final email = emailController.text.trim();
                        final password = passwordController.text.trim();

                        if (email.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please fill all fields."),
                            ),
                          );
                          return;
                        }

                        final result = await ref
                            .read(authenticationControllerProvider.notifier)
                            .signIn(email, password);
                        if (result == true) {
                          final user = ref
                              .watch(authenticationControllerProvider)
                              .login
                              .valueOrNull;

                          final userRole = user?.user?.role;
                          if (userRole == 'user') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashboardView(),
                              ),
                            );
                          } else {
                            final box = Hive.box('data');
                            await box.clear();
                            Fluttertoast.showToast(
                              msg:
                                  "You are not authorized as a vendor and cannot access this app",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.TOP,
                              backgroundColor:
                                  const Color.fromARGB(255, 228, 212, 62),
                              textColor: Colors.black,
                              fontSize: 14.0,
                            );
                          }
                        }

                        // Handle login logic
                      },
                      color: AppColors.brand400,
                      textColor: Colors.white,
                    ),
                    const Gap(8),

                    // Sign Up Text with Navigation
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: const TextStyle(
                                color: AppColors.brand400,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(16),

                    // OR Divider
                    const OrDivider(),
                    const Gap(16),

                    // Social Login Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ImgBton(
                          width: 160,
                          height: 48,
                          onPressed: () {
                            print("Google Login");
                          },
                          color: AppColors.brand800,
                          image: ImageAssets.google,
                          bgColor: AppColors.brand980,
                          radius: 50,
                        ),
                        const Gap(24),
                        ImgBton(
                          width: 160,
                          height: 48,
                          onPressed: () {
                            print("Apple Login");
                          },
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
        ],
      ),
    );
  }
}
