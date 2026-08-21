import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/res/app_colors.dart';
import '../../../../common/widgets/reusable_buttons.dart';
import '../../../../common/widgets/text_styles.dart';
import '../../data/model/response/user_model/new_customer_promotion.dart';

/// Tells the user their new account didn't get the new-customer promo, because
/// this handset already claimed it once.
///
/// **The account was still created.** This is an aside on the way into the app,
/// never an error state and never a reason to retry the signup — a retry would
/// fail on the duplicate email.
///
/// Does nothing when the promo was granted, or when the backend sent no message
/// to show; `message` is dashboard-editable, so it is rendered verbatim rather
/// than replaced with copy of our own.
Future<void> showNewCustomerPromoNotice(
  BuildContext context,
  NewCustomerPromotion? promo,
) async {
  if (promo == null || promo.granted || !promo.hasMessage) return;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: kcWhite,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 56,
              width: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.neutral950,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.info_circle,
                color: AppColors.brand400,
                size: 28,
              ),
            ),
            const Gap(20),
            Text(
              'About the New Customer Promo',
              textAlign: TextAlign.center,
              style: ktBodySemiBoldSize20.copyWith(color: kcBlack),
            ),
            const Gap(10),
            Text(
              promo.message!,
              textAlign: TextAlign.center,
              style: ktBodyRegularSize14.copyWith(
                color: AppColors.neutral400,
                height: 1.5,
              ),
            ),
            const Gap(24),
            FullButton(
              text: 'Continue',
              width: double.infinity,
              height: 48,
              color: AppColors.brand400,
              textColor: kcWhite,
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
      ),
    ),
  );
}
