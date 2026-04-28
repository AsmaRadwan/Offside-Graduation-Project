import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:offside/pages_sign/role_selection.dart';

class SignUpPage extends StatefulWidget {
  final Map<String, String> users;
  const SignUpPage({super.key, required this.users});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String msg_error = "";
  bool _isLoading = false;

  bool isValidEmail(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  Future<void> _signUp() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => msg_error = "Please fill all fields");
      return;
    }

    if (!isValidEmail(email)) {
      setState(() => msg_error = "Please enter a valid email address");
      return;
    }

    if (password != confirmPassword) {
      setState(() => msg_error = "Passwords do not match");
      return;
    }

    setState(() {
      _isLoading = true;
      msg_error = "";
    });

    try {
      // 🔐 SUPABASE AUTH SIGN UP
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (res.user != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RoleSelectionPage(
              userName: name, 
              email: email, 
              phone: phone
            )),
          );
        }
      }
    } on AuthException catch (e) {
      // 💡 HCI Trick: If user already exists but isn't confirmed, try signing them in
      if (e.message.toLowerCase().contains("rate limit") || e.message.toLowerCase().contains("already registered")) {
        setState(() => msg_error = "Please wait a moment or check your Supabase rate limit settings.");
      } else {
        setState(() => msg_error = e.message);
      }
    } catch (e) {
      setState(() => msg_error = "An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Colors.blue[900]!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 28, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Image.asset('asset/logo.png', width: 120, height: 120),
                  Text(
                    "Create your account",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primary),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(nameController, "Full Name", Icons.person, false),
                  const SizedBox(height: 12),
                  _buildTextField(emailController, "Email Address", Icons.email, false),
                  const SizedBox(height: 12),
                  _buildTextField(phoneController, "Phone Number", Icons.phone, false, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildTextField(passwordController, "Password", Icons.lock, true),
                  const SizedBox(height: 12),
                  _buildTextField(confirmPasswordController, "Confirm Password", Icons.lock_outline, true),
                  const SizedBox(height: 20),
                  if (msg_error.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(msg_error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        backgroundColor: primary,
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(color: Colors.black26, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool obscure, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[900]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
