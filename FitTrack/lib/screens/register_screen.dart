import 'package:flutter/material.dart';
import '../auth/auth_service.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final AuthService _authService = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;

  Future<void> _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.signUp(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color.fromARGB(255, 85, 85, 84),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          content: const Text(
            "Account Created Successfully 💪",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1C2E05), Colors.black],
          ),
        ),

        child: SafeArea(
          //   top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),

            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
               
                  Center(
                    child: Image.asset(
                      "assets/logo12.png",
                      width: size.width * 0.5,
                      height: size.width * 0.5,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: size.height * 0.0001),
                  Text(
                    "Welcome Back 💪",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  _input(nameController, "Full Name", Icons.person, size),

                  SizedBox(height: size.height * 0.025),

                  _input(emailController, "Email", Icons.email, size),

                  SizedBox(height: size.height * 0.025),

                  _input(
                    passwordController,
                    "Password",
                    Icons.lock,
                    size,
                    isPassword: true,
                  ),

                  SizedBox(height: size.height * 0.025),

                  _input(
                    confirmPasswordController,
                    "Confirm Password",
                    Icons.lock,
                    size,
                    isPassword: true,
                    isConfirm: true,
                  ),

                  SizedBox(height: size.height * 0.04),

                  /// CREATE ACCOUNT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.065,

                    child: ElevatedButton(
                      onPressed: isLoading ? null : _register,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD0FD3E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: const Color(0xFFD0FD3E),
                            )
                          : Text(
                              "Create Account",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: size.width * 0.04,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.03),

                  /// SOCIAL ICONS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //_socialIcon("assets/onboarding_02.jpg"),
                      _socialIcon("assets/google.png"),
                      SizedBox(width: 20),
                      _socialIcon("assets/iphone.png"),
                      SizedBox(width: 20),
                      _socialIcon("assets/facebook.png"),
                    ],
                  ),

                  SizedBox(height: size.height * 0.05),

                  /// LOGIN TEXT
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: Text.rich(
                        TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: size.width * 0.035,
                          ),

                          children: const [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                color: Color(0xFFD0FD3E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint,
    IconData icon,
    Size size, {
    bool isPassword = false,
    bool isConfirm = false,
  }) {
    return TextField(
      controller: controller,

      obscureText: isPassword
          ? (isConfirm ? isConfirmPasswordHidden : isPasswordHidden)
          : false,

      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),

        prefixIcon: Icon(icon, color: Colors.grey),

        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (isConfirm ? isConfirmPasswordHidden : isPasswordHidden)
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (isConfirm) {
                      isConfirmPasswordHidden = !isConfirmPasswordHidden;
                    } else {
                      isPasswordHidden = !isPasswordHidden;
                    }
                  });
                },
              )
            : null,

        filled: true,
        // ignore: deprecated_member_use
        fillColor: Colors.white.withOpacity(0.08),

        contentPadding: EdgeInsets.symmetric(vertical: size.height * 0.018),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _socialIcon(String path) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.08),
        // ignore: deprecated_member_use
        border: Border.all(color: const Color(0xFFD0FD3E).withOpacity(0.3)),
      ),
      child: Image.asset(path, width: 28, height: 28),
    );
  }
}
