import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _nameController = TextEditingController();

  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Add'),
        actions: <Widget>[
          TextButton(
              child: const Text("Save"),
              onPressed: () async {
                await addProducts(_nameController.text, _priceController.text,
                    _descriptionController.text);

                Navigator.pop(context); // 수정 필요
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            )
          ],
        ),
      ),
    );
  }
}

Future<DocumentReference> addProducts(
    String name, String price, String description) {
  return FirebaseFirestore.instance.collection('product').add(<String, dynamic>{
    'name': name,
    'price': int.parse(price),
    'description': description,
  });
}
