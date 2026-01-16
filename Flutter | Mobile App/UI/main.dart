import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:offside/models/event_model.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/match_model.dart';
import 'package:offside/models/player_model.dart';
import 'package:offside/models/team_model.dart';
import 'package:offside/splash_screen.dart';


// flutter packages pub run build_runner build

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(LeagueAdapter());
  Hive.registerAdapter(TeamAdapter());
  Hive.registerAdapter(Match2Adapter());
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(EventAdapter());
  
  // await Hive.deleteBoxFromDisk('leagues');

  await Hive.openBox<League>('leagues');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
