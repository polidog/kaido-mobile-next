import 'package:freezed_annotation/freezed_annotation.dart';

part 'help_texts.freezed.dart';
part 'help_texts.g.dart';

/// ヘルプ画面のデータモデル。
@freezed
abstract class HelpTexts with _$HelpTexts {
  /// Creates a [HelpTexts].
  const factory HelpTexts({
    @JsonKey(name: 'main_screen') required HelpMainScreen mainScreen,
    required HelpToolbar toolbar,
    @JsonKey(name: 'data_update') required HelpDataUpdate dataUpdate,
    required HelpInquiry inquiry,
    required HelpTips tips,
  }) = _HelpTexts;

  /// Creates a [HelpTexts] from decoded JSON.
  factory HelpTexts.fromJson(Map<String, dynamic> json) =>
      _$HelpTextsFromJson(json);
}

/// メイン画面セクションのデータモデル。
@freezed
abstract class HelpMainScreen with _$HelpMainScreen {
  /// Creates a [HelpMainScreen].
  const factory HelpMainScreen({
    required String title,
    required HelpMainSections sections,
  }) = _HelpMainScreen;

  /// Creates a [HelpMainScreen] from decoded JSON.
  factory HelpMainScreen.fromJson(Map<String, dynamic> json) =>
      _$HelpMainScreenFromJson(json);
}

/// メイン画面内の各サブセクションのデータモデル。
@freezed
abstract class HelpMainSections with _$HelpMainSections {
  /// Creates a [HelpMainSections].
  const factory HelpMainSections({
    @JsonKey(name: 'route_display') required HelpRouteDisplay routeDisplay,
    @JsonKey(name: 'map_icons') required HelpMapIcons mapIcons,
    required HelpOperations operations,
  }) = _HelpMainSections;

  /// Creates a [HelpMainSections] from decoded JSON.
  factory HelpMainSections.fromJson(Map<String, dynamic> json) =>
      _$HelpMainSectionsFromJson(json);
}

/// ルート表示（凡例）セクションのデータモデル。
@freezed
abstract class HelpRouteDisplay with _$HelpRouteDisplay {
  /// Creates a [HelpRouteDisplay].
  const factory HelpRouteDisplay({
    required String title,
    @Default(<HelpRouteItem>[]) List<HelpRouteItem> items,
  }) = _HelpRouteDisplay;

  /// Creates a [HelpRouteDisplay] from decoded JSON.
  factory HelpRouteDisplay.fromJson(Map<String, dynamic> json) =>
      _$HelpRouteDisplayFromJson(json);
}

/// ルート凡例1件分のデータモデル。
@freezed
abstract class HelpRouteItem with _$HelpRouteItem {
  /// Creates a [HelpRouteItem].
  const factory HelpRouteItem({
    required String type,
    required String color,
    required String title,
  }) = _HelpRouteItem;

  /// Creates a [HelpRouteItem] from decoded JSON.
  factory HelpRouteItem.fromJson(Map<String, dynamic> json) =>
      _$HelpRouteItemFromJson(json);
}

/// マップアイコンセクションのデータモデル。
@freezed
abstract class HelpMapIcons with _$HelpMapIcons {
  /// Creates a [HelpMapIcons].
  const factory HelpMapIcons({
    required String title,
    @Default(<HelpMapIconItem>[]) List<HelpMapIconItem> items,
  }) = _HelpMapIcons;

  /// Creates a [HelpMapIcons] from decoded JSON.
  factory HelpMapIcons.fromJson(Map<String, dynamic> json) =>
      _$HelpMapIconsFromJson(json);
}

/// マップアイコン1件分のデータモデル。
@freezed
abstract class HelpMapIconItem with _$HelpMapIconItem {
  /// Creates a [HelpMapIconItem].
  const factory HelpMapIconItem({
    required String type,
    required String icon,
    required String title,
  }) = _HelpMapIconItem;

  /// Creates a [HelpMapIconItem] from decoded JSON.
  factory HelpMapIconItem.fromJson(Map<String, dynamic> json) =>
      _$HelpMapIconItemFromJson(json);
}

/// 操作方法セクションのデータモデル。
@freezed
abstract class HelpOperations with _$HelpOperations {
  /// Creates a [HelpOperations].
  const factory HelpOperations({
    required String title,
    @Default(<HelpOperationItem>[]) List<HelpOperationItem> items,
  }) = _HelpOperations;

  /// Creates a [HelpOperations] from decoded JSON.
  factory HelpOperations.fromJson(Map<String, dynamic> json) =>
      _$HelpOperationsFromJson(json);
}

/// 操作方法1件分のデータモデル。
@freezed
abstract class HelpOperationItem with _$HelpOperationItem {
  /// Creates a [HelpOperationItem].
  const factory HelpOperationItem({
    required String type,
    required String title,
    required String description,
  }) = _HelpOperationItem;

  /// Creates a [HelpOperationItem] from decoded JSON.
  factory HelpOperationItem.fromJson(Map<String, dynamic> json) =>
      _$HelpOperationItemFromJson(json);
}

/// 下部ツールバーセクションのデータモデル。
@freezed
abstract class HelpToolbar with _$HelpToolbar {
  /// Creates a [HelpToolbar].
  const factory HelpToolbar({
    required String title,
    @Default(<HelpToolbarItem>[]) List<HelpToolbarItem> items,
  }) = _HelpToolbar;

  /// Creates a [HelpToolbar] from decoded JSON.
  factory HelpToolbar.fromJson(Map<String, dynamic> json) =>
      _$HelpToolbarFromJson(json);
}

/// 下部ツールバー1件分のデータモデル。
@freezed
abstract class HelpToolbarItem with _$HelpToolbarItem {
  /// Creates a [HelpToolbarItem].
  const factory HelpToolbarItem({
    required String icon,
    required String description,
  }) = _HelpToolbarItem;

  /// Creates a [HelpToolbarItem] from decoded JSON.
  factory HelpToolbarItem.fromJson(Map<String, dynamic> json) =>
      _$HelpToolbarItemFromJson(json);
}

/// データアップデートセクションのデータモデル。
@freezed
abstract class HelpDataUpdate with _$HelpDataUpdate {
  /// Creates a [HelpDataUpdate].
  const factory HelpDataUpdate({
    required String title,
    required HelpDataUpdateInfo info,
    required String warning,
  }) = _HelpDataUpdate;

  /// Creates a [HelpDataUpdate] from decoded JSON.
  factory HelpDataUpdate.fromJson(Map<String, dynamic> json) =>
      _$HelpDataUpdateFromJson(json);
}

/// データアップデート案内のデータモデル。
@freezed
abstract class HelpDataUpdateInfo with _$HelpDataUpdateInfo {
  /// Creates a [HelpDataUpdateInfo].
  const factory HelpDataUpdateInfo({
    required String title,
    required String description,
  }) = _HelpDataUpdateInfo;

  /// Creates a [HelpDataUpdateInfo] from decoded JSON.
  factory HelpDataUpdateInfo.fromJson(Map<String, dynamic> json) =>
      _$HelpDataUpdateInfoFromJson(json);
}

/// お問い合わせセクションのデータモデル。
@freezed
abstract class HelpInquiry with _$HelpInquiry {
  /// Creates a [HelpInquiry].
  const factory HelpInquiry({
    required String title,
    @JsonKey(name: 'main_text') required String mainText,
    @JsonKey(name: 'help_text') required String helpText,
    @JsonKey(name: 'screenshot_note')
    required HelpScreenshotNote screenshotNote,
    @JsonKey(name: 'required_info')
    @Default(<String>[])
    List<String> requiredInfo,
  }) = _HelpInquiry;

  /// Creates a [HelpInquiry] from decoded JSON.
  factory HelpInquiry.fromJson(Map<String, dynamic> json) =>
      _$HelpInquiryFromJson(json);
}

/// スクリーンショット案内のデータモデル。
@freezed
abstract class HelpScreenshotNote with _$HelpScreenshotNote {
  /// Creates a [HelpScreenshotNote].
  const factory HelpScreenshotNote({
    required String icon,
    required String text,
  }) = _HelpScreenshotNote;

  /// Creates a [HelpScreenshotNote] from decoded JSON.
  factory HelpScreenshotNote.fromJson(Map<String, dynamic> json) =>
      _$HelpScreenshotNoteFromJson(json);
}

/// 上手に使うコツセクションのデータモデル。
@freezed
abstract class HelpTips with _$HelpTips {
  /// Creates a [HelpTips].
  const factory HelpTips({
    required String title,
    @Default(<HelpTipItem>[]) List<HelpTipItem> items,
  }) = _HelpTips;

  /// Creates a [HelpTips] from decoded JSON.
  factory HelpTips.fromJson(Map<String, dynamic> json) =>
      _$HelpTipsFromJson(json);
}

/// 上手に使うコツ1件分のデータモデル。
@freezed
abstract class HelpTipItem with _$HelpTipItem {
  /// Creates a [HelpTipItem].
  const factory HelpTipItem({
    required String icon,
    required String title,
    required String description,
  }) = _HelpTipItem;

  /// Creates a [HelpTipItem] from decoded JSON.
  factory HelpTipItem.fromJson(Map<String, dynamic> json) =>
      _$HelpTipItemFromJson(json);
}
