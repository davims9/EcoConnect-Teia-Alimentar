import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'database/database_init.dart';
import 'screens/home_screen.dart';
import 'services/game_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initDatabaseFactory();
  runApp(const FoodWebApp());
}

class FoodWebApp extends StatelessWidget {
  const FoodWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameService(),
      child: MaterialApp(
        title: 'EcoConnect: Teia Alimentar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
