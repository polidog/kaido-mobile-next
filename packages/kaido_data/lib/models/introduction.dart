import 'package:freezed_annotation/freezed_annotation.dart';

part 'introduction.freezed.dart';
part 'introduction.g.dart';

/// はじめに画面のデータモデル。
@freezed
abstract class IntroductionData with _$IntroductionData {
  /// Creates an [IntroductionData].
  const factory IntroductionData({
    required IntroSection intro,
    @Default(<InfoCard>[]) List<InfoCard> supplementaryInfo,
    @Default(<InfoCard>[]) List<InfoCard> terminology,
  }) = _IntroductionData;

  /// Creates an [IntroductionData] from decoded JSON.
  factory IntroductionData.fromJson(Map<String, dynamic> json) =>
      _$IntroductionDataFromJson(json);
}

/// はじめにセクションのデータモデル。
@freezed
abstract class IntroSection with _$IntroSection {
  /// Creates an [IntroSection].
  const factory IntroSection({
    required String title,
    required String content,
    required String updateNote,
  }) = _IntroSection;

  /// Creates an [IntroSection] from decoded JSON.
  factory IntroSection.fromJson(Map<String, dynamic> json) =>
      _$IntroSectionFromJson(json);
}

/// 情報カードのデータモデル。
@freezed
abstract class InfoCard with _$InfoCard {
  /// Creates an [InfoCard].
  const factory InfoCard({
    required String title,
    required String content,
    String? icon,
  }) = _InfoCard;

  /// Creates an [InfoCard] from decoded JSON.
  factory InfoCard.fromJson(Map<String, dynamic> json) =>
      _$InfoCardFromJson(json);
}
