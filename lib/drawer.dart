import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DrawerBar extends StatefulWidget {
  const DrawerBar({Key? key}) : super(key: key);

  @override
  State<DrawerBar> createState() => _DrawerBarState();
}

class _DrawerBarState extends State<DrawerBar> {
  User? _user;
  String _displayName = 'No Name';
  String _email = 'No Email';

  @override
  void initState() {
    super.initState();
    _getUserInfo();
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
            _displayName = snapshot.data()?['username'] ?? 'No Name';
            _email = snapshot.data()?['email'] ?? 'No Email';
            _user = user;
          });
        }
      }
    }
  }

  Future<void> _signOut() async {
    // Show an AlertDialog before logging out
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log Out'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the AlertDialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // Navigate to the login page
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: _user != null
                ? Text(
              _displayName,
              style: TextStyle(
                color: Colors.white,
              ),
            )
                : Text('Loading...'),
            accountEmail: _user != null
                ? Text(
              _email,
              style: TextStyle(color: Colors.white),
            )
                : Text('Loading...'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: _user != null
                    ? _user!.photoURL != null
                    ? Image.network(
                  _user!.photoURL!,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.person,
                  size: 50,
                )
                    : Container(),
              ),
            ),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('History'),
            onTap: () {
              // Add logic for handling history
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Add logic for handling settings
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}
