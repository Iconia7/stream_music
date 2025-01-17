import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/views/widgets/textfield.dart'; // Ensure the correct path is used
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

TextEditingController email = TextEditingController();

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  Future<void> passwordReset() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      if (!mounted) return;
      Navigator.pop(context); // Close the loading dialog
      _showSnackBar("Password reset link sent! Check your Email");
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the loading dialog
      if (e.code == 'user-not-found') {
        _showSnackBar("No user found with this email.");
      } else {
        _showSnackBar(e.message ?? "An error occurred");
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reset Password",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightBlueAccent, Colors.blue],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      "Enter your Email to reset your password",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                      controller: email,
                      hint: "Email",
                      colour: const Color.fromARGB(255, 223, 222, 222),
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 350,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: () {
                                if (email.text.isEmpty) {
                                  _showSnackBar("Please enter an Email");
                                } else {
                                  passwordReset();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 1, 152, 223),
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                "Reset Password",
                                style: GoogleFonts.notoSerif(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
