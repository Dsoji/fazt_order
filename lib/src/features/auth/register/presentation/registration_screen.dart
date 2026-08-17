import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';

import '../../../../common/res/app_colors.dart';
import '../../../../common/utils/validator.dart';
import '../../../../common/widgets/custom_textfield.dart';
import '../../../../common/widgets/reusable_buttons.dart';
import '../../data/controller/authentication_controller.dart';
import '../../data/model/response/user_model/new_customer_promotion.dart';

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

    // Asked once, before the account exists, so the promo can be shown as
    // already claimed rather than refused after the fact. Purely informational
    // — signup goes ahead either way, and the backend decides regardless.
    useEffect(() {
      Future.microtask(
        () => ref
            .read(authenticationControllerProvider.notifier)
            .checkPromoEligibility(),
      );
      return null;
    }, const []);

    final promo = ref
        .watch(authenticationControllerProvider)
        .promoEligibility
        .valueOrNull;

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
                  if (promo != null) ...[
                    const Gap(16),
                    _NewCustomerPromoBanner(promo: promo),
                  ],
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

/// States the new-customer promo up front: still available, or already used on
/// this handset.
///
/// Greyed out is the whole point — a refusal that arrives after the account has
/// been created is a surprise the user can do nothing about, whereas this is
/// something they can see before they sign up.
class _NewCustomerPromoBanner extends StatelessWidget {
  const _NewCustomerPromoBanner({required this.promo});

  final NewCustomerPromotion promo;

  @override
  Widget build(BuildContext context) {
    final offered = promo.isOffered;
    final accent = offered ? AppColors.brand400 : AppColors.neutral600;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: offered ? AppColors.brand980 : AppColors.neutral950,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            offered ? Iconsax.gift : Iconsax.info_circle,
            size: 20,
            color: accent,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offered
                      ? 'New Customer Promo'
                      : 'New Customer Promo unavailable',
                  style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                Text(
                  // Dashboard-editable copy wins whenever the backend sent any.
                  promo.message ??
                      (offered
                          ? 'This account will be signed up with our new customer promotion.'
                          : 'This promotion can only be used once per device.'),
                  style: const TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
