/// CONVENTION:
/// _basePath is prefixed to every asset
/// As required the next folders are added like image and svg
///
/// When searching all the paths which are for images must contain Image in their name
/// Same for others

class Assets {
  static const String _basePath = "assets";
  static const String _imageBasePath = "images";
  static const String _animationBasePath = "animations";
  static const String _fontBasePath = "fonts";

  static const String googleLogoImagePath =
      "$_basePath/$_imageBasePath/google_logo.png";
  static const String efficacyUserLogoImagePath =
      "$_basePath/$_imageBasePath/efficacy_logo.png";
  static const String efficacyUserRoundLogoImagePath =
      "$_basePath/$_imageBasePath/efficacy_user_round.png";
  static const String gdscLogoImagePath =
      "$_basePath/$_imageBasePath/gdsc_logo.png";
  static const String mediaImgPath = "$_basePath/$_imageBasePath/media.png";

  static const String regularFontPath =
      "$_basePath/$_fontBasePath/Sofia_Pro/SofiaProRegular.ttf";

  static const String efficacyUserHostedImageUrl =
      "https://res.cloudinary.com/dxdyqv2jq/image/upload/v1707659043/app/efficacy_user.png";

  static const String loginPageAnimationLottie =
      "$_basePath/$_animationBasePath/login.json";
  static const String emptyFeedAnimation1 =
      "$_basePath/$_animationBasePath/empty.json";
  static const String eventLoadingAnimation =
      "$_basePath/$_animationBasePath/loading.json";
}
