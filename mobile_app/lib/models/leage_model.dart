import 'package:hive/hive.dart';
import 'package:offside/models/match_model.dart';
import 'package:offside/models/player_model.dart';
import 'package:offside/models/team_model.dart';

part 'leage_model.g.dart';

@HiveType(typeId: 0)
class League extends HiveObject {
  @HiveField(0)
  String logo;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Team> teams;

  @HiveField(3)
  List<Match2> matches;

  @HiveField(4)
  List<Player>? topScorers;

  @HiveField(5)
  List<Player>? topAssistants;

  /// The backend UUID returned after syncing to the server.
  /// Null until the league has been pushed to the backend.
  @HiveField(6)
  String? backendId;

  // New fields from ER diagram
  @HiveField(7)
  DateTime? startDate;

  @HiveField(8)
  DateTime? endDate;

  League({
    required this.logo,
    required this.name,
    required this.teams,
    required this.matches,
    this.topScorers,
    this.topAssistants,
    this.backendId,
    this.startDate,
    this.endDate,
  });

  // ─────────────────────────────────────────────────
  //  Standings calculation (unchanged)
  // ─────────────────────────────────────────────────
  void updateStandings() {
    // Reset all stats first
    for (var t in teams) {
      t.played = 0;
      t.wins = 0;
      t.draw = 0;
      t.losses = 0;
      t.goalsFor = 0;
      t.goalsAgainst = 0;
      t.points = 0;
    }

    // Iterate over matches and calculate
    for (var m in matches) {
      if (m.homeTeamScore == null || m.awayTeamScore == null) {
        continue; // If the match hasn't been played, skip it
      }

      final home = teams.firstWhere(
        (t) => t.name == m.homeTeam.name,
        orElse: () =>
            Team(name: m.homeTeam.name, players: [], logo: m.homeTeam.logo),
      );

      final away = teams.firstWhere(
        (t) => t.name == m.awayTeam.name,
        orElse: () =>
            Team(name: m.awayTeam.name, players: [], logo: m.awayTeam.logo),
      );

      home.played = (home.played ?? 0) + 1;
      away.played = (away.played ?? 0) + 1;
      for (var p in home.players) {
        p.played = home.played!;
      }
      for (var p in away.players) {
        p.played = away.played!;
      }

      home.goalsFor = (home.goalsFor ?? 0) + m.homeTeamScore!;
      home.goalsAgainst = (home.goalsAgainst ?? 0) + m.awayTeamScore!;
      away.goalsFor = (away.goalsFor ?? 0) + m.awayTeamScore!;
      away.goalsAgainst = (away.goalsAgainst ?? 0) + m.homeTeamScore!;

      if (m.homeTeamScore! > m.awayTeamScore!) {
        home.wins = (home.wins ?? 0) + 1;
        away.losses = (away.losses ?? 0) + 1;
        home.points = (home.points ?? 0) + 3;
      } else if (m.homeTeamScore! < m.awayTeamScore!) {
        away.wins = (away.wins ?? 0) + 1;
        home.losses = (home.losses ?? 0) + 1;
        away.points = (away.points ?? 0) + 3;
      } else {
        home.draw = (home.draw ?? 0) + 1;
        away.draw = (away.draw ?? 0) + 1;
        home.points = (home.points ?? 0) + 1;
        away.points = (away.points ?? 0) + 1;
      }
    }
  }

  // ─────────────────────────────────────────────────
  //  Top Scorers
  // ─────────────────────────────────────────────────
  void generateTopScorers() {
    // Collect all players from all teams
    final allPlayers = teams.expand((team) => team.players).toList();
    // Keep only players with goals > 0
    final scorers = allPlayers.where((player) => player.goals > 0).toList();
    // Sort by goals descending
    scorers.sort((a, b) => b.goals.compareTo(a.goals));
    // Store in topScorers list
    topScorers = scorers.cast<Player>();
  }

  // ─────────────────────────────────────────────────
  //  Top Assistants
  // ─────────────────────────────────────────────────
  void generateTopAssistants() {
    // Collect all players from all teams
    final allPlayers = teams.expand((team) => team.players).toList();
    // Keep only players with assists > 0
    final assistants = allPlayers.where((p) => p.assists > 0).toList();
    // Sort by assists descending
    assistants.sort((a, b) => b.assists.compareTo(a.assists));
    // Store in topAssistants list
    topAssistants = assistants.cast<Player>();
  }
}
