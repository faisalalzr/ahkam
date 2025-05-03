import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawSuitDetails.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerprofile.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/morelawyer.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerWalletScreen.dart';
import 'package:ahakam_v8/screens/about.dart';
import 'package:ahakam_v8/screens/Lawyer screens/lawyerMessages.dart';
import 'package:ahakam_v8/screens/disclaimerPage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../widgets/lawsuitcard.dart';

class LawyerHomeScreen extends StatefulWidget {
  const LawyerHomeScreen({super.key, required this.lawyer});
  final Lawyer lawyer;

  @override
  State<LawyerHomeScreen> createState() => _LawyerHomeScreenState();
}

class _LawyerHomeScreenState extends State<LawyerHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var _selectedIndex = 3;

  Future<List<Map<String, dynamic>>> fetchThisLawyer() async {
    QuerySnapshot querySnapshot =
        await _firestore
            .collection('account')
            .where('email', isEqualTo: widget.lawyer.email)
            .limit(1)
            .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchRequests() async {
    QuerySnapshot querySnapshot =
        await _firestore
            .collection('requests')
            .where('lawyerId', isEqualTo: widget.lawyer.uid)
            .get();

    return querySnapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          drawer: Drawer(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DrawerHeader(
                  child: Column(
                    children: [
                      Image.asset(
                        height: 50,
                        width: 100,
                        "assets/images/ehkaam-seeklogo.png",
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.info_outline, color: Colors.black),
                  title: Text(
                    "Disclaimer",
                    style: GoogleFonts.lato(fontSize: 17, color: Colors.black),
                  ),
                  onTap: () => Get.to(DisclaimerPage()),
                ),
                ListTile(
                  leading: Icon(Icons.info, color: Colors.black),
                  title: Text(
                    "About",
                    style: GoogleFonts.lato(fontSize: 17, color: Colors.black),
                  ),
                  onTap: () => Get.to(AboutPage()),
                ),
                ListTile(
                  leading: Icon(Icons.person, color: Colors.black),
                  title: Text(
                    "Profile",
                    style: GoogleFonts.lato(fontSize: 17, color: Colors.black),
                  ),
                  onTap:
                      () => Get.to(
                        lawyerProfileScreen(lawyer: widget.lawyer),
                        transition: Transition.noTransition,
                      ),
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.black),
                  title: Text(
                    "Settings",
                    style: GoogleFonts.lato(fontSize: 17, color: Colors.black),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(width: 12),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchThisLawyer(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center();
                        } else {
                          final lawyerData = snapshot.data![0];
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundImage:
                                    (lawyerData['imageUrl'] != null &&
                                            lawyerData['imageUrl'].isNotEmpty)
                                        ? NetworkImage(lawyerData['imageUrl'])
                                        : AssetImage('assets/images/brad.webp')
                                            as ImageProvider,
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Welcome",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${lawyerData['name'] ?? ''}",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () {
                        Get.to(
                          DisclaimerPage(),
                          transition: Transition.rightToLeft,
                        );
                      },
                    ),
                    Stack(
                      children: [
                        Icon(Icons.notifications_none, size: 28),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 7,
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            centerTitle: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Case Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                      label: 'Finished',
                      color: Colors.green,
                      icon: LucideIcons.checkCircle,
                    ),
                    StatusBadge(
                      label: 'Waiting',
                      color: Colors.orange,
                      icon: LucideIcons.timer,
                    ),
                    StatusBadge(
                      label: 'Active',
                      color: Colors.blue,
                      icon: LucideIcons.briefcase,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Consultation Requests',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchRequests(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
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
                          return GestureDetector(
                            onTap: () {
                              Get.to(
                                Lawsuit(rid: request['rid']),
                                transition: Transition.downToUp,
                              );
                            },
                            child: LawsuitCard(
                              status: request['status'],
                              title: request['title'],
                              rid: request['rid'],
                              username: request['username'],
                              date: request['date'],
                              time: request['time'],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            items: [
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
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.home),
                label: "Home",
              ),
            ],
          ),
        ),
      ],
    );
  }

  void onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);

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
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
