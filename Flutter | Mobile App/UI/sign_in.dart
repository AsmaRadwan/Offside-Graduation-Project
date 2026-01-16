import 'package:flutter/material.dart';
import 'package:offside/navbar.dart';

import 'sign_up.dart';

class SignInPage extends StatefulWidget {
  final Map<String, String> users;
  const SignInPage({super.key, required this.users});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorMessage = "";
  String email = "";
  String password = "";
  void signIn() {
    setState(() {
      email = emailController.text;
      password = passwordController.text;
      if (widget.users.containsKey(email)) {
        if (widget.users[email] == password) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OffsideShell()));
        } else {
          errorMessage = "Wrong password";
        
        }
      }else{
        errorMessage = "User not found";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color(0xFFFAFAFC),
      body: SafeArea(child: SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            // Logo
            Image.asset(
              'asset/logo.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 100),
            // Email
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Your Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.blue.shade900),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Password
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                suffixText: "Forgot?",
                suffixStyle: const TextStyle(color: Colors.indigo),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.indigo),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don’t have an account "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignUpPage(
                        users: widget.users,
                      )),
                    );
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Google & Apple buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _socialButton("asset/google_icon.png"),
                const SizedBox(width: 16),
                _socialButton("asset/iphone_icon.png"),
              ],
            ),
            const SizedBox(height: 24),
            // Error message
            Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            // Sign in button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  signIn();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blue[900],
                ),
                child: const Text(
                  "Sign In",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      ))
    );
  }

  Widget _socialButton(String asset) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(asset, height: 30),
    );
  }
}
