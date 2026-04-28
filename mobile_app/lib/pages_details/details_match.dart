import 'package:flutter/material.dart';
import 'package:offside/models/event_model.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/match_model.dart';
import 'package:offside/models/team_model.dart';
import 'package:offside/pages_details/details_team.dart';

class MatchDetailsPage extends StatelessWidget {
  final Match2 match;
  final League league;

  const MatchDetailsPage({
    super.key,
    required this.match,
    required this.league,
  });

  @override
  Widget build(BuildContext context) {
    const Color mainBg = Color(0xFFF0F2F8);
    const Color cardColor = Color(0xFF0D1956);
    const Color cardColor2 = Color(0xFF16246E);

    return Scaffold(
      backgroundColor: mainBg,
      appBar: AppBar(
        backgroundColor: mainBg,
        elevation: 0,
        title: const Text(
          "Match Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: const BackButton(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ================= HEADER =================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cardColor, cardColor2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _teamBox(match.homeTeam, league, context),
                  Column(
                    children: [
                      Text(
                        "${match.homeTeamScore} - ${match.awayTeamScore}",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          match.status ?? "Ended",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  _teamBox(match.awayTeam, league, context),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ================= TITLE =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Match Events",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87.withOpacity(0.85),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= EVENTS TIMELINE =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ...match.eventsHome.map(
                    (e) => _eventTimeline(e, true),
                  ),
                  ...match.eventsAway.map(
                    (e) => _eventTimeline(e, false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // =========================================================
  //                 TEAM BOX (LOGO + NAME)
  // =========================================================
  Widget _teamBox(Team team, League league, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TeamDetailsPage(team: team, league: league),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Image.asset(
              team.logo,
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            team.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  //                      EVENT TIMELINE
  // =========================================================
  Widget _eventTimeline(Event event, bool isHomeTeam) {
    IconData icon;
    Color color;

    switch (event.type) {
      case "Goal":
        icon = Icons.sports_soccer;
        color = Colors.green;
        break;
      case "Yellow Card":
        icon = Icons.square;
        color = Colors.yellow.shade700;
        break;
      case "Red Card":
        icon = Icons.square;
        color = Colors.red;
        break;
      case "Offside":
        icon = Icons.flag;
        color = Colors.redAccent;
        break;
      case "Substitution":
        icon = Icons.compare_arrows;
        color = Colors.orange;
        break;
      case "Shot":
        icon = Icons.sports;
        color = Colors.blue;
        break;
      case "Corner Kick":
        icon = Icons.sports_soccer_outlined;
        color = Colors.teal;
        break;
      case "Free Kick":
        icon = Icons.sports;
        color = Colors.indigo;
        break;

      default:
        icon = Icons.info;
        color = Colors.blueGrey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          // ================= LEFT SIDE =================
          Expanded(
            child: isHomeTeam
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        event.player,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, color: color, size: 22),
                    ],
                  )
                : const SizedBox(),
          ),

          // ================= CENTER LINE =================
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  "${event.minute}'",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 2,
                  height: 40,
                  color: Colors.black26,
                ),
              ],
            ),
          ),

          // ================= RIGHT SIDE =================
          Expanded(
            child: !isHomeTeam
                ? Row(
                    children: [
                      Icon(icon, color: color, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        event.player,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}
