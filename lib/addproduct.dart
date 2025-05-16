import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageRef =
        FirebaseStorage.instance.ref().child('product_images/$fileName');

    await storageRef.putFile(imageFile);
    return await storageRef.getDownloadURL();
  }

  Future<void> _saveProduct() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ 사용자 없음 (로그인 안 됨)');
      return;
    }

    final name = _nameController.text;
    final price = int.tryParse(_priceController.text) ?? 0;
    final description = _descriptionController.text;

    String imageUrl = 'http://handong.edu/site/handong/res/img/logo.png';

    if (_imageFile != null) {
      try {
        imageUrl = await _uploadImage(_imageFile!);
      } catch (e) {
        print('❌ 이미지 업로드 실패: $e');
      }
    }

    try {
      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'price': price,
        'description': description,
        'imageUrl': imageUrl,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Firestore 저장 성공!');
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      print('❌ Firestore 저장 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _imageFile != null
                  ? Image.file(_imageFile!, height: 150)
                  : Image.network(
                      'http://handong.edu/site/handong/res/img/logo.png',
                      height: 150),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('이미지 선택'),
              ),
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
                onPressed: _saveProduct,
                child: const Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
