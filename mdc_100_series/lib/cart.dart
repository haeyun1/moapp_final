import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model/product.dart';
import 'app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Wish List'),
        ),
        body: const Center(
          child: Text('Please log in to view your cart.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wish List'),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final List<Product> cartItems = appState.cart;

          if (cartItems.isEmpty) {
            return const Center(
              child: Text('Your cart is empty.'),
            );
          }

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final product = cartItems[index];
              return ListTile(
                leading: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                        child: const Icon(Icons.image_not_supported),
                      ),
                title: Text(product.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Firestore에서 제품을 삭제
                    FirebaseFirestore.instance
                        .collection('user')
                        .doc(user.uid)
                        .collection('cart')
                        .doc(product.id)
                        .delete();

                    // AppState의 cart가 Firestore와 동기화되어 Consumer가 자동으로 UI 업데이트
                    appState.removeFromCart(product);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
