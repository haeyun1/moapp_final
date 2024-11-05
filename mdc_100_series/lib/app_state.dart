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

class AppState extends ChangeNotifier {
  AppState() {
    init();
  }
  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  StreamSubscription<QuerySnapshot>? _productsSubscription;
  List<Product> _products = []; // 제품 리스트
  List<Product> get products => _products;

  // Firebase 초기화 및 Firebase 인증, Firestore 구독 설정
  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _productsSubscription = FirebaseFirestore.instance
            .collection('product')
            .snapshots()
            .listen((snapshot) {
          _products = [];
          for (final document in snapshot.docs) {
            _products.add(Product(
                id: document.id,
                name: document.data()['name'] as String,
                price: document.data()['price'] as int,
                description: document.data()['description'] as String));
          }
          notifyListeners();
        });
      } else {
        _loggedIn = false;
        _products = [];
        user = null;
        _productsSubscription?.cancel();
      }
      notifyListeners();
    });
  }
}

Future<void> addUserToFireStore() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    final docRef =
        FirebaseFirestore.instance.collection('user').doc(currentUser.uid);

    if (!currentUser.isAnonymous) {
      // Google 계정으로 로그인한 경우
      return docRef.set(<String, dynamic>{
        'uid': currentUser.uid,
        'name': currentUser.displayName,
        'status_message': "I promise to take the test honestly before GOD.",
        'email': currentUser.email,
      });
    } else {
      // 익명으로 로그인한 경우
      return docRef.set(<String, dynamic>{
        'uid': currentUser.uid,
        'status_message': "I promise to take the test honestly before GOD.",
      });
    }
  }
}
