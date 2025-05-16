import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

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
  File? _imageFile;

  final picker = ImagePicker();

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

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _imageUrl = null; // 로컬 이미지 우선 표시하기 위해 URL 무효화
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef =
          FirebaseStorage.instance.ref().child('product_images/$fileName');
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print('이미지 업로드 실패: $e');
      return null;
    }
  }

  Future<void> _saveChanges() async {
    String? imageUrlToSave = _imageUrl;

    if (_imageFile != null) {
      final uploadedUrl = await _uploadImage(_imageFile!);
      if (uploadedUrl != null) {
        imageUrlToSave = uploadedUrl;
      }
    }

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
      'imageUrl': imageUrlToSave,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      Navigator.pop(context);
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
      appBar: AppBar(
        title: const Text('상품 수정'),
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
            onPressed: _saveChanges,
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
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center, // 여기 수정
              children: [
                // 이미지 영역
                _imageFile != null
                    ? Image.file(
                        _imageFile!,
                        width: double.infinity, // 화면 너비에 꽉 차도록
                        fit: BoxFit.fitWidth, // 원본 비율 유지하며 너비에 맞춤
                      )
                    : (_imageUrl != null
                        ? Image.network(
                            _imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          )
                        : const SizedBox.shrink()),

                // 이미지 바로 아래에 카메라 아이콘 오른쪽 끝 배치
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.black54),
                      onPressed: _pickImage,
                    ),
                  ],
                ),
              ],
            ),
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
          ],
        ),
      ),
    );
  }
}
