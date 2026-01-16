import 'package:flutter/material.dart';
import 'package:offside/pages_sign/sign_in.dart';

class SignUpPage extends StatefulWidget {
  final Map<String, String> users;
  const SignUpPage({super.key, required this.users});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();


  String email = "", password = "", confirmPassword = "";
  String msg_error = "";

  void Sign_Up() {
    setState(() {
      email = emailController.text;
      password = passwordController.text;
      confirmPassword = confirmPasswordController.text;
      if (password != confirmPassword) {
        msg_error = "Password not match";
      } else {
        if (!widget.users.containsKey(email)) {
          widget.users[email] = password;
          msg_error = "";
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          Next_Page();
        } else {
          msg_error = "Email already exists";
        }
      }
    });
  }

  void Next_Page() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignInPage(
        users: widget.users,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFC),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 35, color: Colors.blue[900]),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFFAFAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'asset/logo.png',
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 50),
              Text(
                "Create your account",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 24),

              // Email
              TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "Your Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:  BorderSide(color: Colors.blue.shade900),
                ),
              ),
            ), 
                         const SizedBox(height: 16),

              // Password
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,        
              decoration: InputDecoration(
                hintText: "Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:  BorderSide(color: Colors.blue.shade900),
                ),
              ),
            ),
                          const SizedBox(height: 16),

              // Confirm Password
              TextField(
              controller: confirmPasswordController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                hintText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:  BorderSide(color: Colors.blue.shade900),
                ),
              ),
            ),
              const SizedBox(height: 32),

              // error message
              Text(
                msg_error,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),

              // Sign up button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Sign_Up();
                  },
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sign Up as",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_drop_down_circle_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.blue[900],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
