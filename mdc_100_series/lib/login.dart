import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'app_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final _usernameController = TextEditingController();
  // final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/diamond.png'),
                const SizedBox(height: 16.0),
                const Text('SHRINE'),
              ],
            ),
            const SizedBox(height: 120.0),
            const SizedBox(height: 12.0),
            OverflowBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  child: const Text('Google'),
                  onPressed: () async {
                    try {
                      final GoogleSignInAccount? googleUser =
                          await GoogleSignIn().signIn();
                      if (googleUser != null) {
                        final GoogleSignInAuthentication googleAuth =
                            await googleUser.authentication;
                        final AuthCredential credential =
                            GoogleAuthProvider.credential(
                          accessToken: googleAuth.accessToken,
                          idToken: googleAuth.idToken,
                        );
                        await FirebaseAuth.instance
                            .signInWithCredential(credential);
                        print("Google 계정으로 로그인 완료");
                        addUserToFireStore();
                        print("Firebase에 User 정보 추가 완료");
                        Navigator.pop(context);
                      } else {
                        print('Google 로그인 취소됨');
                      }
                    } catch (e) {
                      print('Google 로그인 중 오류 발생: $e');
                    }
                  },
                ),
              ],
            ),
            OverflowBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  child: const Text('Guest'),
                  onPressed: () async {
                    try {
                      final userCredential =
                          await FirebaseAuth.instance.signInAnonymously();
                      print(
                          "Signed in with temporary account. UID: ${userCredential.user?.uid}");
                      addUserToFireStore();
                      print("Firebase에 User 정보 추가 완료");
                    } on FirebaseAuthException catch (e) {
                      switch (e.code) {
                        case "operation-not-allowed":
                          print(
                              "Anonymous auth hasn't been enabled for this project.");
                          break;
                        default:
                          print("Unknown error.");
                      }
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<DocumentReference> addUserToFireStore() async {
  if (!FirebaseAuth.instance.currentUser!.isAnonymous) {
    return FirebaseFirestore.instance.collection('user').add(<String, dynamic>{
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'status_message': "I promise to take the test honestly before GOD.",
      'email': FirebaseAuth.instance.currentUser!.email,
    });
  } else {
    //익명으로 로그인되었을 때
    return FirebaseFirestore.instance.collection('user').add(<String, dynamic>{
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'status_message': "I promise to take the test honestly before GOD.",
    });
  }
}
