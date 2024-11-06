import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.creatorUid,
    required this.creationTime,
    required this.recentUpdateTime,
    required this.imageUrl,
    this.likes = 0, // 좋아요 수 추가, 기본값은 0
  });

  final String id;
  final String name; // 제품 이름
  final int price; // 제품 가격
  final String description;
  final String creatorUid;
  final Timestamp creationTime;
  final Timestamp recentUpdateTime;
  final String imageUrl;
  final int likes; // 좋아요 수 필드
}
