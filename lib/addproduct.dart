import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  static const String defaultImageUrl =
      'http://handong.edu/site/handong/res/img/logo.png';

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

    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final description = _descriptionController.text.trim();

    String imageUrl = defaultImageUrl;

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
      appBar: AppBar(
        title: const Text('Add'),
        leadingWidth: 72,
        leading: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProduct,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 항상 기본 이미지 보이기, 선택하면 덮어쓰기
              _imageFile != null
                  ? Image.file(_imageFile!, height: 150)
                  : Image.network(defaultImageUrl, height: 150),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    tooltip: '이미지 선택',
                  ),
                ],
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
            ],
          ),
        ),
      ),
    );
  }
}
