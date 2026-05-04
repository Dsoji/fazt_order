import 'package:fazt_order/src/common/widgets/or_divider.dart';
import 'package:fazt_order/src/features/auth/data/controller/authentication_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../common/res/app_assets.dart';
import '../../../../common/res/app_colors.dart';
import '../../../../common/utils/validator.dart';
import '../../../../common/widgets/custom_textfield.dart';
import '../../../../router/app_router.dart';
import '../../../profile/data/controller/profile_controller.dart';
import '../../../../common/widgets/reusable_buttons.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = GlobalKey<FormState>();

    final isSendingOtp =
        ref.watch(authenticationControllerProvider).sendOtp.isLoading;

    Future<void> handleContinue() async {
      if (!formKey.currentState!.validate()) return;

      final email = emailController.text.trim();
      final sent = await ref
          .read(authenticationControllerProvider.notifier)
          .sendEmailOtp(email: email, purpose: 'login');

      if (!context.mounted || !sent) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => LoginCodeBottomSheet(email: email),
      );
    }

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
                child: Form(
                  key: formKey,
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
                      CustomFormTextField(
                        fillColor: AppColors.neutral950,
                        labelText: 'Email Address',
                        hintText: "Email Address",
                        fieldName: "email",
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        validator: Validators.emailValidator,
                      ),
                      const Gap(48),
                      FullButton(
                        text: "Continue",
                        width: double.infinity,
                        height: 48,
                        isLoading: isSendingOtp,
                        onPressed: handleContinue,
                        color: AppColors.brand400,
                        textColor: Colors.white,
                      ),
                      const Gap(8),
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
                                  ..onTap = () => context.push('/register'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(16),
                      const OrDivider(),
                      const Gap(16),
                      GestureDetector(
                        onTap: () => context.go('/guest'),
                        child: const Text(
                          'Login as a guest',
                          style: TextStyle(
                            color: AppColors.brand400,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Gap(16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginCodeBottomSheet extends HookConsumerWidget {
  final String email;

  const LoginCodeBottomSheet({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final codeController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final authState = ref.watch(authenticationControllerProvider);
    final isBusy =
        authState.login.isLoading || authState.sendOtp.isLoading;

    Future<void> handleVerify() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      final authService = ref.read(authenticationControllerProvider.notifier);
      final profileNotifier =
          ref.read(profileControllerProvider.notifier);
      final router = ref.read(routerProvider);

      final result = await authService.signIn(
        email,
        code: codeController.text.trim(),
      );

      if (!context.mounted) return;
      if (!result) {
        codeController.clear();
        return;
      }

      final user = ref
          .read(authenticationControllerProvider)
          .login
          .valueOrNull;
      final userRole = user?.user?.role;

      Navigator.pop(context);

      if (userRole == 'user') {
        await profileNotifier.fetchProfile();
        router.go('/dashboard');
      } else {
        await Hive.box('data').clear();
        Fluttertoast.showToast(
          msg: "You are not authorized as a user and cannot access this app",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: const Color.fromARGB(255, 228, 212, 62),
          textColor: Colors.black,
          fontSize: 14.0,
        );
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter login code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Gap(8),
              Text(
                'We sent a 6-digit code to $email',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const Gap(24),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: codeController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                animationDuration: const Duration(milliseconds: 250),
                enableActiveFill: true,
                validator: (v) {
                  if (v == null || v.length < 6) return "Enter the 6-digit code";
                  return null;
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 44,
                  fieldWidth: 40,
                  activeFillColor: Colors.transparent,
                  inactiveFillColor: Colors.transparent,
                  selectedFillColor: Colors.transparent,
                  inactiveColor: Colors.grey,
                  selectedColor: AppColors.brand200,
                  activeColor: Colors.black,
                ),
              ),
              const Gap(8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: authState.sendOtp.isLoading
                      ? null
                      : () async {
                          await ref
                              .read(authenticationControllerProvider.notifier)
                              .sendEmailOtp(email: email, purpose: 'login');
                          if (!context.mounted) return;
                          codeController.clear();
                          Fluttertoast.showToast(
                            msg: "Code resent",
                            gravity: ToastGravity.BOTTOM,
                          );
                        },
                  child: const Text(
                    'Resend code',
                    style: TextStyle(color: AppColors.brand400),
                  ),
                ),
              ),
              const Gap(16),
              FullButton(
                text: "Log In",
                width: double.infinity,
                height: 48,
                isLoading: isBusy,
                onPressed: handleVerify,
                color: AppColors.brand400,
                textColor: Colors.white,
              ),
              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }
}
