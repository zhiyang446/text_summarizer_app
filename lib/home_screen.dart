import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/shape/gf_avatar_shape.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:text_summarizer_app/constants.dart';
import 'package:text_summarizer_app/drawer.dart';
import 'package:text_summarizer_app/function/select_file.dart';
import 'package:text_summarizer_app/function/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'function/save_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedWordIndex = -1; // Initially, no word selected
  int _selectedModeIndex = -1;
  int _selectedToneIndex = -1;
  late TextEditingController
      summaryController;
  User? _user;

  List word = ['150', '300', '500', '700', '1000'];
  List mode = ['Rephrase', 'Shorten', 'Expand', 'Email', 'Summarize'];
  List tone = ['Professional', 'Academic', 'Business', 'Friendly'];

  SelectFile selectFile = SelectFile();
  FirebaseService firebaseService =
      FirebaseService(); // Create an instance of FirebaseService

  @override
  void initState() {
    super.initState();
    _getUserInfo();
    summaryController =
        TextEditingController(); // Initialize the summaryController
  }

  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await user.reload();
      user = FirebaseAuth.instance.currentUser;

      // Use the null-aware operator to safely access uid
      String? userId = user?.uid;

      if (userId != null) {
        // Fetch additional user info from Firestore
        DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

        if (snapshot.exists) {
          setState(() {
            _user = user;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Center(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () {
                          scaffoldKey.currentState?.openDrawer();
                        },
                      ),
                      Spacer(),
                      CircleAvatar(
                        child: ClipOval(
                          child: _user != null
                              ? _user!.photoURL != null
                              ? Image.network(
                            _user!.photoURL!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                          )
                              : const Icon(
                            Icons.person,
                            size: 50,
                          )
                              : Container(),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to Summarize AI',
                        style: TextStyle(
                          fontSize: 35,
                          fontFamily: 'Teko',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Type in a summary :',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto Condensed',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 35),
                    Container(
                      child: SelectFile.isFileSelected
                          ? ElevatedButton.icon(
                              label: Text("Deselect File"),
                              icon: Icon(Icons.cancel),
                              style: ElevatedButton.styleFrom(
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                primary: Colors.red,
                              ),
                              onPressed: () {
                                SelectFile.deselectFile();
                                setState(() {});
                              },
                            )
                          : ElevatedButton.icon(
                              label: const Text(
                                "Select File",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              icon:
                                  Icon(Icons.upload_file, color: Colors.black),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey[200],
                                shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                shadowColor: Colors.grey[500],
                              ),
                              onPressed: () {
                                if (!SelectFile.isFileSelected) {
                                  SelectFile.pickFile(context);
                                  setState(() {});
                                }
                              },
                            ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                  child: SizedBox(
                    height: 150,
                    width: 500,
                    child: TextField(
                      controller: summaryController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: const TextStyle(fontWeight: FontWeight.normal),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      enabled: !SelectFile.isFileSelected,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Word :',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Roboto Condensed',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(word.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 15,
                            ),
                            label: Text(word[index].toString()),
                            selected: _selectedWordIndex == index,
                            selectedColor: kPrimaryColor,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedWordIndex = index;
                                } else {
                                  _selectedWordIndex =
                                      -1; // Unselect when tapped again
                                }
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Mode :',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Roboto Condensed',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(mode.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 15,
                            ),
                            label: Text(mode[index].toString()),
                            selected: _selectedModeIndex == index,
                            selectedColor: kPrimaryColor,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedModeIndex = index;
                                } else {
                                  _selectedModeIndex =
                                      -1; // Unselect when tapped again
                                }
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Tone :',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Roboto Condensed',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(tone.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ChoiceChip(
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 15,
                            ),
                            label: Text(tone[index].toString()),
                            selected: _selectedToneIndex == index,
                            selectedColor: kPrimaryColor,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedToneIndex = index;
                                } else {
                                  _selectedToneIndex =
                                      -1; // Unselect when tapped again
                                }
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        label: const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: const Icon(
                            Icons.send_sharp,
                            color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.fromLTRB(80, 10, 80, 10),
                          primary: kSecondaryColor,
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shadowColor: Colors.black87,
                        ),
                        onPressed: () {
                          saveUserData();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: const DrawerBar(),
    );
  }
  void saveUserData() {
    SaveData.saveUserData(
      context: context,
      summaryController: summaryController,
      selectedWordIndex: _selectedWordIndex,
      selectedModeIndex: _selectedModeIndex,
      selectedToneIndex: _selectedToneIndex,
    );
  }
}
