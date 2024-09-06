import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:samplechat/Auth/Login_screen.dart';
import 'package:samplechat/Messages/Message_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAOLX3rf-Tk7y12pyJzRpvQp19ba9G7Wro",
          authDomain: "samplechat-5d408.firebaseapp.com",
          projectId: "samplechat-5d408",
          storageBucket: "samplechat-5d408.appspot.com",
          messagingSenderId: "197519891387",
          appId: "1:197519891387:web:8ec0e693d62c300876029e",
          measurementId: "G-BTB2CE4WH9"));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample Chat',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FirebaseAuth.instance.currentUser == null
          ? LoginScreen()
          : MessagePage(),
    );
  }
}
