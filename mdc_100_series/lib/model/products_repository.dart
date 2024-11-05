import 'product.dart';

class ProductsRepository {
  static List<Product> loadProducts() {
    const allProducts = <Product>[
      Product(
        id: "0",
        name: 'Vagabond sack',
        price: 120,
        description: "ㅇ",
      ),
    ];
    return allProducts.toList();
  }
}
