import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';

class Message {
  final String senderID;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String type;

  Message({
    required this.senderID,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.type = 'text',
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'type': type,
    };
  }
}

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

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
    String lawyerId,
  ) {
    return FirebaseFirestore.instance
        .collection('requests')
        .where('lawyerId', isEqualTo: lawyerId)
        .where('status', isEqualTo: 'Accepted')
        .snapshots()
        .asyncMap((snapshot) async {
          final List<Map<String, dynamic>> results = [];

          for (var doc in snapshot.docs) {
            final userId = doc['userId'];
            final userSnap =
                await FirebaseFirestore.instance
                    .collection('account')
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
    String senderId,
    String receiverId,
    String message, {
    String type = 'text',
  }) async {
    if (message.trim().isEmpty) return;

    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: senderId,
      receiverID: receiverId,
      message: message,
      timestamp: timestamp,
      type: type,
    );

    List<String> ids = [senderId, receiverId];
    ids.sort();
    String chatroomId = ids.join('_');

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
    String userID,
    String otherID,
  ) {
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

  Future<String?> uploadFile(File file) async {
    try {
      final supabase = Supabase.instance.client;
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final String filePath = 'chat/$fileName';

      final response = await supabase.storage
          .from('imagges') // your bucket name
          .upload(filePath, file);

      final publicUrl = supabase.storage.from('imagges').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Upload failed: $e');
      return null;
    }
  }
}
