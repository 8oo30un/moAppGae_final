import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shrine/editproduct.dart';
import 'package:shrine/wishlist.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool _isLiked = false;
  int _likeCount = 0;
  String? _currentUid;

  @override
  void initState() {
    super.initState();
    _currentUid = FirebaseAuth.instance.currentUser?.uid;
    _fetchLikeData();
  }

  Future<void> _fetchLikeData() async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .get();
    final data = doc.data()!;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    setState(() {
      _likeCount = data['likeCount'] ?? 0;
      _isLiked = _currentUid != null && likedBy.contains(_currentUid);
    });
  }

  Future<void> _toggleLike() async {
    if (_currentUid == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('로그인 후 이용해주세요.')));
      return;
    }

    final productRef =
        FirebaseFirestore.instance.collection('products').doc(widget.productId);
    final doc = await productRef.get();
    final data = doc.data()!;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    final likeCount = data['likeCount'] ?? 0;

    if (_isLiked) {
      // 이미 좋아요 눌렀으면 SnackBar 경고
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('이미 좋아요를 눌렀습니다.')));
      return;
    }

    likedBy.add(_currentUid!);

    await productRef.update({
      'likedBy': likedBy,
      'likeCount': likeCount + 1,
    });

    setState(() {
      _isLiked = true;
      _likeCount = likeCount + 1;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('좋아요가 등록되었습니다!')));
  }

  @override
  Widget build(BuildContext context) {
    // 기존 상세 UI 아래 좋아요 버튼만 추가된 형태
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 상세'),
        actions: [
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('products')
                .doc(widget.productId)
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final isOwner = data['uid'] == _currentUid;

              if (!isOwner) return const SizedBox.shrink();

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProductPage(productId: widget.productId),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('정말 삭제하시겠습니까?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('취소')),
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('삭제')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await FirebaseFirestore.instance
                            .collection('products')
                            .doc(widget.productId)
                            .delete();
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                  ),
                ],
              );
            },
          )
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('에러 발생'));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Image.network(data['imageUrl'], height: 200, fit: BoxFit.cover),
                const SizedBox(height: 16),
                Text(data['name'],
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('₩${data['price']}'),
                const SizedBox(height: 8),
                Text(data['description'] ?? ''),
                const Divider(height: 24),
                Text('작성자 UID: ${data['uid']}'),
                // 좋아요 상태 및 버튼
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                          _isLiked ? Icons.thumb_up : Icons.thumb_up_off_alt,
                          color: _isLiked ? Colors.blue : null),
                      onPressed: _toggleLike,
                    ),
                    Text('$_likeCount'),
                  ],
                ),
                // 기존 수정/삭제 버튼 등은 그대로 유지
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          final isInWishlist = wishlist.isInWishlist(widget.productId);
          return FloatingActionButton(
            onPressed: () {
              wishlist.toggle(widget.productId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isInWishlist ? '위시리스트에서 제거됨' : '위시리스트에 추가됨'),
                ),
              );
            },
            child: Icon(
              isInWishlist ? Icons.check : Icons.shopping_cart,
            ),
          );
        },
      ),
    );
  }
}
