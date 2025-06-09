import 'package:fazt_order/src/common/res/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerRestaurantCard extends StatelessWidget {
  const ShimmerRestaurantCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      color: AppColors.brand980,
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: AppColors.brand980,
            child: Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[300],
            ),
          ),
          const Gap(12),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: AppColors.brand980,
            child: Container(
              height: 20,
              width: double.infinity,
              color: Colors.grey[300],
            ),
          ),
          const Gap(12),
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: AppColors.brand980,
            child: Container(
              height: 20,
              width: double.infinity,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}
