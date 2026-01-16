import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/match_model.dart';
import 'package:offside/models/team_model.dart';
import 'package:intl/intl.dart';
import 'package:offside/pages_details/details_league.dart'; // لعرض التاريخ والوقت بشكل منسق

class CreateMatchPage extends StatefulWidget {
  final List<Team> teams;
  final String leagueLogo;
  final String leagueName;

  const CreateMatchPage({
    super.key,
    required this.teams,
    required this.leagueLogo,
    required this.leagueName,
  });

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  List<Match2> matches = [];

  void createMatch() {
    setState(() {
      matches.clear();
      final shuffledTeams = List<Team>.from(widget.teams)..shuffle(); // Shuffle

      for (int i = 0; i < shuffledTeams.length; i++) {
        for (int j = i + 1; j < shuffledTeams.length; j++) {
          matches.add(Match2(
            homeTeam: shuffledTeams[i],
            awayTeam: shuffledTeams[j],
            date: DateTime.now(),
          ));
        }
      }
    });
  }

  Future<void> pickDateTime(int index) async {
    // اختار التاريخ
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: matches[index].date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    // اختار الوقت
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(matches[index].date),
    );

    if (pickedTime == null) return;

    // دمج التاريخ مع الوقت
    final newDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      matches[index] = Match2(
        homeTeam: matches[index].homeTeam,
        awayTeam: matches[index].awayTeam,
        date: newDateTime,
      );
    });
  }

  Future<void> saveMatches() async {
    final leagueBox = await Hive.openBox<League>('leagues');
    League league = League(
      logo: widget.leagueLogo,
      name: widget.leagueName,
      teams: widget.teams,
      matches: matches,
    );
    await leagueBox.add(league);
    await leagueBox.flush(); // <--- إضافة هذا السطر لضمان الحفظ الفوري
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ League '${widget.leagueName}' with matches saved!")),
    );
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LeaguePage(league: league)));
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd – HH:mm'); // تنسيق التاريخ + الساعة

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Matches - ${widget.leagueName}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            onPressed: matches.isEmpty ? null : saveMatches,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: matches.isEmpty
                ? const Center(
                    child: Text("⚽ No matches yet. Click below to create."),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final match = matches[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 4,
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(match.homeTeam.logo), // لوجو الفريق الأول
                                radius: 18,
                              ),
                              const SizedBox(width: 5),
                              CircleAvatar(
                                backgroundImage: AssetImage(match.awayTeam.logo), // لوجو الفريق الثاني
                                radius: 18,
                              ),
                            ],
                          ),
                          title: Text(
                            "${match.homeTeam.name} 🆚 ${match.awayTeam.name}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "📅 ${dateFormat.format(match.date)}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit_calendar, color: Colors.blueAccent),
                            onPressed: () => pickDateTime(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: createMatch,
              icon: const Icon(Icons.add),
              label: const Text("Create Matches"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
