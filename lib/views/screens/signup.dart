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
   bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool isPasswordLengthValid = false;

  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  void validatePassword(String value) {
    setState(() {
      hasUppercase = value.contains(RegExp(r'[A-Z]'));
      hasLowercase = value.contains(RegExp(r'[a-z]'));
      hasNumber = value.contains(RegExp(r'\d'));
      hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      isPasswordLengthValid = value.length >= 8 && value.length <= 20;
    });
  }

   Future<void> showSuccessDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Signup Success', style: GoogleFonts.notoSerif()),
          content: Text('Your account has been created successfully!',
              style: GoogleFonts.notoSerif()),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              child: Text('OK', style: GoogleFonts.notoSerif()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const int minPasswordLength = 8;
    const int maxPasswordLength = 20;

    bool hasUppercase = pass.text.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = pass.text.contains(RegExp(r'[a-z]'));
    bool hasNumber = pass.text.contains(RegExp(r'\d'));
    bool hasSpecialChar = pass.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

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
                      onChanged: validatePassword,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 35,right: 35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            "Password must:",
                            style: GoogleFonts.notoSerif(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                hasUppercase ? Icons.check_circle : Icons.cancel,
                                color: hasUppercase ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "- Contain at least one uppercase letter.",
                                style: GoogleFonts.notoSerif(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                hasLowercase ? Icons.check_circle : Icons.cancel,
                                color: hasLowercase ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "- Contain at least one lowercase letter.",
                                style: GoogleFonts.notoSerif(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                hasNumber ? Icons.check_circle : Icons.cancel,
                                color: hasNumber ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "- Include at least one number.",
                                style: GoogleFonts.notoSerif(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                hasSpecialChar ? Icons.check_circle : Icons.cancel,
                                color: hasSpecialChar ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "- Include at least one special character (e.g., @, #, \$).",
                                style: GoogleFonts.notoSerif(fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Icon(
                                pass.text.length >= minPasswordLength &&
                                        pass.text.length <= maxPasswordLength
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: pass.text.length >= minPasswordLength &&
                                        pass.text.length <= maxPasswordLength
                                    ? Colors.green
                                    : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "- Be between $minPasswordLength-$maxPasswordLength characters.",
                                style: GoogleFonts.notoSerif(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
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
    if (gUser == null) return null; // User canceled the sign-in

    final GoogleSignInAuthentication gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    if (userCredential.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(isDarkMode: _isDarkMode, toggleTheme: toggleTheme),
        ),
      );
    }
    
    return userCredential;
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
      const int minPasswordLength = 8;
      const int maxPasswordLength = 20;

      bool hasUppercase = pass.text.contains(RegExp(r'[A-Z]'));
      bool hasLowercase = pass.text.contains(RegExp(r'[a-z]'));
      bool hasNumber = pass.text.contains(RegExp(r'\d'));
      bool hasSpecialChar = pass.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

      if (pass.text.isEmpty || cpass.text.isEmpty || email.text.isEmpty) {
        Navigator.pop(context);
        Get.snackbar(
            "Error", "All fields are required.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        return;
      }

      if (pass.text != cpass.text) {
        Navigator.pop(context);
        Get.snackbar(
            "Error", "Passwords do not match.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        return;
      }

      if (pass.text.length < minPasswordLength ||
          pass.text.length > maxPasswordLength ||
          !hasUppercase ||
          !hasLowercase ||
          !hasNumber ||
          !hasSpecialChar) {
        Navigator.pop(context);
        Get.snackbar(
            "Error", "Password does not meet the requirements.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white);
        return;
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text,
        password: pass.text,
      );

      Navigator.pop(context);
      await showSuccessDialog();
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
