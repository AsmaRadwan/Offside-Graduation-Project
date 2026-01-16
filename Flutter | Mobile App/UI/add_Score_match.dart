import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/match_model.dart';
import 'package:offside/models/player_model.dart';
import 'package:offside/models/event_model.dart';

class AddScorePage extends StatefulWidget {
  final int matchIndex;
  final int leagueIndex;

  const AddScorePage({
    super.key,
    required this.matchIndex,
    required this.leagueIndex,
  });

  @override
  State<AddScorePage> createState() => _AddScorePageState();
}

class _AddScorePageState extends State<AddScorePage> {
  final leaguesBox = Hive.box<League>('leagues');
  late League league;

  @override
  void initState() {
    super.initState();
    league = leaguesBox.getAt(widget.leagueIndex)!;
  }

  /// تسجيل أي حدث في الماتش
  void _addEvent(Match2 match, bool isHome, String type, Player player, {String? assist}) {
    final event = Event(
      type: type,
      player: player.name,
      minute: DateTime.now().minute, // ممكن تعدلها عشان تدخل الدقيقة manually
      assist: assist,
    );

    if (isHome) {
      match.eventsHome = [...match.eventsHome, event];
    } else {
      match.eventsAway = [...match.eventsAway, event];
    }

    league.save();
    setState(() {});

  }

  void _showAssistDialog(Player scorer, Match2 match, bool isHome) {
    final players = isHome ? match.homeTeam.players : match.awayTeam.players;
    final availablePlayers = players.where((p) => p != scorer).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.grey[100],
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Assist Player",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: availablePlayers.length,
                  itemBuilder: (context, index) {
                    final p = availablePlayers[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text(p.name),
                        subtitle: Text(
                          "Assists: ${p.assists} | Passes: ${p.passes}",
                          style: const TextStyle(fontSize: 13),
                        ),
                        onTap: () {
                          setState(() {
                            p.assists++;
                            p.passes++;
                            p.appearances++;
                            league.save();
                          });
                          _addEvent(match, isHome, "Goal", scorer, assist: p.name);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {
                    _addEvent(match, isHome, "Goal", scorer); // بدون Assist
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text("No Assist"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEventDialog(Player player, Match2 match, bool isHome) {
    final events = [
      {
        "label": "Goal",
        "icon": Icons.sports_soccer,
        "color": Colors.green,
        "action": () {
          setState(() {
            if (isHome) {
              match.homeTeamScore = (match.homeTeamScore ?? 0) + 1;
            } else {
              match.awayTeamScore = (match.awayTeamScore ?? 0) + 1;
            }
            player.goals++;
            player.shots++;
            player.appearances++;
            league.save();
          });
          _showAssistDialog(player, match, isHome);
        }
      },
      {
        "label": "Yellow Card",
        "icon": Icons.square,
        "color": Colors.yellow[700],
        "action": () {
          setState(() {
            player.yellowCards++;
            league.save();
          });
          _addEvent(match, isHome, "Yellow Card", player);
        }
      },
      {
        "label": "Yellow Card",
        "icon": Icons.square,
        "color": Colors.red,
        "action": () {
          setState(() {
            player.redCards++;
            league.save();
          });
          _addEvent(match, isHome, "Red Card", player);
        }
      },
      {
        "label": "Shot",
        "icon": Icons.sports,
        "color": Colors.blue,
        "action": () {
          setState(() {
            player.shots++;
            league.save();
          });
          _addEvent(match, isHome, "Shot", player);
        }
      },
      {
        "label": "Substitution",
        "icon": Icons.compare_arrows,
        "color": Colors.orange,
        "action": () {
          _addEvent(match, isHome, "Substitution", player);
        }
      },
      {
        "label": "Offside",
        "icon": Icons.flag,
        "color": Colors.purple,
        "action": () {
          _addEvent(match, isHome, "Offside", player);
        }
      },
      {
        "label": "Corner Kick",
        "icon": Icons.sports_soccer_outlined,
        "color": Colors.teal,
        "action": () {
          _addEvent(match, isHome, "Corner Kick", player);
        }
      },
      {
        "label": "Free Kick",
        "icon": Icons.sports,
        "color": Colors.indigo,
        "action": () {
          _addEvent(match, isHome, "Free Kick", player);
        }
      },
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.grey[100],
    builder: (context) {
  return Container(
    padding: const EdgeInsets.all(16),
    height: MediaQuery.of(context).size.height * 0.5, // نصف الشاشة
    child: GridView.count(
      crossAxisCount: 3,
      children: events.map((e) {
        return GestureDetector(
          onTap: () {
            Navigator.pop(context);
            (e["action"] as void Function())();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: e["color"] as Color? ?? Colors.grey,
                child: Icon(
                  e["icon"] as IconData,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                e["label"] as String,
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

    );
  }

  @override
  Widget build(BuildContext context) {
    final match = league.matches[widget.matchIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Match Details")),
      body: Column(
        children: [
          // ====== تفاصيل الماتش فوق ======
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset(match.homeTeam.logo, width: 50, height: 50),
                    Text(match.homeTeam.name),
                  ],
                ),
                const SizedBox(width: 20),
                Text(
                  "${match.homeTeamScore ?? 0} : ${match.awayTeamScore ?? 0}",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    Image.asset(match.awayTeam.logo, width: 50, height: 50),
                    Text(match.awayTeam.name),
                  ],
                ),
              ],
            ),
          ),
          const Divider(thickness: 2),

          // ====== اللاعبين ======
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListView(
                    children: match.homeTeam.players.map((player) {
                      return Card(
                        child: ListTile(
                          title: Text(player.name),
                          subtitle: Text("Goals: ${player.goals} | Assists: ${player.assists}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _showEventDialog(player, match, true),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: match.awayTeam.players.map((player) {
                      return Card(
                        child: ListTile(
                          title: Text(player.name),
                          subtitle: Text("Goals: ${player.goals} | Assists: ${player.assists}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _showEventDialog(player, match, false),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
