import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shrine/detail.dart';
import 'package:shrine/list.dart';
import 'package:shrine/profile.dart';
import 'package:shrine/wishlist.dart';
import 'addproduct.dart'; // AddProductPage가 들어있는 파일명

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _sortOrder = 'desc'; // default: 최신순

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.person), // 프로필 아이콘
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
        ),
        title: const Text('Main'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_cart), // 위시리스트 이동
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add), // 제품 추가
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _sortOrder = 'asc';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _sortOrder == 'asc' ? Colors.blue : Colors.grey[300],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('가격 낮은순'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _sortOrder = 'desc';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _sortOrder == 'desc' ? Colors.blue : Colors.grey[300],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('가격 높은순'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('price', descending: _sortOrder == 'desc')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return const Center(child: Text('에러 발생'));
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                return GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16.0),
                  childAspectRatio: 8.0 / 9.0,
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailPage(productId: doc.id),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          _buildCard(data, theme), // 기존 카드 UI
                          if (context
                              .watch<WishlistProvider>()
                              .isInWishlist(doc.id))
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(Icons.check_circle,
                                  color: Colors.orange),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildCard(Map<String, dynamic> product, ThemeData theme) {
    final formatter = NumberFormat.simpleCurrency(locale: 'ko_KR');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 18 / 11,
            child: Image.network(
              product['imageUrl'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product['name'] ?? '',
                    style: theme.textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    formatter.format(product['price'] ?? 0),
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
