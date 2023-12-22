import 'package:file_picker/file_picker.dart';
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
import 'package:text_summarizer_app/result_screen.dart';

import 'function/document_process.dart';
import 'function/openai_sercive.dart';
import 'function/save_data.dart';
import 'function/summary_processing.dart';
import 'function/upload_file.dart';
import 'loading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedlanguageIndex = -1; // Initially, no word selected
  int _selectedModeIndex = -1;
  int _selectedToneIndex = -1;
  late TextEditingController summaryController;
  User? _user;

  List language = [
    'English',
    'Chinese',
    'Korean',
    'German',
    'French',
    'Japanese'
  ];
  List mode = [
    'Expository',
    'Third Person',
    'Present Tense',
    'Bullet Point',
    'Methodologies',
    'Implications'
  ];
  List tone = [
    'Objective',
    'Formal',
    'Concise',
    'Descriptive',
    'Critical',
    'Informal'
  ];

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
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

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
                      child: ElevatedButton.icon(
                        label: Text(
                          SelectFile.isFileSelected ? "Deselect File" : "Select File",
                          style: TextStyle(
                            color:
                            SelectFile.isFileSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        icon: Icon(
                          SelectFile.isFileSelected ? Icons.cancel : Icons.upload_file,                          color:
                        SelectFile.isFileSelected ? Colors.white : Colors.black,
                        ),
                        style: ElevatedButton.styleFrom(
                          primary:
                          SelectFile.isFileSelected ? Colors.red : Colors.grey[200],
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shadowColor: Colors.grey[500],
                        ),
                        onPressed: () async {
                          if (SelectFile.isFileSelected) {
                            SelectFile.deselectFile();
                          } else {
                            // Handle file selection logic, e.g., show file picker
                            FilePickerResult? result =
                            await SelectFile.pickFile(context);
                            // After selecting a file, call SelectFile.selectFile(file);
                          }
                          // Ensure to call setState to trigger a rebuild
                          setState(() {});
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
                        'Language :',
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
                      children: List.generate(language.length, (index) {
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
                            label: Text(language[index].toString()),
                            selected: _selectedlanguageIndex == index,
                            selectedColor: kPrimaryColor,
                            shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedlanguageIndex = index;
                                } else {
                                  _selectedlanguageIndex =
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
                        onPressed: isSubmitButtonEnabled()
                            ? () {
                          saveUserData();
                        }
                            : null,
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

  Future<void> saveUserData() async {
    try {
      // Show loading screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoadingScreen()),
      );

      // Check if neither a file nor summary is selected
      if (!SelectFile.isFileSelected && summaryController.text.isEmpty) {
        // Show an error message to the user
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select a file or enter a summary to submit.'),
        ));
        return; // Exit the function early
      }

      // Check if a file is selected
      if (SelectFile.isFileSelected && SelectFile.selectedFile != null) {
        // Upload the file
        FileUploadResult? fileUploadResult =
        await FileUpload.uploadFileToBoth(SelectFile.selectedFile!);

        // Save user data with the file URL
        SaveData.saveUserData(
          context: context,
          summaryController: summaryController,
          selectedlanguageIndex: _selectedlanguageIndex,
          selectedModeIndex: _selectedModeIndex,
          selectedToneIndex: _selectedToneIndex,
          fileUploadResult: fileUploadResult,
        );

// Initialize document processor
        DocumentProcessor documentProcessor = DocumentProcessor();

// Extract text from the document and generate summary
        await documentProcessor.extractTextFromDocumentAndProcess(
          context: context,
          documentFile: SelectFile.selectedFile!,
          selectedLanguageIndex: _selectedlanguageIndex,
          selectedModeIndex: _selectedModeIndex,
          selectedToneIndex: _selectedToneIndex,
        );

      } else {
        // Save user data without a file URL
        SaveData.saveUserData(
          context: context,
          summaryController: summaryController,
          selectedlanguageIndex: _selectedlanguageIndex,
          selectedModeIndex: _selectedModeIndex,
          selectedToneIndex: _selectedToneIndex,
          fileUploadResult: null,
        );
        List<Map<String, dynamic>> historicalData = await FirebaseService().getHistoricalData();
        // Initialize summary processor
        SummaryProcessor summaryProcessor = SummaryProcessor();

        // Process summary from input text
        String generatedSummary =
        await summaryProcessor.generateSummaryFromText(
          summary: summaryController.text,
          selectedlanguageIndex: _selectedlanguageIndex,
          selectedModeIndex: _selectedModeIndex,
          selectedToneIndex: _selectedToneIndex,
          historicalData: historicalData, // Provide historical data here
        );

        // Navigate to the result screen with the generated summary
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(summary: generatedSummary),
          ),
        );
      }
    } catch (error) {
      // Handle errors, e.g., show an error message to the user
      print('Error: $error');
      // Show an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $error'),
      ));
    }
  }

  bool isSubmitButtonEnabled() {
    if (!SelectFile.isFileSelected && summaryController.text.isEmpty) {
      return false; // Disable the button if neither a file nor summary is selected
    }
    // Add any additional validation checks here if needed
    return true; // Enable the button if the form is valid
  }
}