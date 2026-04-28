import 'package:hive/hive.dart';

part 'player_stats_model.g.dart';

@HiveType(typeId: 6)
class PlayerStats extends HiveObject {
  @HiveField(0)
  String? backendId;

  @HiveField(1)
  String playerId;

  @HiveField(2)
  String? heatmapImageUrl;

  @HiveField(3)
  String position;

  @HiveField(4)
  int appearanceCount;

  PlayerStats({
    this.backendId,
    required this.playerId,
    this.heatmapImageUrl,
    required this.position,
    this.appearanceCount = 0,
  });
}
