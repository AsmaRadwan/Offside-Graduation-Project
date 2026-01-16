import 'package:hive/hive.dart';

part 'player_model.g.dart';

@HiveType(typeId: 3)
class Player extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String position;

  @HiveField(2)
  int age;

  @HiveField(3)
  String nationality;

  @HiveField(4)
  String? image;

  @HiveField(5)
  int number;

  @HiveField(6)
  int goals;

  @HiveField(7)
  int assists;

  @HiveField(8)
  int appearances;

  @HiveField(9)
  int yellowCards;

  @HiveField(10)
  int redCards;

  @HiveField(11)
  int minutesPlayed;

  @HiveField(12)
  int shots;

  @HiveField(13)
  int passes;

  @HiveField(14)
  int played;

  Player({
    required this.name,
    required this.position,
    required this.age,
    required this.nationality,
    this.image = "",
    required this.number,
    this.goals = 0,
    this.assists = 0,
    this.appearances = 0,
    this.yellowCards = 0,
    this.redCards = 0,
    this.minutesPlayed = 0,
    this.shots = 0,
    this.passes = 0,
    this.played = 0,
  });
  
}
