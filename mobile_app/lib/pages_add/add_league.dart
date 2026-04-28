import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:offside/pages_add/add_team.dart';

class CreateLeaguePage extends StatefulWidget {
  const CreateLeaguePage({super.key});

  @override
  State<CreateLeaguePage> createState() => _CreateLeaguePageState();
}

class _CreateLeaguePageState extends State<CreateLeaguePage> {
  final TextEditingController leagueNameController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  int? selectedLogo;

  final List<String> leagueLogos = [
    "asset/leagues_logo/1.png",
    "asset/leagues_logo/2.png",
    "asset/leagues_logo/3.png",
    "asset/leagues_logo/4.png",
    "asset/leagues_logo/5.png",
    "asset/leagues_logo/6.png",
    "asset/leagues_logo/7.png",
    "asset/leagues_logo/8.png",
  ];

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked; else endDate = picked;
      });
    }
  }

  void _createLeague() {
    String leagueName = leagueNameController.text.trim();
    if (leagueName.isNotEmpty && selectedLogo != null && startDate != null && endDate != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreateTeamPage(
            leagueName: leagueName,
            logo: leagueLogos[selectedLogo!],
            startDate: startDate,
            endDate: endDate,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all fields and select dates.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("Create League"), backgroundColor: Colors.grey.shade100,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: leagueNameController,
              decoration: const InputDecoration(labelText: "League Name", border: OutlineInputBorder(), ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(startDate == null ? "Start Date" : DateFormat('yyyy-MM-dd').format(startDate!)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(endDate == null ? "End Date" : DateFormat('yyyy-MM-dd').format(endDate!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Select League Logo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(leagueLogos.length, (index) {
                return GestureDetector(
                  onTap: () => setState(() => selectedLogo = index),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: selectedLogo == index ? Colors.blue : Colors.transparent, width: 3),
                    ),
                    child: CircleAvatar(radius: 35, backgroundImage: AssetImage(leagueLogos[index]), backgroundColor: Colors.grey[300]),
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _createLeague,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[900], minimumSize: const Size(200, 50)),
                child: const Text("Next: Add Teams", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
