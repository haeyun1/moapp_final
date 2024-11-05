import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' // 이메일 및 전화 인증 제외
    hide
        EmailAuthProvider,
        PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'model/product.dart';
// import 'model/users.dart';

class AppState extends ChangeNotifier {
  AppState() {
    init();
  }
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  StreamSubscription<QuerySnapshot>? _productsSubscription;
  List<Product> _products = []; // 제품 리스트
  List<Product> get products => _products; // 제품 리스트 접근자

  // Firebase 초기화 및 Firebase 인증, Firestore 구독 설정
  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        // Todo : 사용자 컬렉션 구독 설정
        /*_usersSubscription = FirebaseFirestore.instance
            .collection('user')
            .snapshots()
            .listen((snapshot) {
          _users = [];
          for (final document in snapshot.docs) {
            _users.add(Users(
                email: document.data()['email'] as String,
                name: user.displayName ?? '',
                uid: FirebaseAuth.instance.currentUser!.uid,
                status_message: document.data()['status_message'] as String));
          }
        });*/
        // Todo : 제품 컬렉션 구독 설정
      } else {
        _loggedIn = false;
        _products = [];
        _productsSubscription?.cancel();
      }
      notifyListeners();
    });
  }
}
