import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/player_model.dart';
import 'package:offside/models/team_model.dart';

class PlayerProfilePage extends StatefulWidget {
  final String playerName;

  const PlayerProfilePage({super.key, required this.playerName});

  @override
  State<PlayerProfilePage> createState() => _PlayerProfilePageState();
}

class _PlayerProfilePageState extends State<PlayerProfilePage> {
  final leaguesBox = Hive.box<League>('leagues');
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(Player player, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        player.image = image.path;
        player.save();
      });
    }
  }

  void _showEditDialog(Player player) {
    final TextEditingController heightController = TextEditingController(text: player.height?.toString());
    final TextEditingController weightController = TextEditingController(text: player.weight?.toString());
    final TextEditingController nationalityController = TextEditingController(text: player.nationality);
    String selectedPos = player.position;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile Data"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nationalityController, decoration: const InputDecoration(labelText: "Nationality")),
              TextField(controller: heightController, decoration: const InputDecoration(labelText: "Height (cm)"), keyboardType: TextInputType.number),
              TextField(controller: weightController, decoration: const InputDecoration(labelText: "Weight (kg)"), keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedPos,
                items: ["Goalkeeper", "Defender", "Midfielder", "Forward"].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) => selectedPos = val!,
                decoration: const InputDecoration(labelText: "Position"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                player.nationality = nationalityController.text;
                player.height = double.tryParse(heightController.text);
                player.weight = double.tryParse(weightController.text);
                player.position = selectedPos;
                player.save();
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF16246E);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Player Dashboard"),
        backgroundColor: Colors.grey.shade100,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: leaguesBox.listenable(),
        builder: (context, Box<League> box, _) {
          Player? currentPlayer;
          List<Team> joinedTeams = [];
          List<League> participatedLeagues = [];

          for (var league in box.values) {
            bool playedInLeague = false;
            for (var team in league.teams) {
              final p = team.players.where((player) => player.name == widget.playerName);
              if (p.isNotEmpty) {
                currentPlayer = p.first;
                joinedTeams.add(team);
                playedInLeague = true;
              }
            }
            if (playedInLeague) participatedLeagues.add(league);
          }

          if (currentPlayer == null) {
            return const Center(child: Text("Register as a player in a team to see your profile."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header with Image Upload
                _buildHeader(currentPlayer),
                const SizedBox(height: 20),
                
                // Edit Button
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditDialog(currentPlayer!),
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Personal Info"),
                  ),
                ),
                
                const SizedBox(height: 25),
                const Text("Performance Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 2.5,
                  children: [
                    _statCard("Goals", currentPlayer.goals.toString(), Icons.sports_soccer),
                    _statCard("Assists", currentPlayer.assists.toString(), Icons.assistant),
                    _statCard("Matches", currentPlayer.appearances.toString(), Icons.event),
                    _statCard("Passes", currentPlayer.passes.toString(), Icons.swap_horiz),
                  ],
                ),
                const SizedBox(height: 30),
                const Text("Teams & Organizations", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...joinedTeams.map((team) => Card(
                  child: ListTile(
                    leading: Image.asset(team.logo, width: 35),
                    title: Text(team.name),
                    subtitle: const Text("Member"),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Player player) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF16246E), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white24,
                backgroundImage: player.image != null && player.image!.isNotEmpty && !player.image!.startsWith('asset')
                    ? FileImage(File(player.image!))
                    : (player.image != null && player.image!.startsWith('asset') ? AssetImage(player.image!) : null) as ImageProvider?,
                child: player.image == null || player.image!.isEmpty 
                    ? const Icon(Icons.person, size: 50, color: Colors.white70) 
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showPicker(player),
                  child: const CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.camera_alt, size: 15, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(player.position, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 5),
                Text("${player.height ?? 0}cm | ${player.weight ?? 0}kg", style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(Player player) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () { _pickImage(player, ImageSource.gallery); Navigator.pop(context); }),
            ListTile(leading: const Icon(Icons.photo_camera), title: const Text('Camera'), onTap: () { _pickImage(player, ImageSource.camera); Navigator.pop(context); }),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[900], size: 20),
          const SizedBox(width: 10),
          Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ]),
        ],
      ),
    );
  }
}
