import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../common/res/app_assets.dart';
import '../../../../common/res/app_colors.dart';
import '../../../../common/utils/validator.dart';
import '../../../../common/widgets/custom_textfield.dart';
import '../../../../common/widgets/reusable_buttons.dart';
import '../../data/controller/authentication_controller.dart';
import '../../login/presentation/login_screen.dart';

// Separate widget for countdown to isolate rebuilds
class CountdownWidget extends HookWidget {
  final VoidCallback? onResendTap;

  const CountdownWidget({super.key, this.onResendTap});

  @override
  Widget build(BuildContext context) {
    final secondsRemaining = useState(60);
    final isResendAvailable = useState(false);

    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (secondsRemaining.value > 0) {
          secondsRemaining.value--;
        } else {
          isResendAvailable.value = true;
          timer.cancel();
        }
      });

      return timer.cancel;
    }, []);

    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: isResendAvailable.value ? onResendTap : null,
        child: Text(
          isResendAvailable.value
              ? "Didn't receive a code? Resend"
              : "Resend code in ${secondsRemaining.value}s",
          style: TextStyle(
            color: isResendAvailable.value
                ? AppColors.brand400
                : AppColors.neutral300,
            fontSize: 12,
            fontWeight:
                isResendAvailable.value ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// Separate widget for the loading button to isolate provider watching
class SubmitButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const SubmitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading =
        ref.watch(authenticationControllerProvider).emailConfirmation.isLoading;

    return FullButton(
      isLoading: isLoading,
      text: "Continue",
      width: double.infinity,
      height: 48,
      onPressed: onPressed,
      color: AppColors.brand400,
      textColor: Colors.white,
    );
  }
}

class AccountVerificationScreen extends HookConsumerWidget {
  const AccountVerificationScreen({
    super.key,
    required this.email,
  });
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();

    // Using hooks for controllers and state
    final pinController = useTextEditingController();
    final focusNode = useFocusNode(); // Add focus node

    // State hooks for password visibility
    final authService = ref.read(authenticationControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.brand900,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.brand900,
        automaticallyImplyLeading: false,
        title: const Text(
          'Verification',
          style: TextStyle(
              color: Colors.black, fontSize: 24, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Gap(72),
              Image.asset(
                ImageAssets.twofa,
                height: 300,
                width: 300,
              ),
              const Gap(100),
              Text(
                'Enter the OTP sent to your email $email',
                style:
                    const TextStyle(color: AppColors.neutral300, fontSize: 16),
              ),
              const Gap(24),
              CustomFormTextField(
                fillColor: AppColors.brand980,
                labelText: '',
                hintText: "0000",
                fieldName: "Pin",
                keyboardType: TextInputType.number,
                controller: pinController,
                focus: focusNode, // Add focus node
                validator: (value) => Validators.requiredField(value, "Pin"),
              ),
              const Gap(24),
              // Isolated countdown widget
              CountdownWidget(
                onResendTap: () {
                  // Trigger resend function here
                  // authService.resendOTP(email);
                },
              ),
              const Gap(48),
              // Isolated submit button
              SubmitButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  final result = await authService.emailConfirm(
                    email,
                    pinController.text.trim(),
                  );

                  if (result == true) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }
}
