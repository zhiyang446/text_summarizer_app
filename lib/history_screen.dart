import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clipboard/clipboard.dart'; // Import the clipboard package

import 'home_screen.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyCollectionFuture;
  User? user;

  @override
  void initState() {
    super.initState();
    _historyCollectionFuture = getSummarizerData();
  }

  // Firebase Functions
  Future<List<Map<String, dynamic>>> getDataFromFirestore(
      String path, Map<String, dynamic> Function(QueryDocumentSnapshot) dataMapper) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userID = user.uid;
      CollectionReference collectionReference = FirebaseFirestore.instance.collection(path);

      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await collectionReference.get() as QuerySnapshot<Map<String, dynamic>>;

        return querySnapshot.docs.map((doc) => dataMapper(doc)).toList();
      } catch (e) {
        print('Error fetching data from Firestore: $e');
        throw e;
      }
    } else {
      print('User is not authenticated.');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSummarizerData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userID = user.uid;

      CollectionReference summarizerCollection =
      FirebaseFirestore.instance.collection('users/$userID/summarizer');

      try {
        QuerySnapshot<Map<String, dynamic>> summarizers =
        await summarizerCollection.get() as QuerySnapshot<Map<String, dynamic>>;
        List<Map<String, dynamic>> summarizerData = summarizers.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> summarizer) {
          //print('Document Data: ${summarizer.data()}');
          Map<String, dynamic>? data = summarizer.data();

          return {
            'summarizerID': summarizer.id,
            'timestamp': data?['timestamp'],
            'filename': data?['fileName'] ?? '',
            'summary': data?['summary'] ?? '',
            // Include other fields
          };
        }).toList();
        return summarizerData;
      } catch (e) {
        print('Error fetching summarizer data: $e');
        throw e;
      }
    } else {
      print('User is not authenticated.');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHistoricalData(String summarizerID) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userID = user.uid;

      CollectionReference historyCollection = FirebaseFirestore.instance
          .collection('users/$userID/summarizer/$summarizerID/history');

      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await historyCollection.get() as QuerySnapshot<Map<String, dynamic>>;
        List<Map<String, dynamic>> historicalData = querySnapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) {
          Map<String, dynamic>? data = doc.data();

          return {
            'historyID': doc.id,
            'timestamp': doc.data()?['timestamp'], // Replace 'timestamp' with your actual timestamp field
            'summary': doc.data()?['summary'],
            // Include other fields
          };
        }).toList();

        return historicalData;
      } catch (e) {
        print('Error fetching historical data: $e');
        throw e;
      }
    } else {
      print('User is not authenticated.');
      return [];
    }
  }

  // UI Components
  Widget _buildSummarizerList(List<Map<String, dynamic>> summarizers) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0), // Adjust the padding as needed
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: summarizers.length,
        itemBuilder: (context, index) {
          return _buildHistoryItem(context, summarizers[index]);
        },
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> summarizer) {
    String displayText = summarizer['filename'] != null && summarizer['filename'].isNotEmpty
        ? summarizer['filename']
        : summarizer['summary'] ?? '';

    String shortSummary = displayText.length > 50 ? displayText.substring(0, 45) + '...' : displayText;

    return GestureDetector(
      onTap: () async {
        showLatestHistoryPopup(context, summarizer['summarizerID']);
      },
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: BoxConstraints(
          minWidth: 400,
        ),
        child: Text(
          shortSummary,
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontFamily: 'Yanone Kaffeesatz',
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  void showLatestHistoryPopup(BuildContext context, String summarizerID) async {
    List<Map<String, dynamic>> historicalData = await getHistoricalData(summarizerID);

    if (historicalData.isNotEmpty) {
      historicalData.sort((a, b) {
        final timestampA = a['timestamp'] as Timestamp?;
        final timestampB = b['timestamp'] as Timestamp?;

        if (timestampA != null && timestampB != null) {
          return timestampB.compareTo(timestampA);
        } else {
          return 0;
        }
      });

      Map<String, dynamic> latestHistory = historicalData.first;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Latest History'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Time: ${_formatTimestamp(latestHistory['timestamp'])}'),
                Text('Summary: ${latestHistory['summary']}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        FlutterClipboard.copy(latestHistory['summary']); // Copy the summary text to the clipboard
                        Navigator.of(context).pop(); // Close the dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Summary copied to clipboard')),
                        );
                      },
                      child: Text('Copy'),
                    ),
                  ],
                ),
                // Display other historical data as needed
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No Historical Data'),
            content: Text('No historical data available for this summarizer.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDateTime = "${dateTime.toLocal()}".split('.')[0];
    return formattedDateTime;
  }

  Widget _buildCategoryHeader(String category) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        category,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDaySection(String title, List<Map<String, dynamic>> summarizers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCategoryHeader(title),
        _buildSummarizerList(summarizers),
      ],
    );
  }


  String _getDayKey(DateTime dateTime) {
    final now = DateTime.now();
    final daysDifference = now.difference(dateTime).inDays;

    if (daysDifference == 0) {
      return 'Today';
    } else if (daysDifference == 1) {
      return 'Tomorrow';
    } else if (daysDifference >= 2 && daysDifference <= 7) {
      return 'Previous 7 Days';
    } else if (daysDifference > 7) {
      return 'Previous 30 Days';
    } else {
      // Handle other cases as needed
      return 'Other';
    }
  }

  Widget _buildCopyButton(String summary) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            FlutterClipboard.copy(summary); // Copy the summary text to the clipboard
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Copied to clipboard'),
                duration: Duration(seconds: 2), // You can adjust the duration as needed
              ),
            );
          },
          child: Text('Copy'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 20, 5, 20),
          child: AppBar(
            title: Text(
              'History',
              style: TextStyle(
                fontFamily: 'Teko',
                fontSize: 40,
                fontStyle: FontStyle.italic,
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _historyCollectionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available.'));
          } else {
            List<Map<String, dynamic>> summarizerData = snapshot.data!;

            // Filter summarizers based on categories
            List<Map<String, dynamic>> todaySummarizers = [];
            List<Map<String, dynamic>> tomorrowSummarizers = [];
            List<Map<String, dynamic>> next7DaysSummarizers = [];
            List<Map<String, dynamic>> previous7DaysSummarizers = [];

            summarizerData.forEach((summarizer) {
              final timestamp = (summarizer['timestamp'] as Timestamp).toDate();
              final dayKey = _getDayKey(timestamp);

              switch (dayKey) {
                case 'Today':
                  todaySummarizers.add(summarizer);
                  break;
                case 'Tomorrow':
                  tomorrowSummarizers.add(summarizer);
                  break;
                case 'Previous 7 Days':
                  next7DaysSummarizers.add(summarizer);
                  break;
                case 'Previous 30 Days':
                  previous7DaysSummarizers.add(summarizer);
                  break;
              // Handle other cases if needed
              }
            });

            return ListView(
              children: [
                if (todaySummarizers.isNotEmpty)
                  _buildDaySection('Today', todaySummarizers),
                if (tomorrowSummarizers.isNotEmpty)
                  _buildDaySection('Tomorrow', tomorrowSummarizers),
                if (next7DaysSummarizers.isNotEmpty)
                  _buildDaySection('Previous 7 Days', next7DaysSummarizers),
                if (previous7DaysSummarizers.isNotEmpty)
                  _buildDaySection('Previous 30 Days', previous7DaysSummarizers),
              ],
            );
          }
        },
      ),
    );
  }
}
