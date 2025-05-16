import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('상품 상세')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('에러 발생'));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final isOwner = data['uid'] == currentUid;

          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
          final formatter = DateFormat('yyyy-MM-dd HH:mm');

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
                Text(
                    '생성일: ${createdAt != null ? formatter.format(createdAt) : '-'}'),
                Text(
                    '수정일: ${updatedAt != null ? formatter.format(updatedAt) : '-'}'),
                const SizedBox(height: 16),
                if (isOwner)
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: 수정 페이지로 이동
                        },
                        icon: const Icon(Icons.create),
                        label: const Text('수정'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('정말 삭제할까요?'),
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
                                .doc(productId)
                                .delete();
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('삭제'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                      ),
                    ],
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
