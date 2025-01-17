// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/views/screens/home.dart';
import 'package:project/views/screens/login.dart';
import 'package:project/views/widgets/textfield.dart';

TextEditingController pass = TextEditingController();
TextEditingController email = TextEditingController();
TextEditingController cpass = TextEditingController();

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool isLoading = false;
  bool _isDarkMode = false;

  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                    const SizedBox(height: 60),
                    Image.asset('assets/images/Stream_logo.png', width: 150),
                    const SizedBox(height: 2),
                    Text(
                      "Sign Up",
                      style: GoogleFonts.notoSerif(
                          fontSize: 27, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 25),
                    MyTextField(
                      controller: email,
                      hint: "Email",
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 30),
                    MyTextField(
                      controller: pass,
                      hint: "Password",
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30),
                    MyTextField(
                      controller: cpass,
                      hint: "Confirm Password",
                      icon: Icons.lock,
                      isPassword: true,
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: 350,
                      height: 70,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (email.text.isEmpty ||
                                    pass.text.isEmpty ||
                                    cpass.text.isEmpty) {
                                  Get.snackbar(
                                      "Error", "All fields are required.",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white);
                                } else {
                                  serverSignup();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 1, 152, 223),
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                "Sign Up",
                                style: GoogleFonts.notoSerif(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "---------------------  OR  ---------------------",
                      style: GoogleFonts.notoSerif(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 350,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: () => signInWithGoogle(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 236, 226, 226),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google_icon.png',
                                height: 45,
                                width: 45,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Sign Up with Google",
                                style: GoogleFonts.notoSerif(
                                  color: Colors.black,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 70),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account?",
                            style: GoogleFonts.notoSerif(
                                color: const Color.fromARGB(255, 58, 57, 57),
                                fontSize: 14)),
                        TextButton(
                          child: Text("Login",
                              style: GoogleFonts.notoSerif(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color:
                                      const Color.fromARGB(255, 74, 45, 240))),
                          onPressed: () {
                            Get.toNamed("/login");
                          },
                        ),
                      ],
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

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomeScreen(isDarkMode: _isDarkMode, toggleTheme: toggleTheme)),
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Google Sign-In error: $e");
      return null;
    }
  }

  Future<void> serverSignup() async {
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });
      if (pass.text == cpass.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text,
          password: pass.text,
        );
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return const Center(child: Text("Passwords do not match"),);
            });
      }
      Navigator.pop(context);
      // Navigate to HomeScreen if login is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (e) {
      Navigator.pop(context);
      print('An unexpected error occurred: $e');
    }
  }
}
