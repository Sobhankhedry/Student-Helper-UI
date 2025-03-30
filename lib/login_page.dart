import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/LoginRequest.dart';
import 'package:flutter_application_2/models/User.dart';
import 'package:flutter_application_2/services/api_services.dart';
import 'register_page.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 350,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(247, 240, 240, 240),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with circle
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4B22F4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ورود',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B22F4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Username field
                TextField(
                  controller: _usernameController,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Vazir'),
                  decoration: const InputDecoration(
                    hintText: 'نام کاربری',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: TextStyle(fontFamily: 'Vazir'),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  textAlign: TextAlign.right,
                  obscureText: true,
                  style: const TextStyle(fontFamily: 'Vazir'),
                  decoration: const InputDecoration(
                    hintText: 'رمز عبور',
                    hintTextDirection: TextDirection.rtl,
                    hintStyle: TextStyle(fontFamily: 'Vazir'),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: () async {
                    final username = _usernameController.text.trim();
                    final password = _passwordController.text;

                    try {
                      // Create login request model
                      final loginRequest = LoginRequest(
                        email: username,
                        password: password,
                      );

                      // Send to API
                      final responseMessage = await ApiService().login(
                        loginRequest,
                      );

                      final user = await ApiService().login(loginRequest);

                      // Optionally: show success dialog/snack
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ورود موفقیت‌آمیز بود'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Navigate to dashboard
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => SimpleDashboard(
                                user1: user,
                                username: username.isEmpty ? 'کاربر' : username,
                              ),
                        ),
                      );
                    } on HttpException catch (e) {
                      if (e.statusCode == 400) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("رمز عبور اشتباه است"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      if (e.statusCode == 404) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("نام کاربری وجود ندارد"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                    }
                  },
                  child: const Text(
                    'ورود',
                    style: TextStyle(fontFamily: 'Vazir', fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      ' حساب کاربری ندارید؟ ',
                      style: TextStyle(
                        fontFamily: 'Vazir',
                        color: Colors.black54,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'ثبت نام',
                        style: TextStyle(
                          fontFamily: 'Vazir',
                          color: Color(0xFF4B22F4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
