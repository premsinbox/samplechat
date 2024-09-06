import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samplechat/Auth/Login_screen.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  String _profilePicUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfilePic();
  }

  Future<void> _loadProfilePic() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = doc.data();
        if (mounted) {
          setState(() {
            _profilePicUrl = data?['profilePicUrl'] ?? '';
          });
        }
      } catch (e) {
        // Handle errors here if needed
      }
    }
  }

  Future<void> _updateProfilePic() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final storageRef =
        FirebaseStorage.instance.ref().child('profile_pics/${user.uid}.jpg');
    await storageRef.putFile(file);
    final downloadUrl = await storageRef.getDownloadURL();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profilePicUrl': downloadUrl,
      });

      if (mounted) {
        setState(() {
          _profilePicUrl = downloadUrl;
        });
      }
    } catch (e) {
      // Handle errors here if needed
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      // Handle errors here if needed
      print('Logout error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: _profilePicUrl.isNotEmpty
                  ? NetworkImage(_profilePicUrl)
                  : AssetImage('assets/profiledp.jpg') as ImageProvider,
              radius: 50,
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                _updateProfilePic();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                  color: Color.fromARGB(64, 76, 175, 92),
                ),
                padding: EdgeInsets.fromLTRB(4, 5, 4, 5),
                child: Center(
                  child: Text(
                    'Update Profile Picture',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Email: ${user?.email ?? 'Not logged in'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _logout();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red),
                  color: Color.fromARGB(64, 175, 76, 76),
                ),
                padding: EdgeInsets.fromLTRB(4, 5, 4, 5),
                child: Center(
                  child: Text(
                    'Log out',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Perform any cleanup if needed
    super.dispose();
  }
}
