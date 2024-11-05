import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? _user;
  String _statusMessage = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Firestore에서 사용자 status_message 가져오기
  Future<void> _loadUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      final docRef =
          FirebaseFirestore.instance.collection('user').doc(_user!.uid);
      final docSnapshot = await docRef.get();

      // Firestore에서 사용자 status_message 필드 가져오기
      if (docSnapshot.exists &&
          docSnapshot.data()!.containsKey('status_message')) {
        setState(() {
          _statusMessage = docSnapshot['status_message'] as String;
        });
      } else {
        setState(() {
          _statusMessage = "No status message available";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAnonymous = _user?.isAnonymous ?? true;
    final email = isAnonymous ? "Anonymous" : _user?.email;
    final displayName = isAnonymous ? "" : _user?.displayName ?? "Unknown User";
    final photoUrl = isAnonymous
        ? 'https://handong.edu/site/handong/res/img/logo.png' // 익명 계정일 때 기본 이미지 URL
        : _user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            semanticLabel: 'back',
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              semanticLabel: 'logout',
            ),
            onPressed: () async {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
              await FirebaseAuth.instance.signOut();
              print("${_user?.uid} logout.");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(photoUrl!), // 이미지 URL
                  fit: BoxFit.contain, // 이미지를 꽉 채우기
                ),
              ),
            )),
            const SizedBox(height: 16),
            Text(
              '<${_user?.uid ?? "Unknown UID"}>',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$email',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              displayName,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
