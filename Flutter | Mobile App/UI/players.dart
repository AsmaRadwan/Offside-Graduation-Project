import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/player_model.dart';
import 'package:offside/pages_details/details_player.dart';

class PlayersPage extends StatefulWidget {
  const PlayersPage({super.key});

  @override
  State<PlayersPage> createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  final leaguesBox = Hive.box<League>('leagues');

  final Color bg = const Color(0xFFF2F3F8);
  final Color primary = const Color(0xFF0D1956);

  String searchQuery = "";

  List<Player> getAllPlayers() {
    List<Player> players = [];
    for (int i = 0; i < leaguesBox.length; i++) {
      final league = leaguesBox.getAt(i)!;
      for (var team in league.teams) {
        players.addAll(team.players);
      }
    }
    return players;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: leaguesBox.listenable(),
          builder: (context, box, _) {
            final allPlayers = getAllPlayers();

            final players = allPlayers
                .where((p) =>
                    p.name.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return Column(
              children: [
                // ===== Search Bar =====
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => searchQuery = val),
                      decoration: InputDecoration(
                        hintText: "Search player...",
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),

                // ===== Players List =====
                Expanded(
                  child: players.isEmpty
                      ? const Center(
                          child: Text(
                            "No players found",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: players.length,
                          itemBuilder: (context, index) {
                            final player = players[index];

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.07),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PlayerDetailsPage(player: player),
                                    ),
                                  );
                                },

                                // ===== Player Image / Initial =====
                                leading: Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: primary,
                                    image: player.image != null
                                        ? DecorationImage(
                                            image: AssetImage(player.image!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: player.image == null
                                      ? Text(
                                          player.name[0].toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : null,
                                ),

                                // ===== Player Name =====
                                title: Text(
                                  player.name,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade900),
                                ),

                                // ===== Stats =====
                                subtitle: Text(
                                  "Goals: ${player.goals} • Assists: ${player.assists}",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54),
                                ),

                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
