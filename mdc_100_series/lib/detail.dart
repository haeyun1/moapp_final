import 'package:flutter/material.dart';
import 'model/product.dart';

class DetailPage extends StatelessWidget {
  final Product product;

  const DetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(product.creatorUid),
            Text(product.description),
            Text(product.id),
            Text(product.name),
            Text('${product.price}'),
            Text('${product.creationTime}'),
            Text('${product.recentUpdateTime}'),
          ],
        ),
      ),
    );
  }
}
