import 'package:hive/hive.dart';
import 'package:offside/models/event_model.dart';
import 'package:offside/models/team_model.dart';

part 'match_model.g.dart';

@HiveType(typeId: 1)
class Match2 extends HiveObject {
  @HiveField(0)
  Team homeTeam;

  @HiveField(1)
  Team awayTeam;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  int? homeTeamScore;

  @HiveField(4)
  int? awayTeamScore;

  @HiveField(5)
  String? status;

  @HiveField(6)
  List<Event> eventsHome;

  @HiveField(7)
  List<Event> eventsAway;

  /// The backend UUID for this match. Set after syncing to the server.
  @HiveField(8)
  String? backendId;

  // New fields from ER diagram
  @HiveField(9)
  String? videoUrl;

  Match2({
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    this.homeTeamScore = 0,
    this.awayTeamScore = 0,
    this.eventsHome = const [],
    this.eventsAway = const [],
    this.backendId,
    this.videoUrl,
  });
}
