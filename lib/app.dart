import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

class DietQuestApp extends StatelessWidget {
  const DietQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: AppRouter.splash,
      routes: AppRouter.routes,
    );
  }
}