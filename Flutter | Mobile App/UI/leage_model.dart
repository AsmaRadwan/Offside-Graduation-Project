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

  League({
    required this.logo,
    required this.name,
    required this.teams,
    required this.matches,
    this.topScorers,
    this.topAssistants,
  });

  /// 🔥 دي الدالة اللي بتعيد حساب الترتيب
  void updateStandings() {
    // صفر الإحصائيات الأول
    for (var t in teams) {
      t.played = 0;
      t.wins = 0;
      t.draw = 0;
      t.losses = 0;
      t.goalsFor = 0;
      t.goalsAgainst = 0;
      t.points = 0;
    }

    // امشي على الماتشات واحسب
    for (var m in matches) {
      if (m.homeTeamScore == null || m.awayTeamScore == null) {
        continue; // لو الماتش ما اتلعبش، تجاهله
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

  // Generate top scorers
  void generateTopScorers() {
    // نجمع كل اللاعبين من كل الفرق
    final allPlayers = teams.expand((team) => team.players).toList();

    // ناخد بس اللي عندهم اهداف > 0
    final scorers =
        allPlayers.where((player) => (player.goals) > 0).toList();

    // نرتبهم حسب الأهداف تنازلي
    scorers.sort((a, b) => b.goals.compareTo(a.goals as num));

    // نخزنهم في ليست topScorers
    topScorers = scorers.cast<Player>();
  }

  // Generate top assistants
  void generateTopAssistants() {
    // نجمع كل اللاعبين من كل الفرق
    final allPlayers = teams.expand((team) => team.players).toList();

    // ناخد بس اللي عندهم أسيست > 0
    final assistants =
        allPlayers.where((player) => player.assists > 0).toList();

    // نرتبهم حسب الأسيست تنازلي
    assistants.sort((a, b) => b.assists.compareTo(a.assists as num));

    // نخزنهم في ليست topAssistants
    topAssistants = assistants.cast<Player>();
  }
}
