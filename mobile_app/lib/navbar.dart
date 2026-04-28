import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:offside/pages_add/add_league.dart';
import 'package:offside/pages_navbar/analysis.dart';
import 'package:offside/pages_navbar/matchs.dart';
import 'package:offside/pages_navbar/players.dart';
import 'package:offside/pages_navbar/profile.dart';
import 'package:offside/pages_navbar/player_profile.dart';
import 'package:offside/pages_navbar/notifications.dart';

class OffsideShell extends StatefulWidget {
  final String userRole; // "user" or "player"
  final String? userName; // Used for Player Profile lookup
  const OffsideShell({super.key, this.userRole = "user", this.userName});

  @override
  State<OffsideShell> createState() => _OffsideShellState();
}

class _OffsideShellState extends State<OffsideShell> {
  int _index = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
       const MatchesPage(),
       const AnalysisPage(),
       NotificationsPage(userRole: widget.userRole, currentUserEmail: widget.userName),
       const PlayersPage(),
       const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final navy = const Color.fromARGB(255, 13, 25, 86);
    final Color leagueColor = const Color(0xFF16246E);

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.userRole == "player") {
            // Players see their special Player Profile
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerProfilePage(playerName: widget.userName ?? "Guest Player"),
              ),
            );
          } else {
            // Regular users see Create League
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateLeaguePage()),
            );
          }
        },
        backgroundColor: leagueColor,
        shape: const CircleBorder(),
        child: Icon(
          widget.userRole == "player" ? Icons.person : Icons.add,
          size: 32,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: navy,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(index: 0, label: "Matches", icon: 'asset/icons/guidance_stadium.svg'),
              _buildNavItem(index: 1, label: "Analysis", icon: 'asset/icons/analysis.svg'),
              const SizedBox(width: 50),
              _buildNavItem(index: 3, label: "Search", icon: 'asset/icons/play-football.svg'),
              _buildNavItem(index: 4, label: "Settings", icon: 'asset/icons/profile.svg'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required int index, required String label, required String icon}) {
    final isSelected = _index == index;
    return GestureDetector(
      onTap: () => setState(() => _index = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            icon,
            color: isSelected ? Colors.white : Colors.white60,
            width: isSelected ? 28 : 22,
            height: isSelected ? 28 : 22,
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
