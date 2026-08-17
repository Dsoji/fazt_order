class BasePaths {
  static const baseImagePath = "asset/images";
  static const baseSvgPath = "asset/svgs";
  static const lottiePath = "asset/lottie";
  static const baseIconPath = "asset/iconsAsset";
  static const baseGifPath = "asset/gif";
  static const baseAnimationPath = "asset/animations";
  static const basePlaceholderPath = "asset/placeholders";
  static const baseProdUrl = "https://faztorder.onrender.com/v1/";
  static const baseStagingUrl = "https://fazt.onrender.com/v1/";

  // "https://golangfoaxrudderdev-pr-6.onrender.com/v1/";
  // "https://golangfoaxrudderdev.onrender.com/v1/";
  // "https://golangfoaxrudderdev-pr-4.onrender.com/v1/"; //
  // static const baseProdUrl2 = "";
  static const baseTestUrl = "https://dummyjson.com";

  /// This app's own store listings.
  ///
  /// The update popup falls back to these when the version record carries no
  /// `storeUrl` — which is the case on every freshly seeded record. A blocking
  /// popup whose only button does nothing has no way out, so the link cannot be
  /// left to the dashboard.
  static const appStoreUrl = "https://apps.apple.com/app/id6749697862";
  static const playStoreUrl =
      "https://play.google.com/store/apps/details?id=net.faztorder.order";
  // static const baseUrl = AppConfig.devMode ? baseTestUrl : baseProdUrl;
}
