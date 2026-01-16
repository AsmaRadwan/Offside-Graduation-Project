import 'package:flutter/material.dart';
import 'package:offside/models/team_model.dart';
import 'package:offside/pages_add/add_matches.dart';
import 'package:offside/pages_add/add_player.dart';

class CreateTeamPage extends StatefulWidget {
  final String leagueName;
  final String logo;

  const CreateTeamPage(
      {super.key, required this.leagueName, required this.logo});

  @override
  State<CreateTeamPage> createState() => _CreateTeamPageState();
}

class _CreateTeamPageState extends State<CreateTeamPage> {
  TextEditingController teamNameController = TextEditingController();
  List<Team> teams = [];
  int? selectedLogo;

  List<String> teamLogos =
      List.generate(20, (index) => "asset/Teams_Logo/${index + 1}.png");

  void addTeam() async {
    String teamName = teamNameController.text.trim();
    String? teamLogo = selectedLogo != null ? teamLogos[selectedLogo!] : null;

    if (teamName.isNotEmpty && teamLogo != null) {
      // هنا هنروح لصفحة إضافة اللاعبين
      final newTeam = await Navigator.push<Team>(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePlayersPage(
            team: Team(name: teamName, logo: teamLogo, players: []),
          ),
        ),
      );

      if (newTeam != null) {
        setState(() {
          teams.add(newTeam);
        });
        teamNameController.clear();
        selectedLogo = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ Team '${newTeam.name}' added with players!")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please enter a name and select a logo")),
      );
    }
  }

  void saveTeams() {
    if (teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ Please add at least one team")),
      );
      return;
    }

    // بعد كل الفرق تروح لإنشاء المباريات
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CreateMatchPage(
          leagueLogo: widget.logo,
          leagueName: widget.leagueName,
          teams: teams,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leagueName),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(widget.logo),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: teamNameController,
              decoration: InputDecoration(
                labelText: "Team Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            Text("Select Team Logo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(teamLogos.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedLogo = index;
                    });
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: selectedLogo == index
                        ? Colors.blue.shade100
                        : Colors.grey.shade200,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(teamLogos[index]),
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: addTeam,
                  icon: Icon(Icons.add),
                  label: Text("Add Team + Players"),
                ),
                ElevatedButton.icon(
                  onPressed: saveTeams,
                  icon: Icon(Icons.save),
                  label: Text("Save Teams"),
                ),
              ],
            ),

            SizedBox(height: 20),

            Text("Teams Added",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Image.asset(teams[index].logo, width: 40),
                    title: Text(teams[index].name),
                    subtitle: Text("Players: ${teams[index].players.length}"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
