import 'package:flutter/material.dart';
import 'package:offside/pages_add/add_team.dart';

class CreateLeaguePage extends StatefulWidget {
  const CreateLeaguePage({super.key});

  @override
  State<CreateLeaguePage> createState() => _CreateLeaguePageState();
}

class _CreateLeaguePageState extends State<CreateLeaguePage> {
  TextEditingController leagueNameController = TextEditingController();
  int? selectedLogo;

  List<String> leagueLogos = [
    "asset/leagues_logo/1.png",
    "asset/leagues_logo/2.png",
    "asset/leagues_logo/3.png",
    "asset/leagues_logo/4.png",
    "asset/leagues_logo/5.png",
    "asset/leagues_logo/6.png",
    "asset/leagues_logo/7.png",
    "asset/leagues_logo/8.png",
  ];

  void _createLeague() {
    String leagueName = leagueNameController.text.trim();
    int? logoIndex = selectedLogo;

    if (leagueName.isNotEmpty && logoIndex != null) {
      // هنا تقدر تضيف الحفظ في Hive أو DB
      print("League Created: $leagueName with logo index $logoIndex");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ League '$leagueName' created!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreateTeamPage(
            leagueName: leagueName,
            logo: leagueLogos[logoIndex],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Please enter a league name and select a logo."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create League"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم الدوري
            TextField(
              controller: leagueNameController,
              decoration: const InputDecoration(
                labelText: "League Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // اختيار اللوجو
            Text("Select League Logo",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(leagueLogos.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedLogo = index;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedLogo == index
                            ? Colors.blue
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: AssetImage(leagueLogos[index]),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton.icon(
                onPressed: _createLeague,
                icon: const Icon(Icons.check),
                label: const Text("Create League"),
                style: ElevatedButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  textStyle:
                      const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
