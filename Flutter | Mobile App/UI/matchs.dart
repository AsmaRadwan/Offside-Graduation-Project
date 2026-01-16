import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/pages_details/details_league.dart';
import 'package:offside/pages_add/add_Score_match.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final Color matchCardColor = const Color(0xFF0D1956);
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
          padding: const EdgeInsets.all(0),
          child: Image.asset('asset/logo2.png', fit: BoxFit.contain),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset('asset/icons/filter.svg', width: 22),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.subtract(const Duration(days: 1));
              });
            },
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: Colors.black87),
          ),
          IconButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked;
                });
              }
            },
            icon: SvgPicture.asset("asset/icons/date.svg", width: 22),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedDate = selectedDate.add(const Duration(days: 1));
              });
            },
            icon: const Icon(Icons.arrow_forward_ios,
                size: 20, color: Colors.black87),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: "Search team...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              formatDate(selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ValueListenableBuilder<Box<League>>(
                valueListenable: Hive.box<League>('leagues').listenable(),
                builder: (context, box, _) {
                  if (box.values.isEmpty) {
                    return const Center(
                      child: Text(
                        "No leagues saved yet",
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    );
                  }

                  final leagues = box.values.toList();

                  return ListView.builder(
                    itemCount: leagues.length,
                    itemBuilder: (context, index) {
                      final league = leagues[index];

                      var matchesForDay = league.matches
                          .where((m) => isSameDay(m.date, selectedDate))
                          .toList();

                      if (searchQuery.isNotEmpty) {
                        matchesForDay = matchesForDay.where((m) {
                          return m.homeTeam.name
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase()) ||
                              m.awayTeam.name
                                  .toLowerCase()
                                  .contains(searchQuery.toLowerCase());
                        }).toList();
                      }

                      if (matchesForDay.isEmpty) return const SizedBox();

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeaguePage(league: league),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  leagueColor,
                                  leagueColor.withOpacity(0.85),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(league.logo,
                                        width: 32, height: 32),
                                    const SizedBox(width: 10),
                                    Text(
                                      league.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Spacer(),
                                    PopupMenuButton<String>(
                                      color: Colors.white,
                                      onSelected: (value) {},
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                            value: "top",
                                            child: Text("Move to the Top")),
                                        const PopupMenuItem(
                                          value: "hide",
                                          child: Text(
                                            "Hide Championship",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ),
                                        const PopupMenuItem(
                                            value: "bottom",
                                            child: Text("Move to the Bottom")),
                                      ],
                                      icon: const Icon(Icons.more_vert,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.white30),
                                Column(
                                  children: matchesForDay.map((match) {
                                    final now = DateTime.now();
                                    final isUpcoming = now.isBefore(match.date);
                                    final isLive = now.isAfter(match.date) &&
                                        now.isBefore(match.date
                                            .add(const Duration(minutes: 30)));

                                    String statusText;
                                    Color statusColor = Colors.white;
                                    if (isUpcoming) {
                                      statusText = DateFormat('HH:mm')
                                          .format(match.date);
                                    } else if (isLive) {
                                      statusText =
                                          "LIVE   ${match.homeTeamScore} - ${match.awayTeamScore}";
                                      statusColor = Colors.redAccent;
                                    } else {
                                      if (match.homeTeamScore == null &&
                                          match.awayTeamScore == null) {
                                        match.homeTeamScore = 0;
                                        match.awayTeamScore = 0;
                                      }
                                      statusText =
                                          "${match.homeTeamScore} - ${match.awayTeamScore}";
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        final matchIndex =
                                            league.matches.indexOf(match);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddScorePage(
                                              matchIndex: matchIndex,
                                              leagueIndex: index,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white10,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Image.asset(match.homeTeam.logo,
                                                    width: 32, height: 32),
                                                const SizedBox(width: 8),
                                                Text(
                                                  match.homeTeam.name,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              statusText,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  match.awayTeam.name,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                ),
                                                const SizedBox(width: 8),
                                                Image.asset(match.awayTeam.logo,
                                                    width: 32, height: 32),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              ],
                            ),
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
