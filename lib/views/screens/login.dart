// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/controller/logincontroller.dart';
import 'package:project/views/screens/home.dart';
import 'package:project/views/screens/reset.dart';
//import 'package:project/views/widgets/auth_page.dart';
import 'package:project/views/widgets/textfield.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

TextEditingController email = TextEditingController();
TextEditingController pass = TextEditingController();
LoginController loginController = Get.put(LoginController());

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey _emailKey = GlobalKey();
  final GlobalKey _passwordKey = GlobalKey();
  bool rememberMe = false;
  bool isLoading = false;
  bool _isDarkMode = false;

  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  void initState() {
    super.initState();
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
          if (isLoading)
            Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => Center(
                    child: Container(
                      color: Colors.black
                          // ignore: deprecated_member_use
                          .withOpacity(0.3), // Gray overlay with 30% opacity
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Image.asset('assets/images/Stream_logo.png', width: 150),
                    const SizedBox(height: 20),
                    Text(
                      "Sign In",
                      style: GoogleFonts.notoSerif(
                          fontSize: 27, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    MyTextField(
                        key: _emailKey,
                        controller: email,
                        hint: "Email",
                        colour: const Color.fromARGB(255, 223, 222, 222),
                        icon: Icons.email),
                    const SizedBox(height: 20),
                    MyTextField(
                        key: _passwordKey,
                        controller: pass,
                        hint: "Password",
                        colour: const Color.fromARGB(255, 223, 222, 222),
                        icon: Icons.lock,
                        isPassword: true),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberMe,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberMe = value ?? false;
                                  });
                                },
                              ),
                              Text(
                                "Remember Me",
                                style: GoogleFonts.notoSerif(
                                    color:
                                        const Color.fromARGB(255, 58, 57, 57)),
                              ),
                            ],
                          ),
                          TextButton(
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.notoSerif(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color:
                                      const Color.fromARGB(255, 74, 45, 240)),
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return PasswordResetPage();
                              }));
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: 350,
                      height: 70,
                      child: ElevatedButton(
                        onPressed: () {
                          if (email.text.isEmpty) {
                            _showValidationDialog(
                                context, "Please enter a Username", _emailKey);
                          } else if (pass.text.isEmpty) {
                            _showValidationDialog(context,
                                "Please enter a Password", _passwordKey);
                          } else {
                            remoteLogin();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 1, 152, 223),
                            foregroundColor: Colors.white),
                        child: Text("Login",
                            style: GoogleFonts.notoSerif(
                                fontSize: 25, fontWeight: FontWeight.bold)),
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
                          onPressed: () =>
                              signInWithGoogle(), // Disable interaction during loading
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
                                "Sign in with Google",
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
                    const SizedBox(height: 100),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account?",
                            style: GoogleFonts.notoSerif(
                                color: const Color.fromARGB(255, 58, 57, 57),
                                fontSize: 14)),
                        TextButton(
                          child: Text("SignUp",
                              style: GoogleFonts.notoSerif(
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 74, 45, 240),
                                  fontSize: 15)),
                          onPressed: () {
                            Get.toNamed("/signup");
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

  void remoteLogin() async {
    try {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: pass.text,
      );
      Navigator.pop(context);
      // Navigate to HomeScreen if login is successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                HomeScreen(isDarkMode: _isDarkMode, toggleTheme: toggleTheme)),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);

      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      Navigator.pop(context);
      print('An unexpected error occurred: $e');
    }
  }

  void _showValidationDialog(
      BuildContext context, String message, GlobalKey key) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder: (context) {
        final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
        final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

        return Positioned(
          left: offset.dx,
          top: offset.dy - 50,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}
