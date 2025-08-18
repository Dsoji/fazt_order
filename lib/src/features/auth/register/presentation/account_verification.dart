import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../common/res/app_assets.dart';
import '../../../../common/res/app_colors.dart';
import '../../../../common/widgets/reusable_buttons.dart';
import '../../data/controller/authentication_controller.dart';
import '../../map/map_location_screen.dart';

// Separate widget for countdown to isolate rebuilds
class AccountVerificationScreen extends ConsumerStatefulWidget {
  const AccountVerificationScreen({
    super.key,
    required this.email,
  });
  final String email;

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
              // Isolated countdown widget
              RichText(
                text: TextSpan(
                  text: "Didn't receive the OTP? ",
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400),
                  children: <TextSpan>[
                    TextSpan(
                      text: ' Resend OTP',
                      style: const TextStyle(
                          color: Color(0xFF903E9D),
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          if (_start == 0) {
                            // _reverifyUser(context);
                            otpController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                duration: Duration(seconds: 5),
                                backgroundColor: Colors.black,
                                content: Text(
                                  'Please wait for the timer',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            );
                          }
                        },
                    ),
                    const TextSpan(
                      text: ' or ',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: '\nChange Email Address',
                      style: const TextStyle(
                          color: AppColors.brand400,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pop(context);
                        },
                    ),
                  ],
                ),
              ),

              const Gap(48),
              // Submit button
              FullButton(
                text: "Continue",
                width: double.infinity,
                height: 48,
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }
                  final result = await authService.emailConfirm(
                    widget.email,
                    otpController.text.trim(),
                  );

                  if (result == true) {
                    Navigator.pushReplacement(
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
    );
  }
}
