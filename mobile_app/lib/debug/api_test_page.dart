import 'package:flutter/material.dart';
import 'package:offside/services/api_service.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final List<String> _log = [];
  bool _loading = false;

  void _addLog(String msg) {
    setState(() => _log.insert(0, "${DateTime.now().toIso8601String().substring(11, 19)}  $msg"));
  }

  Future<void> _testPing() async {
    setState(() => _loading = true);
    final alive = await ApiService.ping();
    if (alive) {
      _addLog("✅ Server is REACHABLE");
    } else {
      _addLog("❌ Server UNREACHABLE (Check internet/IP)");
    }
    setState(() => _loading = false);
  }

  Future<void> _testCreateTournament() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.createTournament(
        name: "Test League ${DateTime.now().millisecondsSinceEpoch}",
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );
      _addLog("✅ POST /tournaments SUCCESS");
      _addLog("   ID: ${result['id'] ?? result['tournament_id']}");
    } on ApiException catch (e) {
      _addLog("❌ ${e.statusCode}: ${e.message}");
    } catch (e) {
      _addLog("❌ $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1126),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16246E),
        title: const Text("🛠️ Backend Connection Test", style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFF1C2C7A),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text("Base URL: ${ApiService.baseUrl}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _btn("Ping Server", _testPing, Colors.green),
                _btn("POST tournament", _testCreateTournament, Colors.blue),
                _btn("Clear log", () => setState(() => _log.clear()), Colors.red),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (_, i) => Text(_log[i], style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'monospace')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(String label, VoidCallback onTap, Color color) {
    return ElevatedButton(
      onPressed: _loading ? null : onTap,
      style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
      child: Text(label),
    );
  }
}
