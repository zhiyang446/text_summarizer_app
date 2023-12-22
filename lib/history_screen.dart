import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'function/history_result.dart';
import 'historyresult_screen.dart';
import 'home_screen.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<QuerySnapshot<Map<String, dynamic>>> _historyCollectionFuture;
  User? user;

  @override
  void initState() {
    super.initState();
    _historyCollectionFuture = _getUserInfo();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      // Use the null-aware operator to safely access uid
      String? userId = user?.uid;

      if (userId != null) {
        setState(() {
          user = user;
        });
        return FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('summarizer')
            .get();
      }
    }

    throw Exception('User or user ID is null');
  }

  Future<Map<String, dynamic>?> getHistoryData(String summarizerId, String historyId) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String? userId = user.uid;

        if (userId != null) {
          DocumentSnapshot<Map<String, dynamic>> historySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('summarizer')
              .doc(summarizerId)
              .collection('history')
              .doc(historyId)
              .get();

          if (historySnapshot.exists) {
            return historySnapshot.data();
          } else {
            return null;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error fetching history data: $e');
      return null;
    }
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
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: _historyCollectionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available.'));
          } else {
            List<YourDataModel> data = snapshot.data!.docs.map((doc) {
              return YourDataModel.fromMap(doc.data()!);
            }).toList();

            return _buildHistoryList(data);
          }
        },
      ),
    );
  }

  Widget _buildHistoryList(List<YourDataModel> data) {
    Map<String, List<YourDataModel>> groupedData = groupDataByTime(data);

    List<String> sortedTimeCategories = groupedData.keys.toList()
      ..sort((a, b) {
        if (a == 'Today') return -1;
        if (b == 'Today') return 1;
        if (a == 'Tomorrow') return -1;
        if (b == 'Tomorrow') return 1;
        return 0;
      });

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sortedTimeCategories.length,
      itemBuilder: (context, index) {
        String timeCategory = sortedTimeCategories[index];
        List<YourDataModel> items = groupedData[timeCategory]!;

        return Container(
          margin: EdgeInsets.only(bottom: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeSubheading(timeCategory),
              SizedBox(height: 10),
              Column(
                children: items.map((item) => _buildHistoryItem(item)).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSubheading(String time) {
    return Text(
      time,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildHistoryItem(YourDataModel item) {
    String displayText = item.filename != null && item.filename!.isNotEmpty
        ? item.filename!
        : item.summary ?? '';

    String shortSummary = displayText.length > 50
        ? displayText.substring(0, 45) + '...'
        : displayText;

    return GestureDetector(
      onTap: () async {
        Map<String, dynamic>? historyData = await getHistoryData(item.summarizerId ?? '', item.historyId ?? '');

        if (historyData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HistoryResultPage(historyData: historyData),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to retrieve history data for this item.'),
          ));
        }
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



  Map<String, List<YourDataModel>> groupDataByTime(List<YourDataModel> data) {
    Map<String, List<YourDataModel>> groupedData = {};

    for (var item in data) {
      String timeCategory = categorizeByTime(item.timestamp);

      if (groupedData.containsKey(timeCategory)) {
        groupedData[timeCategory]!.add(item);
      } else {
        groupedData[timeCategory] = [item];
      }
    }

    return groupedData;
  }

  String categorizeByTime(DateTime timestamp) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(Duration(days: 1));

    if (timestamp.isAfter(today) && timestamp.isBefore(today.add(Duration(days: 1)))) {
      return 'Today';
    } else if (timestamp.isAfter(yesterday) && timestamp.isBefore(today)) {
      return 'Yesterday';
    } else if (timestamp.isAfter(today.subtract(Duration(days: 7))) && timestamp.isBefore(yesterday)) {
      return 'Previous 7 Days';
    } else {
      return 'Other';
    }
  }
}

class YourDataModel {
  final DateTime timestamp;
  final String? summary;
  final String? filename;
  final String? summarizerId;
  final String? historyId;

  YourDataModel({
    required this.timestamp,
    this.summary,
    this.filename,
    this.summarizerId,
    this.historyId,
  });

  factory YourDataModel.fromMap(Map<String, dynamic> map) {
    return YourDataModel(
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      summary: map['summary'],
      filename: map['fileName'],
      summarizerId: map['summarizerId'],
      historyId: map['historyId'],
    );
  }
}

