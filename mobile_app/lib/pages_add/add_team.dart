import 'package:flutter/material.dart';
import 'package:offside/models/team_model.dart';
import 'package:offside/pages_add/add_matches.dart';
import 'package:offside/pages_add/add_player.dart';

class CreateTeamPage extends StatefulWidget {
  final String leagueName;
  final String logo;
  final DateTime? startDate;
  final DateTime? endDate;

  const CreateTeamPage({
    super.key,
    required this.leagueName,
    required this.logo,
    this.startDate,
    this.endDate,
  });

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController primaryColorController = TextEditingController();
  final TextEditingController secondaryColorController = TextEditingController();
  List<Team> teams = [];
  int? selectedLogo;

  final List<String> teamLogos = List.generate(20, (index) => "asset/Teams_Logo/${index + 1}.png");

  void addTeam() async {
    String teamName = teamNameController.text.trim();
    String? teamLogo = selectedLogo != null ? teamLogos[selectedLogo!] : null;

    if (teamName.isNotEmpty && teamLogo != null) {
      final newTeam = await Navigator.push<Team>(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePlayersPage(
            team: Team(
              name: teamName,
              logo: teamLogo,
              players: [],
              primaryColor: primaryColorController.text,
              secondaryColor: secondaryColorController.text,
            ),
            leagueName: widget.leagueName, // Pass leagueName for invitations
          ),
        ),
      );

      if (newTeam != null) {
        setState(() {
          teams.add(newTeam);
        });
        teamNameController.clear();
        primaryColorController.clear();
        secondaryColorController.clear();
        selectedLogo = null;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Name and logo required")));
    }
  }

  void saveTeams() {
    if (teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Please add at least one team")));
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMatchPage(
          leagueLogo: widget.logo,
          leagueName: widget.leagueName,
          teams: teams,
          startDate: widget.startDate,
          endDate: widget.endDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: Text("Add Teams to ${widget.leagueName}"), backgroundColor: Colors.grey.shade100,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: teamNameController, decoration: const InputDecoration(labelText: "Team Name", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: TextField(controller: primaryColorController, decoration: const InputDecoration(labelText: "Primary Color (Hex)", border: OutlineInputBorder()))),
                const SizedBox(width: 10),
                Expanded(child: TextField(controller: secondaryColorController, decoration: const InputDecoration(labelText: "Secondary Color (Hex)", border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Select Team Logo", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: List.generate(teamLogos.length, (index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedLogo = index),
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: selectedLogo == index ? Colors.blue : Colors.grey[200],
                    child: Padding(padding: const EdgeInsets.all(4), child: Image.asset(teamLogos[index])),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: addTeam,
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text("Invite Players", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: saveTeams,
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: const Text("Finalize League", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Teams in this League:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: teams.length,
              itemBuilder: (context, index) => Card(
                child: ListTile(
                  leading: Image.asset(teams[index].logo, width: 40),
                  title: Text(teams[index].name),
                  subtitle: Text("Players: ${teams[index].players.length}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => teams.removeAt(index)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
