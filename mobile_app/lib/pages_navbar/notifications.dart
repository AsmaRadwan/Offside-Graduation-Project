import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:offside/models/invitation_model.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/player_model.dart';

class NotificationsPage extends StatelessWidget {
  final String userRole; // 'player' or 'user'
  final String? currentUserEmail; // To filter notifications for the specific player

  const NotificationsPage({super.key, required this.userRole, this.currentUserEmail});

  @override
  Widget build(BuildContext context) {
    final invitationsBox = Hive.box<Invitation>('invitations');
    final leaguesBox = Hive.box<League>('leagues');
    final Color primary = Colors.blue[900]!;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.grey.shade100,
      ),
      body: ValueListenableBuilder(
        valueListenable: invitationsBox.listenable(),
        builder: (context, Box<Invitation> box, _) {
          final invitations = box.values.toList().reversed.toList();
          
          // If player, filter by their name/id (simplified here using email or name)
          // In a real app, you'd filter by a unique ID
          final filteredInvitations = userRole == 'player' 
            ? invitations.where((i) => i.playerId == currentUserEmail || i.playerName == currentUserEmail).toList()
            : invitations; // Regular users see all they sent? Or maybe filter by team owner.

          if (filteredInvitations.isEmpty) {
            return const Center(child: Text("No notifications yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredInvitations.length,
            itemBuilder: (context, index) {
              final invite = filteredInvitations[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    userRole == 'player' 
                      ? "Invitation from ${invite.teamName}"
                      : "Invite to ${invite.playerName}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("League: ${invite.leagueName}"),
                      Text("Jersey Number: ${invite.jerseyNumber}"),
                      const SizedBox(height: 8),
                      _statusBadge(invite.status),
                    ],
                  ),
                  trailing: userRole == 'player' && invite.status == 'pending'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () => _handleResponse(invite, 'accepted', leaguesBox),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => _handleResponse(invite, 'rejected', leaguesBox),
                          ),
                        ],
                      )
                    : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'accepted': color = Colors.green; break;
      case 'rejected': color = Colors.red; break;
      default: color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _handleResponse(Invitation invite, String newStatus, Box<League> leaguesBox) {
    invite.status = newStatus;
    invite.save();

    if (newStatus == 'accepted') {
      // Find the league and team and add the player
      // This is a simplified logic. In a real app, you'd have better IDs.
      try {
        final league = leaguesBox.values.firstWhere((l) => l.name == invite.leagueName);
        final team = league.teams.firstWhere((t) => t.name == invite.teamName);
        
        // Find player in the database to get their details
        // Assuming player exists in some league already as per requirement 2
        Player? foundPlayer;
        for (var l in leaguesBox.values) {
          for (var t in l.teams) {
            for (var p in t.players) {
              if (p.name == invite.playerName) {
                foundPlayer = p;
                break;
              }
            }
          }
        }

        if (foundPlayer != null) {
          final newPlayer = Player(
            name: foundPlayer.name,
            position: foundPlayer.position,
            age: foundPlayer.age,
            nationality: foundPlayer.nationality,
            number: invite.jerseyNumber,
            height: foundPlayer.height,
            weight: foundPlayer.weight,
          );
          team.players.add(newPlayer);
          league.save();
        }
      } catch (e) {
        print("Error adding player: $e");
      }
    }
  }
}
