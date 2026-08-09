import 'package:fit_track/provider/auth_provider.dart';
import 'package:fit_track/screens/register_screen.dart';
import 'package:fit_track/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordHidden = true;

  String getErrorMessage(String error) {
    if (error.contains("Invalid login credentials")) {
      return "Incorrect email or password";
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C2E05), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.04),

                      Image.asset(
                        "assets/logo12.png",
                        width: media.size.width * 0.5,
                        height: media.size.width * 0.5,
                        fit: BoxFit.contain,
                      ),

                      /// TITLE
                      Text(
                        "Welcome Back 💪",
                        style: TextStyle(
                          fontSize: width < 400 ? width * 0.06 : 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: height * 0.01),

                      Text(
                        "Sign in to continue your fitness journey",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: width * 0.035,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: height * 0.04),

                      /// EMAIL
                      _inputField(
                        controller: emailController,
                        hint: "Email Address",
                        icon: Icons.email_outlined,
                      ),

                      SizedBox(height: height * 0.02),

                      /// PASSWORD
                      _inputField(
                        controller: passwordController,
                        hint: "Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),

                      SizedBox(height: height * 0.04),

                      /// LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD0FD3E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: auth.isLoading
                              ? null
                              : () async {
                                  if (emailController.text.isEmpty ||
                                      passwordController.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Please enter email & password",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final error = await auth.login(
                                    email: emailController.text.trim(),
                                    password: passwordController.text.trim(),
                                  );

                                  if (!mounted) return;

                                  if (error == null) {
                                    FocusScope.of(context).unfocus();

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            const DashboardScreen(),
                                        transitionDuration: Duration.zero,
                                        reverseTransitionDuration:
                                            Duration.zero,
                                      ),
                                      (route) => false,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(getErrorMessage(error)),
                                      ),
                                    );
                                  }
                                },
                          child: auth.isLoading
                              ? const CircularProgressIndicator(
                                  color: const Color(0xFFD0FD3E),
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * 0.04,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: height * 0.04),

                      /// OR DIVIDER
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "or",
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),

                      SizedBox(height: height * 0.03),

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

                      SizedBox(height: height * 0.10),

                      /// SIGN UP
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  const CreateAccountScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: width * 0.035,
                            ),
                            children: const [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: Color(0xFFD0FD3E),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.03),

                      /// SKIP / CONTINUE AS GUEST
                      GestureDetector(
                        onTap: () async {
                          final auth = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          await auth.loginAsGuest();

                          if (!mounted) return;

                          Navigator.pushAndRemoveUntil(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, __, ___) =>
                                  const DashboardScreen(),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Skip & Continue as Guest ➡️",
                          style: TextStyle(
                            color: const Color(0xFFD0FD3E),
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.038,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      SizedBox(height: height * 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? isPasswordHidden : false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordHidden = !isPasswordHidden;
                  });
                },
              )
            : null,
        filled: true,
        // ignore: deprecated_member_use
        fillColor: Colors.white.withOpacity(0.08),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
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
