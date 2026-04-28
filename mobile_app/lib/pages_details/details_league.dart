import 'package:flutter/material.dart';
import 'package:offside/models/match_model.dart';
import 'package:offside/pages_details/details_match.dart';
import 'package:offside/pages_details/details_player.dart';
import '../models/leage_model.dart';
import 'package:intl/intl.dart';

class LeaguePage extends StatelessWidget {
  final League league;
  const LeaguePage({super.key, required this.league});



  @override
  Widget build(BuildContext context) {
      league.generateTopScorers();
      league.generateTopAssistants();

    final matchesSorted = league.matches..sort((a, b) => a.date.compareTo(b.date));

    final matchesByDate = <String, List<Match2>>{};
    for (var m in matchesSorted) {
      String dateKey = DateFormat('yyyy-MM-dd').format(m.date);
      matchesByDate.putIfAbsent(dateKey, () => []).add(m);
    }

    final Color bg = const Color(0xFFFAFAFC);
    final Color matchCardColor = const Color(0xFF0D1956);
    final Color leagueColor = const Color(0xFF16246E);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: bg,
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(250),
  child: ClipRRect(
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
    child: AppBar(
      backgroundColor: leagueColor,
      automaticallyImplyLeading: false,
      toolbarHeight: 200,
      title: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Image.asset(
                league.logo,
                width: 150,
                height: 150,
              ),
              Row(
                children: const [
                
                  Icon(Icons.star_border, color: Colors.white),
                  SizedBox(width: 25),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            league.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      bottom: const TabBar(
        indicatorColor: Colors.yellow,
        labelColor: Colors.yellow,
        unselectedLabelColor: Colors.white,
        tabs: [
          Tab(text: "Matches"),
          Tab(text: "Teams"),
          Tab(text: "Players"),
        ],
      ),
    ),
  ),
),

        body: TabBarView(
          children: [
            // Matches tab
            ListView(
  children: matchesByDate.entries.map((entry) {
    final matches = entry.value;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: leagueColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              DateFormat('EEEE dd-MM-yyyy').format(matches.first.date),
              style:  TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: leagueColor,
              ),
            ),
          ),
          const SizedBox(height: 10),

          ...matches.map((m) {
            final now = DateTime.now();
            final isUpcoming = now.isBefore(m.date);
            final isLive = now.isAfter(m.date) &&
                now.isBefore(m.date.add(const Duration(minutes: 30)));
            final isFinished = now.isAfter(m.date.add(const Duration(minutes: 30)));

            String statusText;
            Color statusColor = Colors.white;
            BoxDecoration statusBox = BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            );

            if (isUpcoming) {
              statusText = DateFormat('HH:mm').format(m.date);
            } else if (isLive) {
              statusText = "LIVE ${m.homeTeamScore} - ${m.awayTeamScore}";
              statusColor = Colors.red;
              statusBox = BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              );
            } else if (isFinished) {
              statusText = "${m.homeTeamScore} - ${m.awayTeamScore}";
              statusColor = Colors.greenAccent;
              statusBox = BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              );
            } else {
              statusText = "";
            }

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchDetailsPage(
                      match: m,
                      league: league,
                    ),
                  ),
                );
              },
              child: Card(
                color: matchCardColor,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // الفريق الأول
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(m.homeTeam.logo),
                              radius: 18,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                m.homeTeam.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: statusBox,
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight:
                              isLive ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              m.awayTeam.name,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundImage: AssetImage(m.awayTeam.logo),
                            radius: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
          }),
        ],
      ),
    );
  }).toList(),
)
,

          // Teams tab
Builder(
  builder: (context) {

league.updateStandings();
final sortedTeams = [...league.teams]..sort((a, b) {
  final pointsA = a.points ?? 0;
  final pointsB = b.points ?? 0;

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
  
// 🟢 Players tab with fancy pill tabs
DefaultTabController(
  length: 2,
  child: Column(
    children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const TabBar(
          indicator: BoxDecoration(
            color: Color(0xFF0D1956),
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black87,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: TextStyle(fontSize: 14),
          tabs: [
            Tab(text: "Top Scorers"),
            Tab(text: "Top Assists"),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          children: [
            // 🟢 Top Scorers
            (league.topScorers != null && league.topScorers!.isNotEmpty)
                ? ListView.builder(
                  
                    itemCount: league.topScorers!.length,
                    itemBuilder: (context, index) {
                      final player = league.topScorers![index];
                      
                      return Card(
                        
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerDetailsPage(player: player),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF0D1956),
                            backgroundImage: player.image != null
                                ? AssetImage(player.image!)
                                : null,
                            child: player.image == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            player.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(player.position),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${player.goals} goals",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      "No scorers available",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

            // 🟢 Top Assists
            (league.topAssistants != null && league.topAssistants!.isNotEmpty)
                ? ListView.builder(
                    itemCount: league.topAssistants!.length,
                    itemBuilder: (context, index) {
                      final player = league.topAssistants![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlayerDetailsPage(player: player),
                            ),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF0D1956),
                            backgroundImage: player.image != null
                                ? AssetImage(player.image!)
                                : null,
                            child: player.image == null
                                ? const Icon(Icons.person, color: Colors.white)
                                : null,
                          ),
                          title: Text(
                            player.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(player.position),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${player.assists} assists",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Text(
                      "No assistants available",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ],
        ),
      ),
    ],
  ),
)
          ],
        ),
      ),
    );
  }
}
