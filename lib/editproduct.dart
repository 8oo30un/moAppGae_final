import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EditProductPage extends StatefulWidget {
  final String productId;

  const EditProductPage({super.key, required this.productId});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageUrl;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();

    final data = doc.data()!;
    _nameController.text = data['name'] ?? '';
    _priceController.text = data['price'].toString();
    _descriptionController.text = data['description'] ?? '';
    _imageUrl = data['imageUrl'];

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text;
    final price = int.tryParse(_priceController.text) ?? 0;
    final description = _descriptionController.text;

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .update({
      'name': name,
      'price': price,
      'description': description,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('상품 수정')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (_imageUrl != null)
              Image.network(_imageUrl!, height: 150)
            else
              const SizedBox.shrink(),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '상품 이름'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: '가격'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '설명'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveChanges,
              child: const Text('수정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
