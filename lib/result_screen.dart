import 'package:flutter/material.dart';
import 'package:text_summarizer_app/constants.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String longResultText =
      "Your long result text goes here. ".padRight(10000, "Long text. ");

  void regenerateAnswer() {
    setState(() {
      longResultText =
          "New regenerated answer. ".padRight(10000, "Generated text. ");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Results are being displayed...',
                style: TextStyle(
                  fontFamily: 'Teko',
                  fontSize: 40,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  height: 500,
                  width: 500,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Text(
                        longResultText,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20),
                  backgroundColor: kSecondaryColor,
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontStyle: FontStyle.normal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: regenerateAnswer,
                child: Text('Regenerated Answer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
