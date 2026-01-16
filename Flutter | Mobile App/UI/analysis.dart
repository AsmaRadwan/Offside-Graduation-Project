import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/team_model.dart';
import 'package:offside/pages_details/details_league.dart';
import 'package:offside/pages_details/details_team.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final leaguesBox = Hive.box<League>('leagues');

  List<Team> allTeams = [];
  List<League> allLeagues = [];

  List<Team> filteredTeams = [];
  List<League> filteredLeagues = [];

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() {
    final leagues = leaguesBox.values.toList();
    List<Team> loadedTeams = [];

    for (final league in leagues) {
      loadedTeams.addAll(league.teams);
    }

    setState(() {
      allLeagues = leagues;
      allTeams = loadedTeams;

      filteredTeams = allTeams;
      filteredLeagues = allLeagues;
    });
  }

  void onSearch(String text) {
    searchQuery = text.toLowerCase();

    setState(() {
      if (searchQuery.isEmpty) {
        filteredTeams = allTeams;
        filteredLeagues = allLeagues;
      } else {
        filteredTeams = allTeams
            .where((t) => t.name.toLowerCase().contains(searchQuery))
            .toList();

        filteredLeagues = allLeagues
            .where((l) => l.name.toLowerCase().contains(searchQuery))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ============================
            // TOP LOGO HORIZONTAL SCROLL
            // ============================
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: filteredTeams.length,
                itemBuilder: (context, index) {
                  final team = filteredTeams[index];
                  return GestureDetector(
                    onTap: () {
                      final league =
                          allLeagues.firstWhere((l) => l.teams.contains(team));

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TeamDetailsPage(team: team, league: league),
                        ),
                      );
                    },
                    child: Container(
                      width: 65,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xFF16246E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: Image.asset(team.logo),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ============================
            // SEARCH BAR
            // ============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: TextField(
                  onChanged: onSearch,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Search teams or leagues...",
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ============================
            // LEAGUES LIST ONLY
            // ============================
            Expanded(
              child: ListView.builder(
                
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: filteredLeagues.length,
                itemBuilder: (context, index) {
                  final league = filteredLeagues[index];
                  
                  return leagueTile(league);
                  
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // LEAGUE CARD
  // ================================
  Widget leagueTile(League league) {
    
    return GestureDetector(
        onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => LeaguePage(league: league)));
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFF16246E),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
        ],
      ),
      child: Row(children: [
          Image.asset(league.logo, width: 45, height: 45),
          const SizedBox(width: 12),
          Text(
            league.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.white
            ),
          ),
        ],
      ),
      ),
    );
  }
}
