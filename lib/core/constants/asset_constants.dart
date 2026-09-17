/// MYBIKE Asset Path Constants
abstract final class AssetConstants {
  static const String _basePath = 'assets';
  static const String _imagesPath = '$_basePath/images';
  static const String iconsPath = '$_basePath/icons';

  // ─── Logo ───
  static const String logo = '$_imagesPath/logo.png';
  static const String logoDark = '$_imagesPath/logo_dark.png';
  static const String logoIcon = '$_imagesPath/logo_icon.png';

  // ─── Placeholders ───
  static const String placeholderVehicle = '$_imagesPath/placeholder_vehicle.png';
  static const String placeholderUser = '$_imagesPath/placeholder_user.png';

  // ─── Illustrations ───
  static const String emptyState = '$_imagesPath/empty_state.png';
  static const String errorState = '$_imagesPath/error_state.png';
  static const String noConnection = '$_imagesPath/no_connection.png';
}
