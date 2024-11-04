class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
  });

  final int id;
  final String name; // 제품 이름
  final int price; // 제품 가격

  String get assetName => '$id-0.jpg';
  String get assetPackage => 'shrine_images';

  @override
  String toString() => "$name (id=$id)";
}
