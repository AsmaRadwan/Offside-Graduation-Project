import 'package:flutter/material.dart';
import 'package:offside/models/player_model.dart';

class PlayerDetailsPage extends StatelessWidget {
  final Player player;

  const PlayerDetailsPage({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final Color bg = const Color(0xFF0E1126);
    final Color card = const Color(0xFF161A33);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // ===== Banner =====
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF16225A),
                        Color(0xFF0E1126),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // صورة اللاعب
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        backgroundImage: player.image != null &&
                                player.image!.isNotEmpty
                            ? AssetImage(player.image!)
                            : null,
                        child: player.image == null || player.image!.isEmpty
                            ? const Icon(Icons.person,
                                size: 70, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ===== Name =====
                Text(
                  player.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  player.nationality,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 22),

                // ===== Mini Cards: Position / Age / Number =====
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _miniCard("Position", player.position, card),
                    _miniCard("Age", "${player.age}", card),
                    _miniCard("Number", "#${player.number}", card),
                  ],
                ),

                const SizedBox(height: 28),

                // ===== Stats Title =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Statistics",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ===== Stats Grid =====
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.35,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 14,
                    ),
                    children: [
                      _statItem("Appearances", player.appearances),
                      _statItem("Goals", player.goals),
                      _statItem("Assists", player.assists),
                      _statItem("Yellow Cards", player.yellowCards),
                      _statItem("Red Cards", player.redCards),
                      _statItem("Minutes", player.minutesPlayed),
                      _statItem("Shots", player.shots),
                      _statItem("Passes", player.passes),
                      _statItem("Played", player.played),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // ===== Back Button =====
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.black.withOpacity(0.35),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mini Card for Position – Age – Number
  Widget _miniCard(String title, String value, Color cardColor) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
                color: Colors.white.withOpacity(0.6), fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Stat Item
  Widget _statItem(String title, int value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "$value",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white.withOpacity(0.6), fontSize: 12, height: 1.2),
        ),
      ],
    );
  }
}
