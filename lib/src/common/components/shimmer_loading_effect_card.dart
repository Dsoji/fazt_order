import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../ui_helpers.dart';

class ShimmerLoadingEffectCard extends StatelessWidget {
  const ShimmerLoadingEffectCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: double.infinity,
      height: screenHeight(context) * 0.28,
      child: SizedBox(
        //height: size.height * 0.3,
        child: Shimmer.fromColors(
          baseColor: (Colors.grey[200])!,
          highlightColor: (Colors.grey[100])!,
          enabled: true,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            height: 100,
          ),
        ),
      ),
    );
  }
}
