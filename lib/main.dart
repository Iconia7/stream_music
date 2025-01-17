import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/controller/musiccontroller.dart';
import 'package:project/views/screens/home.dart';
import 'package:project/views/screens/login.dart';
import 'package:project/views/screens/reset.dart';
import 'package:project/views/screens/signup.dart';
import 'package:project/views/screens/songplayer.dart';
import 'package:project/views/screens/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize MusicController globally
  Get.put(MusicController());

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Music App',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => Splashscreen()),
        GetPage(name: '/password', page: () => PasswordResetPage()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/signup', page: () => Signup()),
        GetPage(
          name: '/home',
          page: () => HomeScreen(
            isDarkMode: _isDarkMode,
            toggleTheme: toggleTheme,
          ),
        ),
        GetPage(
          name: '/song_player',
          page: () {
            final args = Get.arguments as Map<String, dynamic>;
            final song = args['song'];
            final playlist = args['playlist'];
            return SongPlayerScreen(song: song, playlist: playlist,isDarkMode: _isDarkMode,);
          },
        ),
      ],
    );
  }
}
