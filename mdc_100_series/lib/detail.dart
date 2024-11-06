import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'model/product.dart';

class DetailPage extends StatefulWidget {
  final Product product;
  Product? _product;

  DetailPage({Key? key, required this.product}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool hasLiked = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final likeDoc = await FirebaseFirestore.instance
        .collection('product')
        .doc(widget.product.id)
        .collection('likes')
        .doc(user.uid)
        .get();

    setState(() {
      hasLiked = likeDoc.exists;
    });
  }

  Future<void> _toggleLike(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (hasLiked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only do it once !!")),
      );
    } else {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final productDoc = FirebaseFirestore.instance
            .collection('product')
            .doc(widget.product.id);

        transaction.update(productDoc, {
          'likes': FieldValue.increment(1),
        });
      });

      setState(() {
        hasLiked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("I LIKE IT !")),
      );
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('product')
        .doc(widget.product.id)
        .delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, appstate, child) {
      widget._product = appstate.products.firstWhere(
        (p) => p.id == widget.product.id,
        orElse: () => Product(
          id: '1234',
          name: '',
          price: 0,
          description: '',
          creatorUid: '',
          creationTime: Timestamp.now(),
          recentUpdateTime: Timestamp.now(),
          imageUrl: '',
          likes: 0,
        ),
      );
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPage(product: widget._product!),
                  ),
                );
                if (result == true) {
                  // EditPage에서 true 반환 시에만 새로고침 없이 StreamBuilder가 업데이트를 반영함 데이터 다시 가져오기
                  setState(() {});
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirmDelete = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Product"),
                    content: const Text(
                        "Are you sure you want to delete this product?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
                if (confirmDelete == true) {
                  await _deleteProduct(context);
                }
              },
            ),
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('product')
              .doc(widget._product!.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Product not found.'));
            }
            final productData = snapshot.data!;
            final updatedProduct = Product(
              id: productData.id,
              name: productData['name'],
              price: productData['price'],
              description: productData['description'],
              imageUrl: productData['imageUrl'],
              creatorUid: productData['creatorUid'],
              creationTime: productData['creationTime'],
              recentUpdateTime: productData['recentUpdateTime'],
            );

            // creationTime과 recentUpdateTime이 null인지 확인하고 변환
            final creationTime = updatedProduct.creationTime != null
                ? (updatedProduct.creationTime as Timestamp).toDate()
                : null;
            final recentUpdateTime = updatedProduct.recentUpdateTime != null
                ? (updatedProduct.recentUpdateTime as Timestamp).toDate()
                : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 18 / 11,
                    child: Image.network(
                      widget._product!.imageUrl ??
                          'https://handong.edu/site/handong/res/img/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget._product!.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            '\$${widget._product!.price}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: hasLiked ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => _toggleLike(context),
                          ),
                          Text('${widget._product!.likes}'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  const Divider(),
                  const SizedBox(height: 8.0),
                  Text(
                    widget._product!.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8.0),
                  const Divider(),
                  const SizedBox(height: 8.0),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Creator: ${widget._product!.creatorUid}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Created: ${(widget._product!.creationTime).toDate()}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          'Modified: ${(widget._product!.recentUpdateTime).toDate()}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}

class EditPage extends StatefulWidget {
  final Product product;

  const EditPage({Key? key, required this.product}) : super(key: key);

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _descriptionController =
        TextEditingController(text: widget.product.description);
  }

  Future<void> _pickImage() async {
    final XFile? selectedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = selectedImage;
    });
  }

  Future<String> _uploadImage(File imageFile) async {
    final fileName = basename(imageFile.path);
    final storageRef = FirebaseStorage.instance.ref().child('images/$fileName');
    final uploadTask = storageRef.putFile(imageFile);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _updateProduct() async {
    String? imageUrl = widget.product.imageUrl; // 기존 이미지 URL

    if (_image != null) {
      imageUrl = await _uploadImage(File(_image!.path)); // 이미지 업로드 후 URL 갱신
    }

    await FirebaseFirestore.instance
        .collection('product')
        .doc(widget.product.id)
        .update({
      'recentUpdateTime': FieldValue.serverTimestamp(),
      'name': _nameController.text,
      'price': int.parse(_priceController.text),
      'description': _descriptionController.text,
      'imageUrl': imageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
        leading: TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          TextButton(
              child: const Text("Save"),
              onPressed: () async {
                try {
                  await _updateProduct();
                  setState(() {});
                  Navigator.of(context).pop(true);
                } catch (e) {
                  print(e);
                }
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: _image == null
                    ? Image.network(
                        widget.product.imageUrl ??
                            'https://handong.edu/site/handong/res/img/logo.png',
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_image!.path),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 20),
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
