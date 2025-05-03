import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/Lawyer screens/lawSuitDetails.dart';

class LawsuitCard extends StatefulWidget {
  final String title;
  final String status;
  final String rid;
  final String username;
  final String date;
  final String time;

  const LawsuitCard({
    super.key,
    required this.title,
    required this.status,
    required this.rid,
    required this.username,
    required this.date,
    required this.time,
  });

  @override
  State<LawsuitCard> createState() => _LawsuitCardState();
}

class _LawsuitCardState extends State<LawsuitCard> {
  FirebaseFirestore fyre = FirebaseFirestore.instance;
  String? requestId;
  String? status;
  String? userImageUrl; // URL of the user profile pic

  @override
  void initState() {
    super.initState();
    status = widget.status;
    fetchRequestId();
  }

  /// Fetch user profile picture URL from Firestore
  Future<String?> fetchUserPic() async {
    try {
      var querySnapshot = await fyre
          .collection('account')
          .where('name', isEqualTo: widget.username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data();
        return data['imageUrl'] ?? null;
      }
    } catch (e) {
      print("Error fetching user pic: $e");
    }
    return null;
  }

  /// Fetch the Firestore document ID for this request
  Future<void> fetchRequestId() async {
    try {
      var querySnapshot = await fyre
          .collection('requests')
          .where('rid', isEqualTo: widget.rid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        requestId = querySnapshot.docs.first.id;
        setState(() {}); // optional
      }
    } catch (e) {
      print("Error fetching request ID: $e");
    }
  }

  /// Update request status in Firestore
  Future<void> updateRequestStatus(String newStatus) async {
    if (requestId == null) return;

    try {
      await fyre
          .collection('requests')
          .doc(requestId)
          .update({'status': newStatus});
      if (mounted) {
        setState(() {
          status = newStatus;
        });
      }
    } catch (e) {
      print("Error updating Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == 'Accepted'
        ? const Color.fromARGB(255, 76, 175, 79)
        : status == 'Pending'
            ? const Color.fromARGB(255, 255, 153, 0)
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and View Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text("Status: $status",
                      style: TextStyle(color: Colors.white)),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(Lawsuit(rid: widget.rid),
                        transition: Transition.downToUp);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 14, 32, 41),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text("View details",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 👤 FutureBuilder for user image + name + title
            FutureBuilder<String?>(
              future: fetchUserPic(),
              builder: (context, snapshot) {
                String imageUrl = snapshot.data ?? ''; // default fallback image

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                          ? NetworkImage(imageUrl)
                          : AssetImage('assets/images/brad.webp')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.username,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text(widget.title,
                            style: TextStyle(color: Colors.white)),
                      ],
                    )
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.white30),
            const SizedBox(height: 8),

            // 📅 Date & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Case type: Online consultation",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text("${widget.date.substring(0, 10)}",
                    style: TextStyle(color: Colors.white70)),
                SizedBox(width: 16),
                Icon(Icons.access_time, color: Colors.white70, size: 16),
                SizedBox(width: 4),
                Text("${widget.time}", style: TextStyle(color: Colors.white70)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
