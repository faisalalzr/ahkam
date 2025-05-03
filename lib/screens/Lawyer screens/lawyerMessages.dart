import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerHomeScreen.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/morelawyer.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerWalletScreen.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerchat.dart';

import 'package:ahakam_v8/services/auth_service.dart';
import 'package:ahakam_v8/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/lawsuitcard.dart';
import 'lawSuitDetails.dart';

class Lawyermessages extends StatefulWidget {
  const Lawyermessages({super.key, required this.lawyer});
  final Lawyer lawyer;

  @override
  State<Lawyermessages> createState() => _LawyermessagesScreenState();
}

class _LawyermessagesScreenState extends State<Lawyermessages> {
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int selectedIndex = 2; // Persistent state for bottom nav selection

  // Handles bottom navigation
  void onItemTapped(int index) {
    if (selectedIndex == index) return; // Prevent unnecessary rebuilds
    setState(() => selectedIndex = index);

    switch (index) {
      case 0:
        Get.off(
          () => Morelawyer(lawyer: widget.lawyer),
          transition: Transition.noTransition,
        );
        break;
      case 1:
        Get.off(
          () => LawyerWalletScreen(lawyer: widget.lawyer),
          transition: Transition.noTransition,
        );
        break;

      case 2:
        Get.off(
          Lawyermessages(lawyer: widget.lawyer),
          transition: Transition.noTransition,
        );
        break;
      case 3:
        Get.off(
          () => LawyerHomeScreen(lawyer: widget.lawyer),
          transition: Transition.noTransition,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        toolbarHeight: 40,
        title: Text(
          "Messages",
          style: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 20,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color.fromARGB(255, 255, 255, 255), // Purple color
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: const Color.fromARGB(255, 0, 0, 0)),
            onPressed: () {}, // Implement search functionality here
          ),
        ],
      ),
      body: _buildUserList(),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Bottom Navigation Bar styling
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.plusCircle),
          label: "more",
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.wallet),
          label: "Wallet",
        ),
        BottomNavigationBarItem(
          icon: Icon(LucideIcons.messageCircle),
          label: "Chat",
        ),
        BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: "Home"),
      ],
    );
  }

  Future<List<Map<String, dynamic>>> fetchACCRequests() async {
    QuerySnapshot querySnapshot =
        await _firestore
            .collection('requests')
            .where('lawyerId', isEqualTo: widget.lawyer.uid)
            .where('status', isEqualTo: "Accepted")
            .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  // User list stream
  Widget _buildUserList() {
    return Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchACCRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('');
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching requests'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No requests yet.'));
          }

          List<Map<String, dynamic>> requests = snapshot.data!;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return FutureBuilder<DocumentSnapshot>(
                future:
                    _firestore
                        .collection('account')
                        .doc(request['userId'])
                        .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile();
                  } else if (userSnapshot.hasError ||
                      !userSnapshot.hasData ||
                      !userSnapshot.data!.exists) {
                    return ListTile();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20,
                        ),
                        title: Text(
                          request["username"] ?? 'Unknown User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Tap to chat",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1E3A5F),
                          child:
                              request["pic"] ??
                              Text(
                                request["username"]
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                        onTap: () {
                          Get.to(
                            transition: Transition.rightToLeft,
                            () => Lawyerchat(
                              receivername: request['username'] ?? '',
                              senderId: request["lawyerId"] ?? '',
                              receiverID: request["userId"] ?? '',
                              rid: request['rid'] ?? '',
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // User list item widget
}
