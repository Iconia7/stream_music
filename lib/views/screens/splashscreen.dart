// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'package:project/views/screens/login.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  bool isLoading = false; // Add a loading state

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
          if (isLoading) // Show the loading indicator when isLoading is true
            Container(
              color: Colors.black
                  .withOpacity(0.5), // Add a semi-transparent overlay
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 249, 250, 250)),
                ),
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Stream_logo.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "STREAMS APP",
                    style: GoogleFonts.notoSerif(
                      fontSize: 35,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 250),
                  SizedBox(
                    width: 170,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            });
                        await Future.delayed(
                            const Duration(seconds: 1)); // Simulate a delay
                        Navigator.pop(context);
                        // Navigate to Login page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 1, 152, 223),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        "Get Started",
                        style: GoogleFonts.notoSerif(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50), // Reduced height
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
