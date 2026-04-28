import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  static const String baseUrl = 'https://gsvowvzdxphlguclawur.supabase.co/rest/v1';
  static const String supabaseAnonKey = "sb_publishable_vuHhBKjf4kJJgPnkFlNm9A_ErI2gVd_"; 

  static Uri _uri(String path) {
    String cleanPath = path.startsWith('/') ? path : '/$path';
    if (cleanPath.endsWith('/')) {
      cleanPath = cleanPath.substring(0, cleanPath.length - 1);
    }
    return Uri.parse('$baseUrl$cleanPath');
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'apikey': supabaseAnonKey,
    'Authorization': 'Bearer $supabaseAnonKey',
    'Prefer': 'return=representation',
  };

  static dynamic _handleResponse(http.Response res) {
    print("📡 [API Response] ${res.statusCode} | ${res.body}");
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      final decoded = jsonDecode(res.body);
      if (decoded is List && decoded.isNotEmpty) return decoded.first;
      return decoded;
    } else {
      throw ApiException(statusCode: res.statusCode, message: res.body);
    }
  }

  // 🔹 FETCH Methods
  static Future<List<dynamic>> getAllPlayers() async {
    final res = await http.get(_uri('PLAYERS'), headers: _headers);
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw ApiException(statusCode: res.statusCode, message: res.body);
  }

  // 🔹 INVITATIONS Table (UPPERCASE to match schema)
  static Future<Map<String, dynamic>> sendInvitation({
    required String teamName,
    required String leagueName,
    required String playerName,
    required String playerId,
    required int jerseyNumber,
  }) async {
    final res = await http.post(
      _uri('INVITATIONS'), 
      headers: _headers, 
      body: jsonEncode({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'team_name': teamName,
        'league_name': leagueName,
        'player_name': playerName,
        'player_id': playerId,
        'jersey_number': jerseyNumber,
        'status': 'pending',
        'timestamp': DateTime.now().toIso8601String(),
      })
    );
    return _handleResponse(res);
  }

  static Future<void> updateInvitationStatus(String inviteId, String status) async {
    await http.patch(
      _uri('INVITATIONS'),
      headers: _headers,
      body: jsonEncode({'status': status}),
    );
  }

  // 🔹 Generic CREATE Methods
  static Future<Map<String, dynamic>> createUser({required String name, required String email, required String nationality, required String phoneNumber}) async {
    final res = await http.post(_uri('USERS'), headers: _headers, body: jsonEncode({'user_id': DateTime.now().millisecondsSinceEpoch, 'name': name, 'email': email, 'nationality': nationality, 'phone_number': phoneNumber}));
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> createPlayer({required String fullName, required int jerseyNumber, required String nationality, required double height, required double weight, required String position, required String email, required String phoneNumber, dynamic teamId}) async {
    final res = await http.post(_uri('PLAYERS'), headers: _headers, body: jsonEncode({'player_id': DateTime.now().millisecondsSinceEpoch, 'full_name': fullName, 'jersey_number': jerseyNumber, 'nationality': nationality, 'height': height, 'weight': weight, 'position': position, 'email': email, 'phone_number': phoneNumber, if (teamId != null) 'team_id': teamId}));
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> createTournament({required String name, required DateTime startDate, required DateTime endDate}) async {
    final res = await http.post(_uri('tournaments'), headers: _headers, body: jsonEncode({'tournament_id': DateTime.now().millisecondsSinceEpoch, 'tournament_name': name, 'start_date': startDate.toIso8601String(), 'end_date': endDate.toIso8601String()}));
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> createTeam({required String name, required String primaryColor, required String secondaryColor}) async {
    final res = await http.post(_uri('TEAMS'), headers: _headers, body: jsonEncode({'team_id': DateTime.now().millisecondsSinceEpoch, 'team_name': name, 'tshirt_colors': {'primary': primaryColor, 'secondary': secondaryColor}}));
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> createMatch({required dynamic tournamentId, required dynamic homeTeamId, required dynamic awayTeamId, required DateTime matchDate, String? videoUrl}) async {
    final res = await http.post(_uri('MATCHES'), headers: _headers, body: jsonEncode({'match_id': DateTime.now().millisecondsSinceEpoch, 'tournament_id': tournamentId, 'home_team_id': homeTeamId, 'away_team_id': awayTeamId, 'match_date': matchDate.toIso8601String(), 'video_url': videoUrl ?? ""}));
    return _handleResponse(res);
  }

  // 🔹 STATS Methods
  static Future<Map<String, dynamic>> submitTeamStats({required dynamic matchId, required dynamic teamId, required int goals, required int passes, required int fouls, required int corners}) async {
    final res = await http.post(_uri('TEAM_MATCH_STATS'), headers: _headers, body: jsonEncode({'team_stat_id': DateTime.now().millisecondsSinceEpoch, 'match_id': matchId, 'team_id': teamId, 'goals': goals, 'passes': passes, 'foul': fouls, 'corner': corners}));
    return _handleResponse(res);
  }

  static Future<Map<String, dynamic>> submitPlayerStats({required dynamic matchId, required dynamic playerId, required int goals, required int assists, required int yellowCard, required int redCard, required double topSpeed, required double totalDistance}) async {
    final res = await http.post(_uri('PLAYER_MATCH_STATS'), headers: _headers, body: jsonEncode({'player_stat_id': DateTime.now().millisecondsSinceEpoch, 'match_id': matchId, 'player_id': playerId, 'goals': goals, 'assists': assists, 'yellow_card': yellowCard, 'red_card': redCard, 'top_speed': topSpeed, 'total_distance': totalDistance}));
    return _handleResponse(res);
  }

  static Future<bool> ping() async {
    try {
      final res = await http.get(_uri('PLAYERS'), headers: _headers).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException({required this.statusCode, required this.message});
  @override
  String toString() => 'Error $statusCode: $message';
}
