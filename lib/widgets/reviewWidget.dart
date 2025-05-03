import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LawyerReviewsWidget extends StatelessWidget {
  final String lawyerId;

  const LawyerReviewsWidget({super.key, required this.lawyerId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('lawyerId', isEqualTo: lawyerId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No reviews yet."));
        }

        final reviews = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            final data = review.data() as Map<String, dynamic>;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('account')
                  .doc(data['userId'])
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return SizedBox();
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(userData['name'] ?? 'Unknown'),
                  subtitle: Text(data['review'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      data['rating'] ?? 0,
                      (i) => Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
