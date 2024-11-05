class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
  });

  final String id;
  final String name; // 제품 이름
  final int price; // 제품 가격
  final String description;

  //String get assetName => '$id-0.jpg';
  //String get assetPackage => 'shrine_images';

  //@override
  //String toString() => "$name (id=$id)";
}
