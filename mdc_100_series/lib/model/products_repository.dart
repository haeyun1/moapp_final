import 'product.dart';

class ProductsRepository {
  static List<Product> loadProducts() {
    const allProducts = <Product>[
      Product(
        id: 0,
        name: 'Vagabond sack',
        price: 120,
      ),
      Product(
        id: 1,
        name: 'Stella sunglasses',
        price: 58,
      ),
      Product(
        id: 2,
        name: 'Whitney belt',
        price: 35,
      ),
      Product(
        id: 3,
        name: 'Garden strand',
        price: 98,
      ),
      Product(
        id: 4,
        name: 'Strut earrings',
        price: 34,
      ),
      Product(
        id: 5,
        name: 'Varsity socks',
        price: 12,
      ),
      Product(
        id: 6,
        name: 'Weave keyring',
        price: 16,
      ),
      Product(
        id: 7,
        name: 'Gatsby hat',
        price: 40,
      ),
      Product(
        id: 8,
        name: 'Shrug bag',
        price: 198,
      ),
      Product(
        id: 9,
        name: 'Gilt desk trio',
        price: 58,
      ),
      Product(
        id: 10,
        name: 'Copper wire rack',
        price: 18,
      ),
      Product(
        id: 11,
        name: 'Soothe ceramic set',
        price: 28,
      ),
    ];
    return allProducts.toList();
  }
}
