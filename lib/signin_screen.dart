import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_button/flutter_social_button.dart';
import 'package:flutter/gestures.dart';
import 'package:text_summarizer_app/constants.dart';
import 'package:text_summarizer_app/register._screen.dart';
import 'function/error_dialog.dart';
import 'function/sign_in_facebook_google.dart';
import 'home_screen.dart';
import 'loading_screen.dart';

class SignInScreen extends StatelessWidget {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  SignInScreen({Key? key});

  bool isPasswordValid(String password) {
    // Password should have at least 1 uppercase, 1 lowercase, and 1 numeric character
    final RegExp passwordRegex =
    RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
    return passwordRegex.hasMatch(password);
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    ErrorDialog.show(context, errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/signin.jpg"),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0, bottom: 4.0),
                    child: Text(
                      "SIGN IN",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        fontFamily: 'BebasNeue',
                        fontStyle: FontStyle.italic,
                      ),
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
                            Icons.alternate_email,
                            color: kSecondaryColor,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              hintText: "Email Address",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 15),
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
                            controller: passwordController,
                            obscureText: true,
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
                        padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: kSecondaryColor,
                        ),
                        child: GestureDetector(
                          onTap: () async {
                            String email = emailController.text;
                            String password = passwordController.text;

                            if (email.isNotEmpty && password.isNotEmpty) {
                              // Check if the password meets the specified criteria
                              if (isPasswordValid(password)) {
                                try {
                                  UserCredential? userCredential = await _authService.signInWithEmailAndPassword(email, password);

                                  if (userCredential != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => HomeScreen()),
                                    );
                                  } else {
                                    // Display an error dialog for failed login
                                    _showErrorDialog(context, 'Email and Password Login failed');
                                  }
                                } catch (e) {
                                  // Display an error dialog for exceptions during login
                                  _showErrorDialog(context, 'Error during Email and Password login: $e');
                                }
                              } else {
                                // Password does not meet the criteria
                                _showErrorDialog(
                                    context,
                                    'Invalid password format. It should have at least 1 uppercase, 1 lowercase, and 1 numeric character.'
                                );
                              }
                            } else {
                              // Fields are empty, show an error
                              _showErrorDialog(context, 'Please enter both email and password.');
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: kSecondaryColor,
                            ),
                            child: const Row(
                              children: <Widget>[
                                Text(
                                  "JOIN",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // The next part should not use Expanded if it's not in a flex context
            Container(
              margin: const EdgeInsets.fromLTRB(40, 0, 40, 0),
              height: 110,  // or use constraints to limit height
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 10),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 2, // Adjust the thickness of the divider
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: Text('or'),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 2, // Adjust the thickness of the divider
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Redesigned Facebook Login Button
                        Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: FlutterSocialButton(
                            onTap: () async{
                              try{
                                UserCredential? user = await _authService.signInWithFacebook();

                                if(user != null){
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => HomeScreen()),
                                  );
                                }else {
                                  print('Facebook Login failed');
                                }
                              } catch(e){
                                print('Error during Facebook login: $e');
                              }
                            },
                            mini: true,
                            buttonType: ButtonType.facebook,
                          ),
                        ),
                        // Redesigned Google Login Button
                        FlutterSocialButton(
                          onTap: () async {
                            try {
                              UserCredential? userCredential = await _authService.signInWithGoogle();

                              if (userCredential != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen()),
                                );
                              } else {
                                print('Google Login failed');
                              }
                            } catch (e) {
                              print('Error during Google login: $e');
                            }
                          },
                          mini: true,
                          buttonType: ButtonType.google,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(children: [
                      const TextSpan(
                        text: 'Not a Member? ',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'Sign Up',
                        style: const TextStyle(
                          color: Colors.blue,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return const RegisterScreen();
                              },
                            ));
                          },
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
