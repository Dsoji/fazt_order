import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/app_colors.dart';
import '../../../../common/widgets/text_styles.dart';
import '../../data/controller/shop_controller.dart';
import '../../data/model/response/meal_variant_menu/result.dart';
import '../../data/model/response/pack_add_options/pack_add_options.dart';
import '../providers/active_pack_provider.dart';
import 'add_to_cart_bottom_sheet.dart';

/// The "Add to This Pack" picker.
///
/// What may go into a pack depends on what is already in it, and those rules
/// are the backend's: a pack of option-free meals accepts any other option-free
/// meal, while a pack holding a meal with options accepts only more of that
/// same meal. `GET /carts/:cartId/pack/:packNumber/add-options` answers with
/// exactly one of those two shapes, which is why this sheet asks rather than
/// filtering the menu itself — a local guess produces adds that come back
/// rejected after the customer has already chosen.
Future<void> showAddToPackSheet(
  BuildContext context, {
  required String shopId,
  required String cartId,
  required int packNumber,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddToPackSheet(
      shopId: shopId,
      cartId: cartId,
      packNumber: packNumber,
    ),
  );
}

class AddToPackSheet extends HookConsumerWidget {
  const AddToPackSheet({
    super.key,
    required this.shopId,
    required this.cartId,
    required this.packNumber,
  });

  final String shopId;
  final String cartId;
  final int packNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      Future.microtask(
        () => ref
            .read(shopControllerProvider.notifier)
            .fetchPackAddOptions(cartId, packNumber),
      );
      return null;
    }, [cartId, packNumber]);

    final optionsAsync = ref.watch(shopControllerProvider).packAddOptions;

    /// Point the next add at this pack, then open the meal's own sheet. The
    /// pack number rides along on `POST /carts` from there.
    void openMeal(MealVariantMenuResult meal) {
      ref.read(activePackProvider.notifier).select(shopId, packNumber);
      Navigator.pop(context);
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddToCartBottomSheet(menuItem: meal, shopId: shopId),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: kcWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: kcPrimaryNeutral900,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add to Pack $packNumber',
                    style:
                        ktBodyBoldSize18.copyWith(color: kcPrimaryNeutral100),
                  ),
                  const Gap(3),
                  Text(
                    _subtitleFor(optionsAsync.valueOrNull),
                    style: ktLabelRegularSize12.copyWith(
                        color: kcPrimaryNeutral500),
                  ),
                ],
              ),
            ),
            Flexible(
              child: optionsAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const _EmptyState(
                  message: "We couldn't load what can go in this pack. "
                      'Please try again.',
                ),
                data: (options) => _Body(
                  options: options,
                  scrollController: scrollController,
                  onPick: openMeal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _subtitleFor(PackAddOptions? options) => switch (
      options?.packType) {
        PackType.mealOptions =>
          'This pack is customised, so only more of the same meal can join it',
        PackType.combinable => 'Anything here can share this pack',
        _ => 'Checking what can go in this pack',
      };
}

class _Body extends StatelessWidget {
  const _Body({
    required this.options,
    required this.scrollController,
    required this.onPick,
  });

  final PackAddOptions options;
  final ScrollController scrollController;
  final void Function(MealVariantMenuResult) onPick;

  @override
  Widget build(BuildContext context) {
    if (!options.hasAnythingToAdd) {
      return const _EmptyState(
        message: 'Nothing else can be added to this pack. '
            'Start another pack instead.',
      );
    }

    // A customised pack takes only more of the meal already in it, so there is
    // no picker to show — just that one meal's option sheet.
    if (options.packType == PackType.mealOptions) {
      final meal = MealVariantMenuResult.fromMap({
        'id': options.mealVariant,
        'meal': options.meal,
        'inStock': true,
      });
      final name = meal.meal?.mealName;
      return ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _PackRuleNotice(
            message: name == null || name.isEmpty
                ? 'This pack holds a customised meal, so only more of that '
                    'same meal can go in it. Any other meal needs its own pack.'
                : 'This pack holds $name with its own options, so only more '
                    '$name can go in it. Any other meal needs its own pack.',
          ),
          const Gap(12),
          _MealTile(meal: meal, onTap: () => onPick(meal)),
        ],
      );
    }

    // The notice rides in the list rather than above it so the sheet keeps a
    // single scrollable — the drag handle needs [scrollController] to own the
    // whole body.
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: options.eligibleMeals.length + 1,
      separatorBuilder: (_, __) => const Gap(10),
      itemBuilder: (_, index) {
        if (index == 0) {
          return const _PackRuleNotice(
            message: 'These meals can share this pack. A meal with its own '
                'options is missing here because it needs a pack of its own.',
          );
        }
        final meal = options.eligibleMeals[index - 1];
        return _MealTile(
          meal: meal,
          // An out-of-stock meal is listed but not tappable, so the pack's
          // contents stay explicable rather than the item silently vanishing.
          onTap: meal.inStock == false ? null : () => onPick(meal),
        );
      },
    );
  }
}

/// Why this pack won't take everything.
///
/// The rule is the backend's — a pack holding a customised meal accepts only
/// more of that meal — and it is invisible from the menu, so a customer who
/// came here to add something else reads the empty picker as a bug. Stating it
/// at the moment of the choice is cheaper than the support message afterwards.
class _PackRuleNotice extends StatelessWidget {
  const _PackRuleNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kcPrimary980,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Iconsax.info_circle, size: 16, color: kcPrimary300),
          const Gap(8),
          Expanded(
            child: Text(
              message,
              style: ktLabelRegularSize12.copyWith(color: kcPrimary100),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealTile extends StatelessWidget {
  const _MealTile({required this.meal, this.onTap});

  final MealVariantMenuResult meal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final image = meal.meal?.mealImage;
    final disabled = onTap == null;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kcWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kcPrimaryNeutral900),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 52,
                  width: 52,
                  child: image == null || image.isEmpty
                      ? Container(
                          color: kcPrimaryNeutral950,
                          child: const Icon(Iconsax.cake,
                              size: 20, color: kcPrimaryNeutral500),
                        )
                      : CachedNetworkImage(
                          imageUrl: image,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: kcPrimaryNeutral950,
                            child: const Icon(Iconsax.cake,
                                size: 20, color: kcPrimaryNeutral500),
                          ),
                        ),
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.meal?.mealName ?? 'Meal',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: kcPrimaryNeutral100,
                      ),
                    ),
                    if (disabled) ...[
                      const Gap(2),
                      Text(
                        'Out of stock',
                        style: ktLabelRegularSize12.copyWith(
                            color: kcPrimaryNeutral500),
                      ),
                    ],
                  ],
                ),
              ),
              if (!disabled)
                const Icon(Icons.add_circle_outline,
                    size: 22, color: kcPrimary300),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: ktLabelRegularSize12.copyWith(color: kcPrimaryNeutral500),
        ),
      ),
    );
  }
}
