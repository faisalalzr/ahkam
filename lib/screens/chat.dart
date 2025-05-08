import 'dart:io';
import 'package:ahakam_v8/services/chat_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Chat extends StatefulWidget {
  final String receiverID;
  final String receivername;
  final String rid;
  final String senderId;
  final String imageurl;

  const Chat({
    super.key,
    required this.receiverID,
    required this.receivername,
    required this.rid,
    required this.senderId,
    required this.imageurl,
  });

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxBool _isSending = false.obs;

  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty) return;
    _isSending.value = true;
    await _chatService.sendMessage(widget.senderId, widget.receiverID, message);
    _messageController.clear();
    _scrollToBottom();
    _isSending.value = false;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;

    final file = File(result.files.single.path!);
    final url = await _chatService.uploadFile(file);
    if (url != null) {
      await _chatService.sendMessage(
        widget.senderId,
        widget.receiverID,
        url,
        type:
            result.files.single.extension!.startsWith('jp') ||
                    result.files.single.extension!.startsWith('png')
                ? 'image'
                : 'file',
      );
    }
  }

  Widget _buildMessageItem(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final isMe = data['senderID'] == widget.senderId;
    final message = data['message'] ?? '';
    final type = data['type'] ?? '';
    final time = _formatTimestamp(data['timestamp']);

    final isImageMessage = type == 'image' || message.contains('supabase.co');

    Widget content;
    if (isImageMessage) {
      content = GestureDetector(
        onTap: () => _launchURL(message),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            message,
            width: 180,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (type == 'file') {
      content = GestureDetector(
        onTap: () => _launchURL(message),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, color: Colors.white),
            SizedBox(width: 6),
            Text("Document", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    } else {
      content = Text(
        message,
        style: TextStyle(color: isMe ? Colors.white : Colors.black),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            content,
            SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      Get.snackbar("Error", "Cannot open the link.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.imageurl)),
            SizedBox(width: 10),
            Text(widget.receivername),
          ],
        ),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatService.getMessages(
                widget.senderId,
                widget.receiverID,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder:
                      (context, index) => _buildMessageItem(docs[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.document_scanner),
                  onPressed: _pickAndSendFile,
                ),
                Obx(() {
                  return IconButton(
                    icon: Icon(Icons.send),
                    onPressed: _isSending.value ? null : _sendMessage,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
