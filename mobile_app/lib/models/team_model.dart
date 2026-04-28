import 'package:hive/hive.dart';
import 'package:offside/models/player_model.dart';

part 'team_model.g.dart';

@HiveType(typeId: 2)
class Team extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String logo;

  @HiveField(2)
  int? points;

  @HiveField(3)
  int? wins;

  @HiveField(4)
  int? losses;

  @HiveField(5)
  int? goalsFor;

  @HiveField(6)
  int? goalsAgainst;

  @HiveField(7)
  int? draw;

  @HiveField(8)
  List<Player> players;

  @HiveField(9)
  int? played;

  @HiveField(10)
  int? diff_goals;

  @HiveField(11)
  String? backendId;

  @HiveField(12)
  String? primaryColor;

  @HiveField(13)
  String? secondaryColor;

  Team({
    required this.name,
    required this.logo,
    this.points = 0,
    this.wins = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.draw = 0,
    required this.players,
    this.played = 0,
    this.diff_goals = 0,
    this.backendId,
    this.primaryColor,
    this.secondaryColor,
  });
}
