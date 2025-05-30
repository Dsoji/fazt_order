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
import '../../map/map_location_screen.dart';

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

    // State hooks for password visibility

    final authService = ref.read(authenticationControllerProvider.notifier);
    final secondsRemaining = useState(60);
    final isResendAvailable = useState(false);

// Countdown logic
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

    return Scaffold(
      backgroundColor: AppColors.brand900,
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Gap(72),
          Image.asset(
            ImageAssets.twofa,
            height: 300,
            width: 300,
          ),
          const Spacer(),
          Container(
            margin: const EdgeInsets.only(top: 25),
            height: 372,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(70),
                topRight: Radius.circular(70),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Enter the OTP sent to your email $email',
                      style: const TextStyle(
                          color: AppColors.neutral300, fontSize: 16),
                    ),
                    const Gap(24),
                    CustomFormTextField(
                      fillColor: AppColors.brand980,
                      labelText: '',
                      hintText: "0000",
                      fieldName: "Pin",
                      keyboardType: TextInputType.number,
                      controller: pinController,
                      validator: (value) =>
                          Validators.requiredField(value, "Pin"),
                    ),
                    const Gap(24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: isResendAvailable.value
                            ? () {
                                // Trigger resend function here
                                // Restart timer
                                isResendAvailable.value = false;
                                secondsRemaining.value = 60;
                                // authService.resendOTP(
                                //     email); // Assume this function exists
                              }
                            : null,
                        child: Text(
                          isResendAvailable.value
                              ? "Didn't receive a code? Resend"
                              : "Resend code in ${secondsRemaining.value}s",
                          style: TextStyle(
                            color: isResendAvailable.value
                                ? AppColors.brand400
                                : AppColors.neutral300,
                            fontSize: 12,
                            fontWeight: isResendAvailable.value
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    const Gap(48),
                    FullButton(
                      isLoading: ref
                          .watch(authenticationControllerProvider)
                          .emailConfirmation
                          .isLoading,
                      text: "Continue",
                      width: double.infinity,
                      height: 48,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        final result = await authService.emailConfirm(
                          email,
                          pinController.text.trim(),
                        );

                        if (result == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapLocationScreen(),
                            ),
                          );
                        }
                      },
                      color: AppColors.brand400,
                      textColor: Colors.white,
                    ),
                    const Gap(16),
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
