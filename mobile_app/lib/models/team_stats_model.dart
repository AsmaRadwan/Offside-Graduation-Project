import 'package:hive/hive.dart';

part 'team_stats_model.g.dart';

@HiveType(typeId: 7)
class TeamStats extends HiveObject {
  @HiveField(0)
  String? backendId;

  @HiveField(1)
  String teamId;

  @HiveField(2)
  int appearanceCount;

  @HiveField(3)
  int totalOwnGoals;

  TeamStats({
    this.backendId,
    required this.teamId,
    this.appearanceCount = 0,
    this.totalOwnGoals = 0,
  });
}
