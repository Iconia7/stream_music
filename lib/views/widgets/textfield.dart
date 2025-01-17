import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color colour;
  final bool isPassword;
  final ValueChanged<String>? onChanged; // Add onChanged callback

  const MyTextField({
    super.key,
    required this.controller,
    this.hint = "",
    this.icon = Icons.abc,
    this.colour = const Color.fromARGB(255, 223, 222, 222),
    this.isPassword = false,
    this.onChanged, // Initialize onChanged
  });

  @override
  // ignore: library_private_types_in_public_api
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword && _isObscured,
        onChanged: widget.onChanged, // Pass onChanged to TextField
        decoration: InputDecoration(
          fillColor: widget.colour,
          filled: true,
          hintText: widget.hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: Colors.lightBlueAccent),
          ),
          prefixIcon: Icon(widget.icon),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
