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
  StreamSubscription<QuerySnapshot>? _cartsSubscription;

  List<Product> _products = []; // 제품 리스트
  List<Product> get products => _products;

  List<Product> _cart = []; // 장바구니 리스트
  List<Product> get cart => _cart;

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
        'creatorUid': product.creatorUid,
        'recentUpdateTime': product.recentUpdateTime,
        'creationTime': product.creationTime,
        'likes': product.likes,
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

      // 로컬 상태에서도 해당 제품 제거
      _cart.removeWhere((item) => item.id == product.id);
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

        // 구독 초기화 및 데이터 가져오기
        _initializeCartSubscription(user.uid);
        _initializeProductsSubscription();
      } else {
        _loggedIn = false;
        _products = [];
        _cart = [];
        _productsSubscription?.cancel();
        _cartsSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  void _initializeCartSubscription(String userId) {
    _cartsSubscription = FirebaseFirestore.instance
        .collection('user')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .listen((snapshot) {
      // 중복 방지를 위해 매 업데이트 시 초기화
      _cart = snapshot.docs.map((document) {
        final data = document.data();
        return Product(
          id: document.id,
          name: data['name'] as String,
          price: data['price'] as int,
          description: data['description'] as String,
          creatorUid: data['creatorUid'] as String,
          recentUpdateTime: data['recentUpdateTime'] as Timestamp,
          creationTime: data['creationTime'] as Timestamp,
          imageUrl: data['imageUrl'] as String,
          likes: (data['likes'] ?? 0) as int,
        );
      }).toList();
      notifyListeners();
    });
  }

  void _initializeProductsSubscription() {
    _productsSubscription = FirebaseFirestore.instance
        .collection('product')
        .snapshots()
        .listen((snapshot) {
      _products = snapshot.docs.map((document) {
        final data = document.data();
        return Product(
          id: document.id,
          name: data['name'] as String,
          price: data['price'] as int,
          description: data['description'] as String,
          creatorUid: data['creatorUid'] as String,
          recentUpdateTime: data['recentUpdateTime'] as Timestamp,
          creationTime: data['creationTime'] as Timestamp,
          imageUrl: data['imageUrl'] as String,
          likes: (data['likes'] ?? 0) as int,
        );
      }).toList();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    _cartsSubscription?.cancel();
    super.dispose();
  }
}

// Firestore에서 유저 정보 추가
Future<void> addUserToFireStore() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    final docRef =
        FirebaseFirestore.instance.collection('user').doc(currentUser.uid);

    if (!currentUser.isAnonymous) {
      return docRef.set(<String, dynamic>{
        'uid': currentUser.uid,
        'name': currentUser.displayName,
        'status_message': "I promise to take the test honestly before GOD.",
        'email': currentUser.email,
      });
    } else {
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
