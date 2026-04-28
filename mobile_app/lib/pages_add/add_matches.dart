import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/match_model.dart';
import 'package:offside/models/team_model.dart';
import 'package:intl/intl.dart';
import 'package:offside/pages_details/details_league.dart';
import 'package:offside/services/sync_service.dart';

class CreateMatchPage extends StatefulWidget {
  final List<Team> teams;
  final String leagueLogo;
  final String leagueName;
  final DateTime? startDate;
  final DateTime? endDate;

  const CreateMatchPage({
    super.key,
    required this.teams,
    required this.leagueLogo,
    required this.leagueName,
    this.startDate,
    this.endDate,
  });

  @override
  State<CreateMatchPage> createState() => _CreateMatchPageState();
}

class _CreateMatchPageState extends State<CreateMatchPage> {
  List<Match2> matches = [];
  bool _isSyncing = false;

  void createMatch() {
    setState(() {
      matches.clear();
      final shuffledTeams = List<Team>.from(widget.teams)..shuffle();

      for (int i = 0; i < shuffledTeams.length; i++) {
        for (int j = i + 1; j < shuffledTeams.length; j++) {
          matches.add(Match2(
            homeTeam: shuffledTeams[i],
            awayTeam: shuffledTeams[j],
            date: widget.startDate ?? DateTime.now(),
          ));
        }
      }
    });
  }

  Future<void> pickDateTime(int index) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: matches[index].date,
      firstDate: widget.startDate ?? DateTime(2020),
      lastDate: widget.endDate ?? DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(matches[index].date),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      matches[index] = Match2(
        homeTeam: matches[index].homeTeam,
        awayTeam: matches[index].awayTeam,
        date: DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute),
      );
    });
  }

  Future<void> saveMatches() async {
    setState(() => _isSyncing = true);
    try {
      final leagueBox = await Hive.openBox<League>('leagues');
      final league = League(
        logo: widget.leagueLogo,
        name: widget.leagueName,
        teams: widget.teams,
        matches: matches,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
      await leagueBox.add(league);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ League saved locally!")));

      // Syncing everything to backend based on the ER Diagram
      await SyncService.syncLeagueToBackend(league);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🚀 Full sync to backend successful!"), backgroundColor: Colors.green),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LeaguePage(league: league)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Sync Error: $e"), backgroundColor: Colors.red));
      // Still navigate if it's just a backend error, as it's saved locally
      final leagueBox = Hive.box<League>('leagues');
      if (leagueBox.isNotEmpty) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LeaguePage(league: leagueBox.values.last)));
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd – HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leagueName),
        actions: [
          if (_isSyncing)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))))
          else
            IconButton(icon: const Icon(Icons.cloud_upload), onPressed: matches.isEmpty ? null : saveMatches),
        ],
      ),
      body: Column(
        children: [
          if (widget.startDate != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Tournament Duration: ${DateFormat('MMM dd').format(widget.startDate!)} - ${DateFormat('MMM dd, yyyy').format(widget.endDate!)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            ),
          Expanded(
            child: matches.isEmpty
                ? const Center(child: Text("⚽ Tap 'Create Matches' to generate the schedule"))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final m = matches[index];
                      return Card(
                        child: ListTile(
                          leading: Image.asset(m.homeTeam.logo, width: 30),
                          title: Text("${m.homeTeam.name} vs ${m.awayTeam.name}", style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(dateFormat.format(m.date)),
                          trailing: IconButton(icon: const Icon(Icons.event, color: Colors.blue), onPressed: () => pickDateTime(index)),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: createMatch,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Generate Round Robin Schedule"),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
