import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'cart.dart';
import 'app_state.dart';
import 'model/product.dart';
import 'package:firebase_auth/firebase_auth.dart' // 이메일 및 전화 인증 제외
    ;
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _sortOrder = 'ASC'; // 기본 정렬 기준

  // Product 리스트를 받아서 카드 형태로 변환하는 메서드
  List<Card> _buildGridCards(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return const <Card>[];
    }

    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    // 선택한 정렬 기준에 따라 제품 리스트를 정렬
    final sortedProducts = List<Product>.from(products);
    sortedProducts.sort((a, b) => _sortOrder == 'ASC'
        ? a.price.compareTo(b.price)
        : b.price.compareTo(a.price));

    Future<bool> isInCart(String productId) async {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final cartRef = FirebaseFirestore.instance
            .collection('user')
            .doc(currentUser.uid)
            .collection('cart')
            .doc(productId);
        final snapshot = await cartRef.get();
        return snapshot.exists;
      }
      return false;
    }

    return sortedProducts.map((product) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 이미지 표시
                AspectRatio(
                  aspectRatio: 18 / 11,
                  child: product.imageUrl != null && product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          'https://handong.edu/site/handong/res/img/logo.png',
                          fit: BoxFit.cover,
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        formatter.format(product.price),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // 체크 아이콘 추가
            /*if (isInCart('${product.id}') == true)
              Positioned(
                top: 8.0,
                right: 8.0,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                ),
              ),*/
            FutureBuilder(
              future: isInCart(product.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                if (snapshot.hasData && snapshot.data == true) {
                  return const Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                    ),
                  );
                }
                return Container();
              },
            ),

            Positioned(
              right: 8.0,
              bottom: 8.0,
              child: TextButton(
                onPressed: () async {
                  // 상세 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(product: product),
                    ),
                  ).then((_) {
                    setState(() {}); // Detail 페이지에서 돌아온 후 상태 업데이트
                  });
                },
                child: const Text(
                  'more',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // 정렬 기준을 업데이트하는 메서드
  void _updateSortOrder(String sortOrder) {
    setState(() {
      _sortOrder = sortOrder;
    });
  }

  Future<bool> _checkIfInCart(Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final cartDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(user.uid)
        .collection('cart')
        .doc(product.id)
        .get();

    return cartDoc.exists;
  }

  @override
  Widget build(BuildContext context) {
    // AppState의 products 리스트를 Provider를 통해 가져옴
    final products = context.watch<AppState>().products;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.person,
            semanticLabel: 'profile',
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        title: const Text('Main'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              semanticLabel: 'cart',
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(),
                ),
              ).then((_) {
                setState(() {}); // Detail 페이지에서 돌아온 후 상태 업데이트
              });
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
              semanticLabel: 'add_product',
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/addproduct');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // DropdownButtonExample에서 선택한 정렬 기준을 _updateSortOrder로 전달
          Center(
            child: DropdownButtonExample(onSortOrderChanged: _updateSortOrder),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              childAspectRatio: 8.0 / 9.0,
              children: _buildGridCards(context, products),
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  final ValueChanged<String> onSortOrderChanged;

  const DropdownButtonExample({Key? key, required this.onSortOrderChanged})
      : super(key: key);

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

const List<String> list = <String>['ASC', 'DESC'];

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_drop_down_sharp),
      elevation: 0,
      alignment: AlignmentDirectional.centerStart,
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
        // 선택한 정렬 기준을 콜백으로 전달
        widget.onSortOrderChanged(dropdownValue);
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
