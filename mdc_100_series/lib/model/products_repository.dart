// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
