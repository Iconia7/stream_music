// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const ProfileScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = "";
  String _email = "";
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _email = user.email ?? "No email provided";
        _name = user.displayName ?? _deriveNameFromEmail(_email);
      });
    }
  }

  String _deriveNameFromEmail(String email) {
    return email.split('@').first.replaceAll('.', ' ').replaceAll('_', ' ');
  }

  Future<void> _changeProfilePhoto() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child('${user.uid}.jpg');

        // Upload the photo to Firebase Storage
        await storageRef.putFile(File(pickedFile.path));
        final downloadUrl = await storageRef.getDownloadURL();

        // Update the user's photoURL
        await user.updatePhotoURL(downloadUrl);

        setState(() {});  // Refresh the UI
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo updated successfully!")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile photo: $e")),
        );
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: _email.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildAccountSettings(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Image.asset('assets/images/Stream_logo.png', width: 100),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.blue),
                  onPressed: _changeProfilePhoto,
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditProfileDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Account Settings",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListTile(
          title: const Text("Change Email"),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showChangeEmailDialog(context),
        ),
        ListTile(
          title: const Text("Change Password"),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showChangePasswordDialog(context),
        ),
        ListTile(
          title: const Text("Log Out"),
          trailing: const Icon(Icons.exit_to_app),
          onTap: () => _logOut(context),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(text: _name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: "Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await user.updateDisplayName(nameController.text);
                setState(() {
                  _name = nameController.text;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Email"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: "New Email"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                try {
                  // ignore: deprecated_member_use
                  await user.updateEmail(emailController.text);
                  setState(() {
                    _email = emailController.text;
                  });
                } catch (e) {
                  debugPrint("Failed to update email: $e");
                }
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: "New Password"),
          obscureText: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                try {
                  await user.updatePassword(passwordController.text);
                  debugPrint("Password updated successfully.");
                } catch (e) {
                  debugPrint("Failed to update password: $e");
                }
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _logOut(BuildContext context) async {
  try {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Sign out from Google (if Google Sign-In is used)
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    // Navigate to the login screen
    Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    debugPrint('Error during logout: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to log out. Please try again.')),
    );
  }
}
}
