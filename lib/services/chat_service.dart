import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/message.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns a stream of user data from Firestore.
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore
        .collection("account")
        .where('isLawyer', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getAcceptedRequestsForLawyer(
      String lawyerId) {
    return FirebaseFirestore.instance
        .collection('requests')
        .where('lawyerId', isEqualTo: lawyerId)
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Map<String, dynamic>> results = [];

      for (var doc in snapshot.docs) {
        final userId = doc['userId'];
        final userSnap = await FirebaseFirestore.instance
            .collection('account') // assuming user data is here
            .doc(userId)
            .get();
        if (userSnap.exists) {
          final userData = userSnap.data()!;
          userData['request'] = doc.data();
          userData['requestId'] = doc.id;
          results.add(userData);
        }
      }

      return results;
    });
  }

  Stream<List<Map<String, dynamic>>> getLawyerStream() {
    return _firestore
        .collection("account")
        .where('isLawyer', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Sends a message to the given receiver.
  Future<void> sendMessage(
      String senderId, String receiverId, String message) async {
    // Validate that the message is not empty or just whitespace.
    if (message.trim().isEmpty) return;

    final Timestamp timestamp = Timestamp.now();

    // Create a new message instance.
    Message newMessage = Message(
      senderID: senderId,
      receiverID: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Construct chatroom id by sorting the user IDs.
    List<String> ids = [senderId, receiverId];
    ids.sort();
    String chatroomId = ids.join('_');

    // Add the new message to Firestore.
    try {
      await _firestore
          .collection("chat_rooms")
          .doc(chatroomId)
          .collection("messages")
          .add(newMessage.toMap());
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(
      String userID, String otherID) {
    List<String> ids = [userID, otherID];
    ids.sort();
    String chatroomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<List<String>> getChatRoomIDs() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('chat_rooms').get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }
}
