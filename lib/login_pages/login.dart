import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Scribe/main_pages/main_page.dart';
import 'sign_up.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
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

  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          checkColor: Colors.white,
          activeColor: Colors.indigoAccent,
          onChanged: (value) {
            setState(() {
              _rememberMe = value!;
            });
          },
        ),
        const Text(
          'Remember me',
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final String email = _emailController.text.trim();
          final String password = _passwordController.text.trim();

          try {
            await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: email, password: password);
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
          'LOGIN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpText() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage()),
        );
      },
      child: const Text(
        "Don't have an account? Sign up",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          decoration: TextDecoration.underline,
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
              'Sign In',
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
            _buildPasswordTextField(),
            const SizedBox(height: 20.0),
            _buildRememberMeCheckbox(),
            _buildLoginButton(),
            const SizedBox(height: 20.0),
            _buildSignUpText(),
          ],
        ),
      ),
    );
  }
}
