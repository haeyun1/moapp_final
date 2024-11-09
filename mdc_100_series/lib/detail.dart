import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

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
  bool isIncart = false;

  @override
  void initState() {
    super.initState();
    _checkIfLiked();
    _checkIfIncart();
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

  Future<void> _checkIfIncart() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final isInCart = await appState.isInCart(widget.product);
    setState(() {
      isIncart = isInCart;
    });
  }

  Future<void> _toggleLike(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final productDoc =
        FirebaseFirestore.instance.collection('product').doc(widget.product.id);
    final likeDoc = productDoc.collection('likes').doc(user.uid);

    if (hasLiked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only like it once!")),
      );
    } else {
      await likeDoc.set({
        'likedAt': FieldValue.serverTimestamp(),
      });
      await productDoc.update({
        'likes': FieldValue.increment(1),
      });
      setState(() {
        hasLiked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Liked!")),
      );
    }
  }

  Future<void> _togglecart(BuildContext context) async {
    final appState = context.read<AppState>();

    if (isIncart) {
      await appState.removeFromCart(widget.product);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from cart!")),
      );
    } else {
      await appState.addToCart(widget.product);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to cart!")),
      );
    }

    setState(() {
      isIncart = !isIncart;
    });
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final productRef =
        FirebaseFirestore.instance.collection('product').doc(widget.product.id);

    // 1. 모든 'likes' 서브컬렉션의 문서를 삭제
    final likesSnapshot = await productRef.collection('likes').get();
    for (var doc in likesSnapshot.docs) {
      await doc.reference.delete();
    }

    // 2. 제품 문서 삭제
    await productRef.delete();

    // 3. 장바구니에서도 제품 삭제
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.removeFromCart(widget.product);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appstate, child) {
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

        bool isIncart = this.isIncart;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail'),
            actions: [
              if (FirebaseAuth.instance.currentUser?.uid ==
                  widget.product.creatorUid) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPage(product: widget.product),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await _deleteProduct(context);
                  },
                ),
              ],
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 18 / 11,
                  child: widget.product.imageUrl != null &&
                          widget.product.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.product.imageUrl,
                          fit: BoxFit.contain,
                        )
                      : Container(), // 이미지가 없을 경우 빈 컨테이너 표시
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   widget._product!.name,
                        //   style: Theme.of(context).textTheme.titleLarge,
                        // ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              0.7, // Limits width
                          child: Text(
                            widget._product!.name,
                            style: Theme.of(context).textTheme.titleLarge,
                            overflow:
                                TextOverflow.ellipsis, // Truncates long text
                          ),
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
                Text(
                  'creator: <${widget._product!.creatorUid}>',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  '${(widget._product!.creationTime).toDate()} Created',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  '${(widget._product!.recentUpdateTime).toDate()} Modified',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _togglecart(context),
            child: Icon(
              isIncart ? Icons.check : Icons.shopping_cart,
            ),
          ),
        );
      },
    );
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
    final fileName = path.basename(imageFile.path);
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
    setState(() {});
    Navigator.pop(context, imageUrl);
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
                  Navigator.pop(context);
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
