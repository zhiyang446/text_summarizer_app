import 'package:firebase_auth/firebase_auth.dart';
import 'package:text_summarizer_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:text_summarizer_app/home_screen.dart';
import 'package:text_summarizer_app/signin_screen.dart';
import 'package:text_summarizer_app/function/signup.dart';

import 'function/error_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final AuthService _authService = AuthService();


  Future<void> _signUp(BuildContext context) async {
    final email = _emailController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;

    // Validate email
    if (email.isEmpty || !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(email)) {
      _showErrorDialog(context, "Invalid email address");
      return;
    }

    // Validate username
    if (username.isEmpty) {
      _showErrorDialog(context, "Username cannot be empty");
      return;
    }

    // Validate password
    if (password.isEmpty || !_isPasswordValid(password)) {
      _showErrorDialog(context, "Invalid password format. It should have at least 1 uppercase, 1 lowercase, and 1 numeric character.");
      return;
    }

    try {
      User? user = await _authService.signUp(email, password, username);

      // Check if the user was successfully created
      if (user != null) {
        // Navigate to the home screen or any other screen after successful sign-up
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle the case where user is null (sign up failed)
        _showErrorDialog(context, "Sign up failed");
      }
    } catch (e) {
      // Handle error, show a message, etc.
      print(e.toString());
      _showErrorDialog(context, "Sign up failed: $e");
    }
  }

  bool _isPasswordValid(String password) {
    final RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    ErrorDialog.show(context, errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height * 1.0,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/register.jpg"),
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: <Widget>[
                      const Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: 4.0),
                              child: Text("SIGN UP",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                    fontFamily: 'BebasNeue',
                                    fontStyle: FontStyle.italic,
                                  ))),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.alternate_email,
                                color: kSecondaryColor,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _emailController, // Add this line
                                decoration: const InputDecoration(
                                  hintText: "Email Address",
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.person,
                                color: kSecondaryColor,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _usernameController, // Add this line
                                decoration: const InputDecoration(
                                  hintText: "Username",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 30),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Icon(
                                Icons.lock,
                                color: kSecondaryColor,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                obscureText: true,
                                controller: _passwordController, // Add this line
                                decoration: const InputDecoration(
                                  hintText: "Password",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: kSecondaryColor,
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _signUp(context);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: kSecondaryColor,
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          "Create Account",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: RichText(
                      text: TextSpan(children: [
                        const TextSpan(
                          text: 'Already have account? ',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                            text: 'Login',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return SignInScreen();
                                  },
                                ));
                              }),
                      ]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
