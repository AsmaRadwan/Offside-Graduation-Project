import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/pages_sign/sign_in.dart';
import 'package:offside/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  const ProfilePage({super.key, this.userName = "User"});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> clearCache() async {
    final box = await Hive.openBox<League>('leagues');
    await box.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Cache cleared successfully!"),
      duration: Duration(seconds: 2),
    ));

    setState(() {});
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage(users: {})),
                (route) => false,
              );
            },
            child: const Text("Sign Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Profile Header
            Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.userName, 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 5),
                Text(
                  "Member since 2024",
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade700, fontSize: 15),
                ),
                const SizedBox(height: 12),
              ],
            ),

            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Edit Profile", style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 25),

            // Settings Section
            sectionHeader("Settings"),
            settingTile(Icons.sports_soccer, "My Leagues", () {}),
            
            // Dark Mode Toggle Tile
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                secondary: Icon(Icons.dark_mode, color: isDark ? Colors.blueAccent : const Color(0xFF16246E)),
                title: const Text("Dark Mode", style: TextStyle(fontSize: 16)),
                value: isDark,
                onChanged: (val) => ThemeProvider.toggleTheme(),
              ),
            ),
            
            settingTile(Icons.delete_forever, "Clear Cache", clearCache),

            const SizedBox(height: 30),

            // Account Section
            sectionHeader("Account"),
            settingTile(Icons.logout, "Sign Out", _signOut, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget sectionHeader(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget settingTile(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Theme.of(context).cardTheme.color,
        leading: Icon(icon, color: isDestructive ? Colors.red : (Theme.of(context).brightness == Brightness.dark ? Colors.blueAccent : const Color(0xFF16246E))),
        title: Text(title, style: TextStyle(fontSize: 16, color: isDestructive ? Colors.red : null)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
