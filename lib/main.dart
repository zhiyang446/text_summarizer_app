import 'package:text_summarizer_app/constants.dart';
import 'package:text_summarizer_app/register._screen.dart';
import 'package:text_summarizer_app/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:text_summarizer_app/loading_screen.dart';
import 'package:text_summarizer_app/result_screen.dart';
import 'package:text_summarizer_app/home_screen.dart';
import 'package:text_summarizer_app/drawer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:text_summarizer_app/history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Summarizer AI',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kBackgroundColor,
        textTheme: const TextTheme(
          headlineLarge:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          labelLarge:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.italic),
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.white.withOpacity(.2),
            ),
          ),
        ),
      ),
      home:  WelcomeScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/login':(context) => SignInScreen(),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/welcome.jpg"),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: "Text Summarizer AI\n",
                          style: TextStyle(
                            fontFamily: 'Teko',
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          )),
                      TextSpan(
                          text: "Discover and summarize long texts with ease !",
                          style: TextStyle(
                            fontFamily: 'Roboto Condensed',
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ))
                    ],
                  ),
                ),
                FittedBox(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return SignInScreen();
                        },
                      ));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 80),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 120, vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: kSecondaryColor,
                      ),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Get Started",
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
