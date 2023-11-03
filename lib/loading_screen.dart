import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            child: Lottie.network(
              'https://lottie.host/cdf45cde-5070-4a9b-85ad-fb9e2c593ebb/nnGltHG9Ru.json',
              width: 450,
            ),
          ),
          const Text(
            'Preparing for take off...',
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'Teko',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold
            ),
          )
        ],
      ),
    );
  }
}
