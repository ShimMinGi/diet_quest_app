import 'package:flutter/material.dart';
import 'package:diet_quest_app/features/auth/pages/login_page.dart';
import 'package:diet_quest_app/features/auth/pages/signup_page.dart';
import 'package:diet_quest_app/features/dashboard/pages/dashboard_page.dart';
import 'package:diet_quest_app/features/daily_record/pages/daily_record_page.dart';
import 'package:diet_quest_app/features/meal_record/pages/meal_record_page.dart';
import 'package:diet_quest_app/features/onboarding/pages/onboarding_page.dart';
import 'package:diet_quest_app/features/records/pages/records_page.dart';
import 'package:diet_quest_app/features/settings/pages/change_password_page.dart';
import 'package:diet_quest_app/features/settings/pages/delete_account_page.dart';
import 'package:diet_quest_app/features/settings/pages/reset_goal_page.dart';
import 'package:diet_quest_app/features/settings/pages/settings_page.dart';
import 'package:diet_quest_app/features/splash/splash_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String dailyRecord = '/daily-record';
  static const String mealRecord = '/meal-record';
  static const String records = '/records';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  static const String deleteAccount = '/delete-account';
  static const String resetGoal = '/reset-goal';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashPage(),
        login: (context) => const LoginPage(),
        signup: (context) => const SignupPage(),
        onboarding: (context) => const OnboardingPage(),
        dashboard: (context) => const DashboardPage(),
        dailyRecord: (context) => const DailyRecordPage(),
        mealRecord: (context) => const MealRecordPage(),
        records: (context) => const RecordsPage(),
        settings: (context) => const SettingsPage(),
        changePassword: (context) => const ChangePasswordPage(),
        deleteAccount: (context) => const DeleteAccountPage(),
        resetGoal: (context) => const ResetGoalPage(),
      };
}