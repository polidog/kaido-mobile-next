import 'package:freezed_annotation/freezed_annotation.dart';

part 'gokaido.freezed.dart';
part 'gokaido.g.dart';

/// 五街道画面用のデータモデル。
@freezed
abstract class GokaidoData with _$GokaidoData {
  /// Creates a [GokaidoData].
  const factory GokaidoData({
    required GokaidoIntroduction introduction,
    @Default(<GokaidoRoute>[]) List<GokaidoRoute> routes,
  }) = _GokaidoData;

  /// Creates a [GokaidoData] from decoded JSON.
  factory GokaidoData.fromJson(Map<String, dynamic> json) =>
      _$GokaidoDataFromJson(json);
}

/// 五街道紹介部分のデータモデル。
@freezed
abstract class GokaidoIntroduction with _$GokaidoIntroduction {
  /// Creates a [GokaidoIntroduction].
  const factory GokaidoIntroduction({
    required String title,
    required String content,
    required String note,
  }) = _GokaidoIntroduction;

  /// Creates a [GokaidoIntroduction] from decoded JSON.
  factory GokaidoIntroduction.fromJson(Map<String, dynamic> json) =>
      _$GokaidoIntroductionFromJson(json);
}

/// 街道ルートのデータモデル。
@freezed
abstract class GokaidoRoute with _$GokaidoRoute {
  /// Creates a [GokaidoRoute].
  const factory GokaidoRoute({
    required String title,
    required String content,
    required String icon,
    required String historicalNote,
    Map<String, String>? appLinks,
  }) = _GokaidoRoute;

  /// Creates a [GokaidoRoute] from decoded JSON.
  factory GokaidoRoute.fromJson(Map<String, dynamic> json) =>
      _$GokaidoRouteFromJson(json);
}
