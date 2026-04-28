import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/match_model.dart';
import 'package:offside/pages_details/details_league.dart';
import 'package:offside/pages_add/add_Score_match.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final Color leagueColor = const Color(0xFF16246E);

  DateTime selectedDate = DateTime.now();
  String searchQuery = "";

  String formatDate(DateTime date) {
    return DateFormat("EEEE, dd/MM/yyyy").format(date);
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('asset/logo2.png', fit: BoxFit.contain),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.subtract(const Duration(days: 1));
              });
            },
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          ),
          IconButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) setState(() => selectedDate = picked);
            },
            icon: const Icon(Icons.calendar_month, color: Colors.black87),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.add(const Duration(days: 1));
              });
            },
            icon: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black87),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search team or league...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
            const SizedBox(height: 14),
            if (searchQuery.isEmpty)
              Text(formatDate(selectedDate), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ValueListenableBuilder<Box<League>>(
                valueListenable: Hive.box<League>('leagues').listenable(),
                builder: (context, box, _) {
                  final allLeagues = box.values.toList();
                  if (allLeagues.isEmpty) {
                    return const Center(child: Text("No leagues or matches found"));
                  }

                  return ListView.builder(
                    itemCount: allLeagues.length,
                    itemBuilder: (context, lIdx) {
                      final league = allLeagues[lIdx];
                      
                      // Filter matches: if searching, ignore date. If not searching, filter by selectedDate.
                      List<Match2> displayMatches;
                      if (searchQuery.isNotEmpty) {
                        displayMatches = league.matches.where((m) =>
                          m.homeTeam.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                          m.awayTeam.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                          league.name.toLowerCase().contains(searchQuery.toLowerCase())
                        ).toList();
                      } else {
                        displayMatches = league.matches.where((m) => isSameDay(m.date, selectedDate)).toList();
                      }

                      if (displayMatches.isEmpty) return const SizedBox.shrink();

                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [leagueColor, leagueColor.withOpacity(0.85)]),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(league.logo, width: 32, height: 32),
                                  const SizedBox(width: 10),
                                  Text(league.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Divider(color: Colors.white30),
                              ...displayMatches.map((match) {
                                final matchIdx = league.matches.indexOf(match);
                                return GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddScorePage(matchIndex: matchIdx, leagueIndex: lIdx))),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Row(children: [Image.asset(match.homeTeam.logo, width: 24), const SizedBox(width: 8), Flexible(child: Text(match.homeTeam.name, style: const TextStyle(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis))])),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            match.homeTeamScore == null ? DateFormat('HH:mm').format(match.date) : "${match.homeTeamScore} - ${match.awayTeamScore}",
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Flexible(child: Text(match.awayTeam.name, style: const TextStyle(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis)), const SizedBox(width: 8), Image.asset(match.awayTeam.logo, width: 24)])),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
