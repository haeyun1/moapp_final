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
    final displayName =
        isAnonymous ? "Guest" : _user?.displayName ?? "Unknown User";

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
              // await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'UID: ${_user?.uid ?? "Unknown UID"}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Email: $email',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Name: $displayName',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Status Message: $_statusMessage',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
