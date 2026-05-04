import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../common/res/app_assets.dart';
import '../../../../common/res/app_colors.dart';
import '../../../../common/widgets/reusable_buttons.dart';
import '../../../profile/data/controller/profile_controller.dart';
import '../../data/controller/authentication_controller.dart';

// Separate widget for countdown to isolate rebuilds
class AccountVerificationScreen extends ConsumerStatefulWidget {
  const AccountVerificationScreen({
    super.key,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.referralCode,
    this.purpose = 'signup',
  });
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? referralCode;
  final String purpose;

  @override
  ConsumerState<AccountVerificationScreen> createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState
    extends ConsumerState<AccountVerificationScreen> {
  late Timer _timer;
  int _start = 60;
  bool isLoading = false;

  final otpController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;
  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    errorController?.close();
    otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            isLoading = false;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authenticationControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.brand900,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
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
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(72),
              Image.asset(
                ImageAssets.twofa,
                height: 300,
                width: 300,
              ),
              const Gap(100),
              Text(
                'Enter the OTP sent to your email ${widget.email}',
                style:
                    const TextStyle(color: AppColors.neutral300, fontSize: 16),
              ),
              const Gap(24),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 30,
                ),
                child: PinCodeTextField(
                  backgroundColor: Colors.transparent,
                  appContext: context,
                  pastedTextStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  length: 6,
                  obscureText: true,
                  obscuringCharacter: '*',
                  blinkWhenObscuring: true,
                  animationType: AnimationType.fade,
                  validator: (v) {
                    if (v!.length < 3) {
                      return "Otp not complete";
                    } else {
                      return null;
                    }
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldWidth: 40,
                    fieldHeight: 40,
                    activeFillColor: Colors.transparent,
                    inactiveFillColor: Colors.transparent,
                    selectedFillColor: Colors.transparent,
                    inactiveColor: Colors.grey,
                    selectedColor: AppColors.brand200,
                    activeColor: Colors.black,
                  ),
                  cursorColor: AppColors.brand200,
                  animationDuration: const Duration(milliseconds: 500),
                  enableActiveFill: true,
                  errorAnimationController: errorController,
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  boxShadows: const [
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                  onCompleted: (v) {
                    debugPrint("Completed");
                  },
                  onChanged: (value) {
                    debugPrint(value);
                    setState(() {
                      currentText = value;
                    });
                  },
                  beforeTextPaste: (text) {
                    debugPrint("Allowing to paste $text");
                    return true;
                  },
                ),
              ),
              const Gap(24),
              Builder(
                builder: (context) {
                  final isResending = ref.watch(authenticationControllerProvider
                      .select((s) => s.sendOtp.isLoading));
                  final canResend = _start == 0 && !isResending;

                  Future<void> handleResend() async {
                    otpController.clear();
                    final sent = await ref
                        .read(authenticationControllerProvider.notifier)
                        .sendEmailOtp(
                          email: widget.email,
                          purpose: widget.purpose,
                        );
                    if (!mounted || !sent) return;
                    setState(() {
                      _start = 60;
                    });
                    startTimer();
                  }

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Didn't receive the OTP? ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (isResending)
                            const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF903E9D),
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: canResend ? handleResend : null,
                              child: Text(
                                canResend
                                    ? 'Resend OTP'
                                    : 'Resend OTP in ${_start}s',
                                style: TextStyle(
                                  color: canResend
                                      ? const Color(0xFF903E9D)
                                      : Colors.grey[700],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Gap(8),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          'Change Email Address',
                          style: TextStyle(
                            color: AppColors.brand400,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const Gap(48),
              // Submit button
              Consumer(
                builder: (context, ref, _) {
                  final authState = ref.watch(authenticationControllerProvider);
                  final isBusy = authState.verifyOtp.isLoading ||
                      authState.signUp.isLoading;
                  return FullButton(
                    text: "Continue",
                    width: double.infinity,
                    height: 48,
                    isLoading: isBusy,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      final proofToken = await authService.verifyEmailOtp(
                        email: widget.email,
                        otp: otpController.text.trim(),
                        purpose: widget.purpose,
                      );

                      if (!context.mounted) return;
                      if (proofToken == null || proofToken.isEmpty) return;

                      final firstName = widget.firstName;
                      final lastName = widget.lastName;
                      final phone = widget.phone;
                      if (firstName == null ||
                          lastName == null ||
                          phone == null) {
                        return;
                      }

                      final signedUp = await authService.signUp(
                        email: widget.email,
                        firstName: firstName,
                        lastName: lastName,
                        phone: phone,
                        referralCode: widget.referralCode,
                        signupOtpToken: proofToken,
                      );

                      if (!context.mounted) return;
                      if (signedUp) {
                        await ref
                            .read(profileControllerProvider.notifier)
                            .fetchProfile();
                        if (!context.mounted) return;
                        context.go('/set-location');
                      }
                    },
                    color: AppColors.brand400,
                    textColor: Colors.white,
                  );
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
