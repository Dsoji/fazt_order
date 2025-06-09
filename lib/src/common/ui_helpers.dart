import 'dart:math';

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'components/shimmer_loading_effect_card.dart';
import 'components/shimmer_loading_effect_grid.dart';
import 'components/shimmer_loading_effect_list.dart';

const double _tinySize = 5.0;
const double _smallSize = 10.0;
const double _mediumSize = 25.0;
const double _semiLargeSize = 40.0;
const double _largeSize = 50.0;
const double _massiveSize = 120.0;

const Widget horizontalSpaceTiny = SizedBox(width: _tinySize);
const Widget horizontalSpaceSmall = SizedBox(width: _smallSize);
const Widget horizontalSpaceMedium = SizedBox(width: _mediumSize);
const Widget horizontalSpaceLarge = SizedBox(width: _largeSize);

const Widget verticalSpaceTiny = SizedBox(height: _tinySize);
const Widget verticalSpaceSmall = SizedBox(height: _smallSize);
const Widget verticalSpaceMedium = SizedBox(height: _mediumSize);
const Widget verticalSpaceSemiLarge = SizedBox(height: _semiLargeSize);
const Widget verticalSpaceLarge = SizedBox(height: _largeSize);
const Widget verticalSpaceMassive = SizedBox(height: _massiveSize);

Widget spacedDivider = const Column(
  children: <Widget>[
    verticalSpaceMedium,
    Divider(color: Colors.blueGrey, height: 5.0),
    verticalSpaceMedium,
  ],
);

Widget verticalSpace(double height) => SizedBox(height: height);
Widget horizontalSpace(double width) => SizedBox(width: width);

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0, double max = 3000}) =>
    min((screenHeight(context) - offsetBy) / dividedBy, max);

double screenWidthFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0, double max = 3000}) =>
    min((screenWidth(context) - offsetBy) / dividedBy, max);

double halfScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 2);

double thirdScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 3);

double quarterScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 4);

double getResponsiveHorizontalSpaceMedium(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 10);
double getResponsiveSmallFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 14, max: 15);

double getResponsiveMediumFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 16, max: 17);

double getResponsiveLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 21, max: 31);

double getResponsiveExtraLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 25);

double getResponsiveMassiveFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 30);

double getResponsiveFontSize(BuildContext context,
    {double? fontSize, double? max}) {
  max ??= 100;

  var responsiveSize = min(
      screenWidthFraction(context, dividedBy: 10) * ((fontSize ?? 100) / 100),
      max);

  return responsiveSize;
}

Widget verticalLine(
    {required double height, Color? color, double? thicknessValue}) {
  return SizedBox(
    height: height,
    child: VerticalDivider(
      color: color ?? kcWhite,
      thickness: thicknessValue ?? 0.2,
    ),
  );
}

Widget horizontalLine(
    {required double width, Color? color, double? thicknessValue}) {
  return SizedBox(
    width: width,
    child: Divider(
        color: color ?? kcWhite,
//width: 10.0,
        thickness: thicknessValue ?? 0.2),
  );
}

Widget loadingEffectStyle(String type) {
  Widget effect = const Text('Loading');
  if (type == 'Grid') {
    effect = const ShimmerLoadingEffectGrid();
  } else if (type == 'List') {
    effect = const ShimmerLoadingEffectList();
  } else if (type == 'Card') {
    effect = const ShimmerLoadingEffectCard();
  }
  return effect;
}
