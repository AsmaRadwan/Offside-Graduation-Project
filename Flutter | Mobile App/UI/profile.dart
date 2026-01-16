import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:offside/models/leage_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> clearCache() async {
    final box = await Hive.openBox<League>('leagues');
    await box.clear();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Cache cleared successfully!"),
      duration: Duration(seconds: 2),
    ));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          children: [

            const SizedBox(height: 10),

            // ============================
            // PROFILE AVATAR + NAME
            // ============================
            Column(
              children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: Color(0xFF16246E),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage("assets/images/profile.png"),
                    // لو معندكش صورة بروفايل حط أي لوجو عادي
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Team Offside",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "offside@example.com",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),

            // ============================
            // EDIT PROFILE BUTTON
            // ============================
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF16246E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 16 , color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ============================
            // SETTINGS SECTION
            // ============================
            sectionHeader("Settings"),

            settingTile(Icons.sports_soccer, "My Leagues", () {}),
            settingTile(Icons.notifications, "Notifications", () {}),
            settingTile(Icons.color_lens, "Theme", () {}),
            settingTile(Icons.language, "Language", () {}),
            settingTile(Icons.delete_forever, "Clear Cache", clearCache),

            const SizedBox(height: 30),

            // ============================
            // ABOUT SECTION
            // ============================
            sectionHeader("About"),

            settingTile(Icons.privacy_tip, "Privacy Policy", () {}),
            settingTile(Icons.info_outline, "About App", () {}),
          ],
        ),
      ),
    );
  }

  // Header for each section
  Widget sectionHeader(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0D1956),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Single setting item
  Widget settingTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
        leading: Icon(icon, color: Color(0xFF16246E)),
        title: Text(title, style: const TextStyle(fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
