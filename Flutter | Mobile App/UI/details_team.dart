import 'package:flutter/material.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/team_model.dart';
import 'package:offside/models/player_model.dart';
import 'package:offside/pages_details/details_match.dart';
import 'package:offside/pages_details/details_player.dart';

class TeamDetailsPage extends StatefulWidget {
  final Team team;
  final League league;

  const TeamDetailsPage({super.key, required this.team, required this.league});

  @override
  State<TeamDetailsPage> createState() => _TeamDetailsPageState();
}

class _TeamDetailsPageState extends State<TeamDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color navy = const Color(0xFF0D1956);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D25),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.star_border, color: Colors.white),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Header (Logo + Name + Country)
          Column(
            children: [
               Image.asset( 
                widget.team.logo,
                height: 150,
                width: 150,
              ),
              
              const SizedBox(height: 10),
              Text(
                widget.team.name,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                "Egypt",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ✅ TabBar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C223C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.tealAccent[400],
              ),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white,
              tabs: const [
                Tab(text: "Matches"),
                Tab(text: "Standings"),
                Tab(text: "Players"),
              ],
            ),
          ),

          // ✅ Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Matches Tab
              // Matches Tab
Builder(
  builder: (context) {
    // فلترة ماتشات الفريق من كل ماتشات الدوري
    final teamMatches = widget.league.matches.where((m) {
      return m.homeTeam.name == widget.team.name ||
             m.awayTeam.name == widget.team.name;
    }).toList();

    if (teamMatches.isEmpty) {
      return const Center(
        child: Text(
          "No matches found for this team",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teamMatches.length,
      itemBuilder: (context, index) {
        final match = teamMatches[index];
      return InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchDetailsPage(match: match, league: widget.league),
      ),
    );
  },
  child: Card(
    color: const Color(0xFF1C223C),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // League + Round
          Text(
            widget.league.name,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),

          // Teams + Score/Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Home Team
              Row(
                children: [
                  Image.asset(match.homeTeam.logo, width: 28, height: 28),
                  const SizedBox(width: 6),
                  Text(match.homeTeam.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),

              // Score OR Time
              Column(
                children: [
                  Text(
                    "${match.homeTeamScore} - ${match.awayTeamScore}",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    match.date.toString(),
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),

              // Away Team
              Row(
                children: [
                  Text(match.awayTeam.name,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Image.asset(match.awayTeam.logo, width: 28, height: 28),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

      },
    );
  },
),


                
                

                // Standings Tab
                Builder(
  builder: (context) {
    // ترتيب الفرق بالمنطق بتاع الكورة
  // ترتيب الفرق
   // احسب الترتيب من الصفر
widget.league.updateStandings();
final sortedTeams = [...widget.league.teams]..sort((a, b) {
  final pointsA = a.points ?? 0;
  final pointsB = b.points ?? 0;
  if (pointsB != pointsA) return pointsB.compareTo(pointsA);
  if (pointsB != pointsA) return pointsB.compareTo(pointsA);

  final diffA = (a.goalsFor ?? 0) - (a.goalsAgainst ?? 0);
  final diffB = (b.goalsFor ?? 0) - (b.goalsAgainst ?? 0);
  if (diffB != diffA) return diffB.compareTo(diffA);

  final goalsForA = a.goalsFor ?? 0;
  final goalsForB = b.goalsFor ?? 0;
  if (goalsForB != goalsForA) return goalsForB.compareTo(goalsForA);

  return a.name.compareTo(b.name);
});


    return Container(
  margin: const EdgeInsets.all(8),
  decoration: BoxDecoration(
    color: const Color(0xFF0D1956),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: ListView(
    
    padding: const EdgeInsets.all(8),
    children: [
      DataTable(
        columnSpacing: 18,
        headingRowHeight: 45,
        dataRowHeight: 45,
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
        headingRowColor: WidgetStateColor.resolveWith(
            (states) => const Color(0xFF091142)),
        headingTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Team')),
          DataColumn(label: Text('P')),
          DataColumn(label: Text('W')),
          DataColumn(label: Text('D')),
          DataColumn(label: Text('L')),
          DataColumn(label: Text('Goals')),
          DataColumn(label: Text('Diff')),
          DataColumn(label: Text('Pts')),
        ],
        rows: List.generate(

          sortedTeams.length,
          (index) {
            final t = sortedTeams[index];
            

            // ألوان المراكز
            Color rankColor;
            if (index < 4) {
              rankColor = Colors.green; // Champions League
            } else if (index < 6) {
              rankColor = Colors.blue; // Europa League
            } else if (index >= sortedTeams.length - 3) {
              rankColor = Colors.red; // Relegation
            } else {
              rankColor = Colors.white;
            }

            return DataRow(
  color: WidgetStateColor.resolveWith(
    (states) => index.isEven
        ? const Color(0xFF16246E)
        : const Color(0xFF1C2C7A),
  ),
  
  
  cells: [
    DataCell(Text(
      '${index + 1}',
      style: TextStyle(
        color: rankColor,
        fontWeight: FontWeight.bold,
      ),
    )),
    
    DataCell(
  Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.asset(t.logo, width: 26, height: 26),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: GestureDetector(
        
          child: Text(
            t.name,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ),
    ],
  ),
),

    DataCell(Text('${t.played ?? 0}', style: const TextStyle(color: Colors.white))),
    DataCell(Text('${t.wins ?? 0}', style: const TextStyle(color: Colors.white))),
    DataCell(Text('${t.draw ?? 0}', style: const TextStyle(color: Colors.white))),
    DataCell(Text('${t.losses ?? 0}', style: const TextStyle(color: Colors.white))),
    DataCell(Text('${t.goalsFor ?? 0}:${t.goalsAgainst ?? 0}',
        style: const TextStyle(color: Colors.white))),
    DataCell(Text(
      '${(t.goalsFor ?? 0) - (t.goalsAgainst ?? 0)}',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
    )),
    DataCell(Text('${t.points ?? 0}',
        style: TextStyle(
            color: rankColor,
            fontWeight: FontWeight.bold,
            fontSize: 14))),
  ],
);

          },
        ),
      ),
    ],
  ),
);
  },
),

                // Players Tab
                _buildPlayersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildPlayersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.team.players.length,
      itemBuilder: (context, index) {
        Player player = widget.team.players[index];
          
        return InkWell(
          onTap: () {
 Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerDetailsPage(player: player),
            ),
          );
          },
          child: Card(
            color: const Color(0xFF1C223C),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                  
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          player.position,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "#${player.number}",
                    style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ),
          ));
        },
      );
    }
  }
