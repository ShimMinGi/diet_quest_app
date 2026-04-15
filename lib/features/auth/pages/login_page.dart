import 'package:flutter/material.dart';
import 'package:diet_quest_app/core/router/app_router.dart';
import 'package:diet_quest_app/data/services/auth_service.dart';
import 'package:diet_quest_app/data/services/user_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await _authService.signIn(
        email: email,
        password: password,
      );

      final hasProfile = await _userService.hasUserProfile();

      if (!mounted) return;

      if (hasProfile) {
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.onboarding);
      }
    } on Exception catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 72,
                    color: Colors.pink,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Diet Quest',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '다이어트를 게임처럼 즐겨보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '로그인',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: '이메일',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: '비밀번호',
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: isLoading ? null : _signIn,
                            child: Text(isLoading ? '로그인 중...' : '로그인'),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRouter.signup);
                            },
                            child: const Text('회원가입'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}