import 'package:flutter/material.dart';
import 'package:offside/navbar.dart';
import 'package:offside/pages_sign/player_info.dart';
import 'package:offside/services/api_service.dart';

class RoleSelectionPage extends StatefulWidget {
  final String userName;
  final String? email;
  final String? phone;
  const RoleSelectionPage({super.key, required this.userName, this.email, this.phone});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  bool _isLoading = false;

  Future<void> _handleRegularUser() async {
    setState(() => _isLoading = true);
    try {
      // 🚀 Fix: Ensured phoneNumber is passed correctly as defined in ApiService
      await ApiService.createUser(
        name: widget.userName,
        email: widget.email ?? "user_${DateTime.now().millisecondsSinceEpoch}@example.com",
        nationality: "Unknown",
        phoneNumber: widget.phone ?? "0000000000",
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => OffsideShell(userRole: "user", userName: widget.userName)),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Failed to create user: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Colors.blue[900]!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Welcome, ${widget.userName}!", textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary)),
                  const SizedBox(height: 10),
                  const Text("Please select your role to continue", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 50),
                  _roleCard(context, title: "Regular User", subtitle: "Follow matches, follow teams, and track stats.", icon: Icons.person, onTap: _handleRegularUser),
                  const SizedBox(height: 20),
                  _roleCard(context, title: "Player", subtitle: "Join teams, track your personal stats, and play matches.", icon: Icons.sports_soccer, onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerInfoPage(userName: widget.userName, email: widget.email, phone: widget.phone)));
                  }),
                ],
              ),
            ),
          ),
          if (_isLoading) Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _roleCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20), 
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))], 
          border: Border.all(color: Colors.blue[900]!.withOpacity(0.1))
        ),
        child: Row(
          children: [
            CircleAvatar(radius: 30, backgroundColor: Colors.blue[900]!.withOpacity(0.1), child: Icon(icon, color: Colors.blue[900], size: 30)),
            const SizedBox(width: 20),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600]))])),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue[900]),
          ],
        ),
      ),
    );
  }
}
