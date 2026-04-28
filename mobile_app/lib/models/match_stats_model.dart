import 'package:hive/hive.dart';

part 'match_stats_model.g.dart';

@HiveType(typeId: 5)
class MatchStats extends HiveObject {
  @HiveField(0)
  String? backendId;

  @HiveField(1)
  String matchId;

  @HiveField(2)
  String teamId;

  @HiveField(3)
  int passesCount;

  @HiveField(4)
  int goalCount;

  @HiveField(5)
  int foulCount;

  @HiveField(6)
  int yellowCardCount;

  @HiveField(7)
  int redCardCount;

  @HiveField(8)
  int goalkeeperSaves;

  @HiveField(9)
  int cornerCount;

  @HiveField(10)
  String? mvpName;

  @HiveField(11)
  int ownGoals;

  @HiveField(12)
  int freeKicks;

  MatchStats({
    this.backendId,
    required this.matchId,
    required this.teamId,
    this.passesCount = 0,
    this.goalCount = 0,
    this.foulCount = 0,
    this.yellowCardCount = 0,
    this.redCardCount = 0,
    this.goalkeeperSaves = 0,
    this.cornerCount = 0,
    this.mvpName,
    this.ownGoals = 0,
    this.freeKicks = 0,
  });
}
