import 'package:Almuslim/exports/constants.dart' show AlmuslimCategory, Ribbon;

class Thekr {
  late final String id;
  late final String text;
  late final String sectionName;
  late final int section;

  late final bool isTitle;
  late bool isFav;

  late final int counter;

  final AlmuslimCategory category = AlmuslimCategory.athkar;
  final String ribbon = Ribbon.ribbon1;

  Thekr._(
    this.id,
    this.text,
    this.counter,
    this.isTitle,
    this.section,
    this.isFav, {
    this.sectionName = '',
  }) : super();

  factory Thekr.fromMap(Map<String, dynamic> map) => Thekr._(
        map['id'] ?? '',
        map['text'] ?? '',
        map['counter'] ?? 0,
        map['isTitle'] ?? false,
        map['section'] ?? 0,
        map['isFav'] ?? false,
        sectionName: map['sectionName'] ?? '',
      );

  factory Thekr.title(Map<String, dynamic> map) => Thekr._(
        '',
        map['text'] as String,
        map['counter'] as int,
        map['isTitle'] as bool,
        map['section'] as int,
        false,
        sectionName: map['sectionName'] ?? '',
      );
}
