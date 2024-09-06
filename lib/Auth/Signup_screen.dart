import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:samplechat/Auth/Login_screen.dart';
import 'package:samplechat/Constants/Constants.dart';
import 'package:samplechat/Messages/Message_page.dart';
class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Future<void> signIn() async {
  //   if (_formKey.currentState!.validate()) {
  //     try {
  //       UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: _emailController.text,
  //         password: _passwordController.text,
  //       );
  //       if (user != null) {
  //         await FirebaseFirestore.instance.collection('users').doc(user.user?.uid).set({
  //           'email': user.user?.email,
  //           'username': user.user?.displayName ?? user.user?.email,
  //           'isOnline': true,
  //         }, SetOptions(merge: true));
  //         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UsersListScreen()));
  //       }
  //     } catch (e) {
  //       print(e);
  //     }
  //   }
  // }

  Future<void> signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential user =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.user?.uid)
              .set({
            'email': user.user?.email,
            'username': user.user?.displayName ?? user.user?.email,
            'isOnline': true,
          }, SetOptions(merge: true));
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => MessagePage()));
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            width: double.infinity,
            height: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.fromLTRB(0, 100, 0, 0)),
                      Text(
                        'SignUp',
                        style: TextStyle(
                          color: bgcolor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Welcome aboard! ",
                        style: TextStyle(
                            fontSize: 26,
                            color: Colors.black,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        ' Sign up and share your love.',
                      ),
                      const SizedBox(height: 10.0),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(height: 30),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                                fillColor: Colors.grey[200],
                                filled: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.lock),
                                fillColor: Colors.grey[200],
                                filled: true,
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            // SizedBox(height: 30),
                            // ElevatedButton(
                            //   onPressed: signIn,
                            //   style: ElevatedButton.styleFrom(
                            //     padding: EdgeInsets.all(16.0),
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(12),
                            //     ),
                            //     backgroundColor: Colors.blueAccent,
                            //   ),
                            //   child: Text(
                            //     'Sign In',
                            //     style: TextStyle(fontSize: 18),
                            //   ),
                            // ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: signUp,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: bgcolor,
                              ),
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Already have an Account?",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color:
                                        const Color.fromARGB(255, 66, 66, 66),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()),
                                    );
                                  },
                                  child: Text(
                                    ' Login',
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            bgcolor // This color won't be used; it will be overridden by the gradient
                                        ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ]),
              ),
            )));
  }
}
