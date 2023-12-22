import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:text_summarizer_app/constants.dart';
import 'package:text_summarizer_app/function/firebase_service.dart';
import 'package:text_summarizer_app/history_screen.dart';
import 'package:text_summarizer_app/loading_screen.dart';

class HistoryResultPage extends StatefulWidget {
  final Map<String, dynamic> historyData;
  const HistoryResultPage({Key? key, required this.historyData}) : super(key: key);

  @override
  _HistoryResultState createState() => _HistoryResultState();
}

class _HistoryResultState extends State<HistoryResultPage> {
  String currentSummary = '';

  @override
  void initState() {
    super.initState();
    fetchSummaryFromFirebase();
  }

  Future<void> fetchSummaryFromFirebase() async {
    try {
      List<Map<String, dynamic>> historyData = await FirebaseService().getHistoricalData();
      print('history: $historyData');

      if (historyData.isNotEmpty) {
        setState(() {
          currentSummary = historyData[0]['summary'] as String;
        });
      } else {
        // Handle the case where there is no history data
        setState(() {
          currentSummary = '';
        });
      }
    } catch (error) {
      print('Error fetching history data from Firebase: $error');
      // Handle error, e.g., show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching history data: $error'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      // Close the loading overlay
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the history screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(20),
                  backgroundColor: kSecondaryColor,
                  onPrimary: Colors.white,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Roboto Condensed',
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text('Return to History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
