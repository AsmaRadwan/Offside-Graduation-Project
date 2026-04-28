import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:offside/models/event_model.dart';
import 'package:offside/models/leage_model.dart';
import 'package:offside/models/match_model.dart';
import 'package:offside/models/player_model.dart';
import 'package:offside/models/team_model.dart';
import 'package:offside/models/match_stats_model.dart';
import 'package:offside/models/player_stats_model.dart';
import 'package:offside/models/team_stats_model.dart';
import 'package:offside/models/invitation_model.dart';
import 'package:offside/splash_screen.dart';
import 'package:offside/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🚀 Initialize Supabase
  await Supabase.initialize(
    url: 'https://gsvowvzdxphlguclawur.supabase.co',
    anonKey: 'sb_publishable_vuHhBKjf4kJJgPnkFlNm9A_ErI2gVd_', 
  );

  await Hive.initFlutter();

  // Registering Adapters
  Hive.registerAdapter(LeagueAdapter());      
  Hive.registerAdapter(Match2Adapter());      
  Hive.registerAdapter(TeamAdapter());        
  Hive.registerAdapter(PlayerAdapter());      
  Hive.registerAdapter(EventAdapter());       
  
  try {
    Hive.registerAdapter(MatchStatsAdapter());  
    Hive.registerAdapter(PlayerStatsAdapter()); 
    Hive.registerAdapter(TeamStatsAdapter());   
    // Hive.registerAdapter(InvitationAdapter()); 
  } catch (_) {}
  
  await Hive.openBox<League>('leagues');
  try {
     await Hive.openBox<Invitation>('invitations');
  } catch (_) {
     await Hive.openBox('invitations');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Offside',
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
