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
  List<Product> _wishlist = [];

  List<Product> get wishlist => _wishlist;

  void addToWishlist(Product product) {
    _wishlist.add(product);
    notifyListeners();
  }

  void removeFromWishlist(Product product) {
    _wishlist.remove(product.id);
    notifyListeners();
  }

  bool isInWishlist(Product product) {
    return _wishlist.contains(product);
  }

  Future<void> addToCart(Product product) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final cartRef = FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.uid)
          .collection('cart')
          .doc(product.id);
      await cartRef.set({
        'name': product.name,
        'price': product.price,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'addedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    }
  }

  Future<void> removeFromCart(Product product) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final cartRef = FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.uid)
          .collection('cart')
          .doc(product.id);
      await cartRef.delete();
      notifyListeners();
    }
  }

  Future<bool> isInCart(Product product) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final cartRef = FirebaseFirestore.instance
          .collection('user')
          .doc(currentUser.uid)
          .collection('cart')
          .doc(product.id);
      final snapshot = await cartRef.get();
      return snapshot.exists;
    }
    return false;
  }

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
              description: document.data()['description'] as String,
              creatorUid: document.data()['creatorUid'] as String,
              recentUpdateTime:
                  document.data()['recentUpdateTime'] as Timestamp,
              creationTime: document.data()['creationTime'] as Timestamp,

              imageUrl: document.data()['imageUrl'] as String,
              likes: (document.data()['likes'] ?? 0) as int, // 좋아요 수 추가
            ));
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

// Firestore에서 유저 정보 추가
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

// Firestore에 제품 추가
Future<DocumentReference> addProducts(
    String name, String price, String description, String imageUrl) async {
  return FirebaseFirestore.instance.collection('product').add(<String, dynamic>{
    'name': name,
    'price': int.parse(price),
    'description': description,
    'creatorUid': FirebaseAuth.instance.currentUser!.uid,
    'recentUpdateTime': FieldValue.serverTimestamp(),
    'creationTime': FieldValue.serverTimestamp(),

    'imageUrl': imageUrl,
    'likes': 0, // 기본값 0으로 좋아요 수 초기화
  });
}
