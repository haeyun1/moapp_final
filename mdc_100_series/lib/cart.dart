import 'package:flutter/material.dart';
import 'model/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Your cart is empty.'),
            );
          }

          final cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItemId = cartItems[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('product')
                    .doc(cartItemId)
                    .get(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!productSnapshot.hasData ||
                      !productSnapshot.data!.exists) {
                    return Container(); // Skip rendering if product data is not found
                  }

                  final productData =
                      productSnapshot.data!.data() as Map<String, dynamic>;

                  final product = Product(
                    id: productSnapshot.data!.id,
                    name: productData['name'] ?? 'Unknown Product',
                    price: productData['price'] ?? 0,
                    description: productData['description'] ?? 'No description',
                    imageUrl: productData['imageUrl'] ?? '',
                    creatorUid: productData['creatorUid'] ?? 'Unknown',
                    creationTime:
                        productData['creationTime'] ?? Timestamp.now(),
                    recentUpdateTime:
                        productData['recentUpdateTime'] ?? Timestamp.now(),
                  );

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
                        FirebaseFirestore.instance
                            .collection('user')
                            .doc(user.uid)
                            .collection('cart')
                            .doc(product.id)
                            .delete()
                            .then((_) {
                          setState(() {}); // 삭제 후 화면 업데이트
                        });
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
