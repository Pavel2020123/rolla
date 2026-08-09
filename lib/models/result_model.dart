enum MedalType { gold, silver, bronze, none }

class ResultModel {
  final String id;
  final String title;
  final DateTime date;
  final String modality;
  final String position;
  final String? time;
  final MedalType medalType;

  ResultModel({
    required this.id,
    required this.title,
    required this.date,
    required this.modality,
    required this.position,
    this.time,
    this.medalType = MedalType.none,
  });

  bool get showMedal => medalType != MedalType.none;

  factory ResultModel.fromJson(Map<String, dynamic> json) {
    return ResultModel(
      id: json['id'] as String,
      title: json['title'] as String,
      date: DateTime.parse(json['date'] as String),
      modality: json['modality'] as String,
      position: json['position'] as String,
      time: json['time'] as String?,
      medalType: _parseMedalType(json['medal_type'] as String?),
    );
  }

  static MedalType _parseMedalType(String? type) {
    switch (type) {
      case 'gold':
        return MedalType.gold;
      case 'silver':
        return MedalType.silver;
      case 'bronze':
        return MedalType.bronze;
      default:
        return MedalType.none;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'modality': modality,
      'position': position,
      'time': time,
      'medal_type': medalType.name,
    };
  }
}