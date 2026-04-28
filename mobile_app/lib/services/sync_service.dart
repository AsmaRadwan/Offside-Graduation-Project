import 'package:offside/models/leage_model.dart';
import 'package:offside/models/match_model.dart';
import 'api_service.dart';

class SyncService {
  /// Orchestrates the full sync of a League, its Teams, Players, and Matches based on the Supabase schema.
  static Future<void> syncLeagueToBackend(League league) async {
    try {
      print("📡 [Sync] Starting Full League Sync: ${league.name}");

      // 1. Create tournament
      final tournament = await ApiService.createTournament(
        name: league.name,
        startDate: league.startDate ?? DateTime.now(),
        endDate: league.endDate ?? DateTime.now().add(const Duration(days: 30)),
      );
      
      final tId = tournament['id'] ?? tournament['tournament_id'];
      if (tId == null) throw Exception("Failed to get Tournament ID from backend");
      league.backendId = tId.toString();
      print("✅ [Sync] Tournament Created: ${league.backendId}");

      // 2. Create Teams & Players
      for (final team in league.teams) {
        final remoteTeam = await ApiService.createTeam(
          name: team.name,
          primaryColor: team.primaryColor ?? "#0000FF",
          secondaryColor: team.secondaryColor ?? "#FFFFFF",
        );
        
        final tmId = remoteTeam['id'] ?? remoteTeam['team_id'];
        if (tmId == null) continue;
        team.backendId = tmId.toString();
        print("✅ [Sync] Team Created: ${team.name} | ID: ${team.backendId}");

        // 3. Create Players for THIS Team
        for (final player in team.players) {
          try {
            final remotePlayer = await ApiService.createPlayer(
              fullName: player.name,
              jerseyNumber: player.number,
              nationality: player.nationality,
              height: player.height ?? 175.0,
              weight: player.weight ?? 70.0,
              position: player.position,
              email: "player_${DateTime.now().millisecondsSinceEpoch}_${player.number}@offside.com", 
              phoneNumber: "01000000000",
              teamId: team.backendId, 
            );
            
            final pId = remotePlayer['id'] ?? remotePlayer['player_id'];
            if (pId != null) {
              player.backendId = pId.toString();
              print("✅ [Sync] Player Created: ${player.name} in Team ${team.name}");
            }
          } catch (e) {
            print("❌ [Sync] Error creating player ${player.name}: $e");
          }
        }
      }

      // 4. Create Matches
      for (final match in league.matches) {
        final dynamic hId = match.homeTeam.backendId;
        final dynamic aId = match.awayTeam.backendId;

        if (league.backendId != null && hId != null && aId != null) {
          final remoteMatch = await ApiService.createMatch(
            tournamentId: league.backendId!,
            homeTeamId: hId,
            awayTeamId: aId,
            matchDate: match.date,
            videoUrl: match.videoUrl,
          );
          
          final mId = remoteMatch['id'] ?? remoteMatch['match_id'];
          if (mId != null) {
            match.backendId = mId.toString();
            print("✅ [Sync] Match Created: ${match.homeTeam.name} vs ${match.awayTeam.name}");
          }
        }
      }

      await league.save();
      print("🏁 [Sync] Full League Sync Completed Successfully!");
    } catch (e) {
      print("❌ [Sync] Critical Sync Error: $e");
      rethrow;
    }
  }

  /// Syncs individual match results (Score and Statistics) to the backend.
  static Future<void> syncMatchResult(Match2 match, League league, {bool isFinished = false}) async {
    if (match.backendId == null) {
      print("⚠️ [Sync Stats] Match has no backendId. Sync failed.");
      return;
    }

    try {
      print("📡 [Sync Stats] Starting stats sync for match: ${match.homeTeam.name} vs ${match.awayTeam.name}");

      // 1. Submit Home Team Stats
      if (match.homeTeam.backendId != null) {
        await ApiService.submitTeamStats(
          matchId: match.backendId!,
          teamId: match.homeTeam.backendId!,
          goals: match.homeTeamScore ?? 0,
          passes: match.homeTeam.players.fold(0, (sum, p) => sum + p.passes),
          fouls: match.eventsHome.where((e) => e.type.toLowerCase().contains('foul') || e.type.toLowerCase().contains('card')).length,
          corners: match.eventsHome.where((e) => e.type.toLowerCase().contains('corner')).length,
        );
      }

      // 2. Submit Away Team Stats
      if (match.awayTeam.backendId != null) {
        await ApiService.submitTeamStats(
          matchId: match.backendId!,
          teamId: match.awayTeam.backendId!,
          goals: match.awayTeamScore ?? 0,
          passes: match.awayTeam.players.fold(0, (sum, p) => sum + p.passes),
          fouls: match.eventsAway.where((e) => e.type.toLowerCase().contains('foul') || e.type.toLowerCase().contains('card')).length,
          corners: match.eventsAway.where((e) => e.type.toLowerCase().contains('corner')).length,
        );
      }

      // 3. Submit Individual Player Stats (Match-Specific, not career totals)
      final allParticipants = [...match.homeTeam.players, ...match.awayTeam.players];
      for (var player in allParticipants) {
        if (player.backendId != null) {
          final isHome = match.homeTeam.players.contains(player);
          final events = isHome ? match.eventsHome : match.eventsAway;
          final playerEvents = events.where((e) => e.player == player.name).toList();

          await ApiService.submitPlayerStats(
            matchId: match.backendId!,
            playerId: player.backendId!,
            goals: playerEvents.where((e) => e.type == 'Goal').length,
            assists: playerEvents.where((e) => e.assist == player.name).length,
            yellowCard: playerEvents.where((e) => e.type == 'Yellow Card').length,
            redCard: playerEvents.where((e) => e.type == 'Red Card').length,
            topSpeed: player.highestSpeed ?? 0.0,
            totalDistance: player.totalDistance ?? 0.0,
          );
        }
      }
      print("🏁 [Sync Stats] Match sync completed!");

    } catch (e) {
      print("❌ [Sync Stats] Error during statistics sync: $e");
      rethrow;
    }
  }
}
