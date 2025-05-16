import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shrine/wishlist.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>().wishlist;

    if (wishlist.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('위시리스트')),
        body: const Center(child: Text('위시리스트가 비어 있어요!')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('위시리스트')),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .where(FieldPath.documentId, whereIn: wishlist.toList())
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('위시리스트에 상품이 없습니다.'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final productId = docs[index].id;

              return ListTile(
                leading: Image.network(data['imageUrl'],
                    width: 60, fit: BoxFit.cover),
                title: Text(data['name']),
                subtitle: Text('₩${data['price']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<WishlistProvider>().remove(productId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
