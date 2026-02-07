import 'package:hive/hive.dart';

part 'report.g.dart';

@HiveType(typeId: 1)
class Report extends HiveObject {
  Report({
    required this.id,
    required this.title,
    required this.description,
    this.photoPath,
    this.latitude,
    this.longitude,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String? photoPath;

  @HiveField(4)
  final double? latitude;

  @HiveField(5)
  final double? longitude;

  @HiveField(6)
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'photoPath': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    final createdAtValue = json['createdAt'];
    final createdAt = createdAtValue is DateTime
        ? createdAtValue
        : createdAtValue is String
            ? DateTime.parse(createdAtValue)
            : createdAtValue is num
                ? DateTime.fromMillisecondsSinceEpoch(
                    createdAtValue.toInt(),
                    isUtc: true,
                  )
                : DateTime.now().toUtc();
    return Report(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      photoPath: json['photoPath'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      createdAt: createdAt,
    );
  }
}
