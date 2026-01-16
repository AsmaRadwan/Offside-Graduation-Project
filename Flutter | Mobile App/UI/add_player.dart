import 'package:flutter/material.dart';
import 'package:offside/models/player_model.dart';
import 'package:offside/models/team_model.dart';

class CreatePlayersPage extends StatefulWidget {
  final Team team;

  const CreatePlayersPage({super.key, required this.team});

  @override
  State<CreatePlayersPage> createState() => _CreatePlayersPageState();
}

class _CreatePlayersPageState extends State<CreatePlayersPage> {
  TextEditingController playerNameController = TextEditingController();
  List<Player> players = [];

  void addPlayer() {
    String playerName = playerNameController.text.trim();
    if (playerName.isNotEmpty) {
      setState(() {
        players.add(Player(name: playerName, position: "Unknown" ,age: 0 , nationality: "Egypt" , number: 0)); // تقدر تزود position
        playerNameController.clear();
      });
    }
  }

  void savePlayers() {
    Navigator.pop(
        context,
        Team(
          name: widget.team.name,
          logo: widget.team.logo,
          players: players,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Players to ${widget.team.name}")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: playerNameController,
              decoration: InputDecoration(
                labelText: "Player Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: addPlayer, child: Text("Add Player")),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(players[index].name),
                  );
                },
              ),
            ),
            ElevatedButton.icon(
              onPressed: savePlayers,
              icon: Icon(Icons.save),
              label: Text("Save Players & Return"),
            )
          ],
        ),
      ),
    );
  }
}
