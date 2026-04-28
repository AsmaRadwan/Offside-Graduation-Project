import 'package:hive/hive.dart';

// part 'invitation_model.g.dart';

// @HiveType(typeId: 8)
class Invitation extends HiveObject {
  // @HiveField(0)
  String id;

  // @HiveField(1)
  String teamName;

  // @HiveField(2)
  String leagueName;

  // @HiveField(3)
  String playerName;

  // @HiveField(4)
  String playerId;

  // @HiveField(5)
  int jerseyNumber;

  // @HiveField(6)
  String status; // 'pending', 'accepted', 'rejected'

  // @HiveField(7)
  DateTime timestamp;

  Invitation({
    required this.id,
    required this.teamName,
    required this.leagueName,
    required this.playerName,
    required this.playerId,
    required this.jerseyNumber,
    this.status = 'pending',
    required this.timestamp,
  });
}
