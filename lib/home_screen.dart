import 'package:flutter/material.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/shape/gf_avatar_shape.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:text_summarizer_app/constants.dart';
import 'package:text_summarizer_app/drawer.dart';
import 'package:text_summarizer_app/function/upload_file.dart';

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

  List word = ['150', '300', '500', '700', '1000'];
  List mode = ['Rephrase', 'Shorten', 'Expand', 'Email', 'Summarize'];
  List tone = ['Professional', 'Academic', 'Business', 'Friendly'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Padding(
        padding: EdgeInsets.only(top: 30),
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
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
                    GFAvatar(
                      backgroundImage: AssetImage("assets/user_profile.jpg"),
                      shape: GFAvatarShape.circle,
                      size: GFSize.LARGE,
                    ),
                  ],
                ),
                alignment: Alignment.topRight,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
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
                              fontFamily: 'Roboto Condensed'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 60),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: ElevatedButton.icon(
                            label: const Text(
                              "Upload File",
                              style: TextStyle(color: Colors.black),
                            ),
                            icon: Icon(Icons.upload_file),
                            style: ElevatedButton.styleFrom(
                                primary: Colors.white60,
                                shape: ContinuousRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                shadowColor: Colors.grey[500]),
                            onPressed: () {
                              FileUpload.uploadFile();
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.shade600,
                        spreadRadius: 1,
                        blurRadius: 5)
                  ],
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const SizedBox(
                  height: 150,
                  width: 500,
                  child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: TextStyle(fontWeight: FontWeight.normal),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Word :',
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Roboto Condensed',
                          fontWeight: FontWeight.bold),
                    )
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          label: Text(word[index].toString()),
                          selected: _selectedWordIndex == index,
                          selectedColor: kPrimaryColor,
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
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
                margin: EdgeInsets.all(20),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Mode :',
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Roboto Condensed',
                          fontWeight: FontWeight.bold),
                    )
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          label: Text(mode[index].toString()),
                          selected: _selectedModeIndex == index,
                          selectedColor: kPrimaryColor,
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
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
                margin: EdgeInsets.all(20),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Tone :',
                      style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Roboto Condensed',
                          fontWeight: FontWeight.bold),
                    )
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 15),
                          label: Text(tone[index].toString()),
                          selected: _selectedToneIndex == index,
                          selectedColor: kPrimaryColor,
                          shape: ContinuousRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    label: const Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: Icon(Icons.send),
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.fromLTRB(80, 10, 80, 10),
                        primary: kSecondaryColor,
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        shadowColor: Colors.black87),
                    onPressed: () {
                      // Add your code for the upload action here
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      drawer: const DrawerBar(),
    );
  }
}
