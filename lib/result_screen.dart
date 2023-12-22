import 'package:flutter/material.dart';
import 'package:text_summarizer_app/constants.dart';
import 'package:clipboard/clipboard.dart';
import 'package:text_summarizer_app/home_screen.dart';

import 'function/firebase_service.dart';
import 'function/summary_processing.dart';
import 'loading_screen.dart';

class ResultScreen extends StatefulWidget {
  final String summary;

  ResultScreen({Key? key, required this.summary}) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String currentSummary = '';

  @override
  void initState() {
    super.initState();
    // Initialize the local variable with the initial summary
    currentSummary = widget.summary;
  }

  Future<void> regenerateAnswer() async {
    try {
      // Navigate to the loading screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoadingScreen()),
      );

      // Get historical data from Firebase
      List<Map<String, dynamic>> historicalData = await FirebaseService().getHistoricalData();

      // Initialize summary processor
      SummaryProcessor summaryProcessor = SummaryProcessor();

      // Process summary from input text with historical data
      String regeneratedSummary = await summaryProcessor.generateSummaryFromText(
        summary: currentSummary,
        selectedlanguageIndex: 0, // Replace with the actual index
        selectedModeIndex: 0, // Replace with the actual index
        selectedToneIndex: 0, // Replace with the actual index
        historicalData: historicalData, // Provide historical data here
      );

      // Update the local variable with the new summary
      setState(() {
        currentSummary = regeneratedSummary;
      });

      // Optionally, you can show a snackbar or toast to indicate that the summary has been regenerated.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Summary Regenerated'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error regenerating summary: $error');
      // Handle error if needed
    } finally {
      // Navigate back to the ResultScreen
      Navigator.pop(context);
    }
  }


  void copyToClipboard() {
    FlutterClipboard.copy(currentSummary);

    // Optionally, you can show a snackbar or toast to indicate that the text has been copied.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2), // You can adjust the duration as needed
      ),
    );
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 500,
                          width: 500,
                          child: Center(
                            child: SingleChildScrollView(
                              child: Text(
                                currentSummary,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white60,
                          onPrimary: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: copyToClipboard,
                        child: Icon(Icons.copy),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.black,
                        side: const BorderSide(
                          width: 2.0,
                          color: Colors.black
                        ),
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                      ),
                      onPressed:() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 20,),
                    ElevatedButton(
                      onPressed: regenerateAnswer,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(20),
                        backgroundColor: kSecondaryColor,
                        onPrimary: Colors.white,
                        textStyle: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Roboto Condensed'),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text('Regenerate Answer'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
