import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../common/res/app_colors.dart';
import '../../../../common/utils/validator.dart';
import '../../../../common/widgets/custom_textfield.dart';
import '../../../../common/widgets/reusable_buttons.dart';
import '../../data/controller/authentication_controller.dart';

final logger = Logger();

class RegistrationScreen extends HookConsumerWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final emailController = useTextEditingController();
    final numberController = useTextEditingController();
    final referralCodeController = useTextEditingController();

    final formKey = GlobalKey<FormState>();

    final isSendingOtp =
        ref.watch(authenticationControllerProvider).sendOtp.isLoading;

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
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(100),
            topRight: Radius.circular(100),
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
                    textAlign: TextAlign.center,
                  ),
                  const Gap(24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: CustomFormTextField(
                          fillColor: AppColors.brand980,
                          labelText: 'First name',
                          hintText: "First name",
                          fieldName: "First name",
                          keyboardType: TextInputType.text,
                          controller: firstNameController,
                          validator: (value) =>
                              Validators.requiredField(value, "First name"),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: CustomFormTextField(
                          fillColor: AppColors.brand980,
                          labelText: 'Last name',
                          hintText: "Last name",
                          fieldName: "Last name",
                          keyboardType: TextInputType.text,
                          controller: lastNameController,
                          validator: (value) =>
                              Validators.requiredField(value, "Last name"),
                        ),
                      ),
                    ],
                  ),
                  const Gap(16),
                  CustomFormTextField(
                    fillColor: AppColors.neutral950,
                    labelText: 'Email Address',
                    hintText: "Email Address",
                    fieldName: "Email Address",
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    validator: Validators.emailValidator,
                  ),
                  const Gap(16),
                  CustomFormTextField(
                    fillColor: AppColors.brand980,
                    labelText: 'Phone number',
                    hintText: "08012345678",
                    fieldName: "Phone number",
                    keyboardType: TextInputType.phone,
                    controller: numberController,
                    validator: Validators.phoneValidator,
                  ),
                  const Gap(16),
                  CustomFormTextField(
                    fillColor: AppColors.brand980,
                    labelText: 'Referral code (optional)',
                    hintText: "Enter referral code",
                    fieldName: "Referral code",
                    keyboardType: TextInputType.text,
                    controller: referralCodeController,
                  ),
                  const Gap(48),
                  FullButton(
                    text: "Continue",
                    width: double.infinity,
                    isLoading: isSendingOtp,
                    height: 48,
                    onPressed: () async {
                      final authService =
                          ref.read(authenticationControllerProvider.notifier);

                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      final email = emailController.text.trim();
                      final firstName = firstNameController.text.trim();
                      final lastName = lastNameController.text.trim();
                      final phone = numberController.text.trim();
                      final referralCode =
                          referralCodeController.text.trim();

                      final sent = await authService.sendEmailOtp(
                        email: email,
                        purpose: 'signup',
                      );

                      if (!context.mounted) return;
                      if (sent) {
                        context.push('/verify-otp', extra: {
                          'email': email,
                          'firstName': firstName,
                          'lastName': lastName,
                          'phone': phone,
                          if (referralCode.isNotEmpty)
                            'referralCode': referralCode,
                          'purpose': 'signup',
                        });
                      }
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
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: const TextStyle(
                              color: AppColors.brand400,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => context.go('/login'),
                          ),
                        ],
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
    );
  }
}
