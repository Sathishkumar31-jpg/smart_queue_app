import 'package:flutter/material.dart';
import 'package:smart_queue_app/screens/auth/register_screen.dart';
import '../../services/auth_service.dart';
import '../patient/patient_home.dart';
import '../doctor/doctor_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var user = await _authService.login(
                  emailController.text,
                  passwordController.text,
                );
                if (user != null) {
                  if (user.role == "patient") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const PatientHome()),
                    );
                  } else if (user.role == "doctor") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const DoctorHome()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Unknown role")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Login Failed")));
                }
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
