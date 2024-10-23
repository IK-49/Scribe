import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Scribe/main_pages/main_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Widget _buildEmailTextField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.email, color: Colors.indigoAccent),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildUsernameTextField() {
    return TextField(
      controller: _displayNameController,
      keyboardType: TextInputType.text,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Username',
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.person, color: Colors.indigoAccent),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: const Icon(Icons.lock, color: Colors.indigoAccent),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final String email = _emailController.text.trim();
          final String displayName = _displayNameController.text.trim();
          final String password = _passwordController.text.trim();

          try {
            final UserCredential userCredential = await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: email, password: password);
            User? user = FirebaseAuth.instance.currentUser;
            await user?.updateDisplayName(displayName);
            await user?.reload();
            user = FirebaseAuth.instance.currentUser;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          } on FirebaseAuthException catch (e) {
            print('Error: ${e.message}');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigoAccent,
          padding: const EdgeInsets.all(15.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: const Text(
          'SIGN UP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB3E5FC), // Light Blue
              Color(0xFF536DFE), // Indigo Accent
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 100.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Create Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40.0),
            _buildEmailTextField(),
            const SizedBox(height: 20.0),
            _buildUsernameTextField(),
            const SizedBox(height: 20.0),
            _buildPasswordTextField(),
            const SizedBox(height: 30.0),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }
}
