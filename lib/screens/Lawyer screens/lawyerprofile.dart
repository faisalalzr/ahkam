import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/screens/home.dart';
import 'package:ahakam_v8/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class lawyerProfileScreen extends StatefulWidget {
  final Lawyer lawyer;

  const lawyerProfileScreen({super.key, required this.lawyer});

  @override
  State<lawyerProfileScreen> createState() => _lawyerProfileScreenState();
}

class _lawyerProfileScreenState extends State<lawyerProfileScreen> {
  FirebaseFirestore fyre = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getInfo() async {
    try {
      var querySnapshot =
          await fyre
              .collection('account')
              .where('email', isEqualTo: widget.lawyer.email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first;
      }
      return null; // Return null if no document is found
    } catch (e) {
      print("Error fetching profile data: $e");
      return null;
    }
  }

  Future<void> updateInfo() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Text("Profile"),
        backgroundColor: Color(0xFFF5EEDC),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        future: getInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              snapshot.data == null ||
              !snapshot.data!.exists) {
            return Center(child: Text("Error loading profile data."));
          }

          var userData = snapshot.data!.data() ?? {};

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        (userData['imageUrl'] != null &&
                                userData['imageUrl'].isNotEmpty)
                            ? NetworkImage(userData['imageUrl'])
                            : AssetImage('assets/images/brad.webp')
                                as ImageProvider,
                    backgroundColor: Colors.grey[300],
                  ),

                  SizedBox(height: 20),

                  // User Name
                  Text(
                    userData['name'] ?? "No Name",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // User Email
                  Text(
                    userData['email'] ?? "No Email",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 30),

                  // User Details Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ListTile(
                            trailing: IconButton(
                              icon: Icon(Icons.edit, size: 25),
                              onPressed: () {},
                            ),
                            leading: Icon(Icons.phone, color: Colors.black),
                            title: Text("Phone Number"),
                            subtitle: Text(
                              userData['number'] ?? "Not provided",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(
                              Icons.calendar_today,
                              color: Colors.black,
                            ),
                            title: Text("Joined Date"),
                            subtitle: Text(
                              userData['joinedDate'] ?? "Unknown",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Get.off(LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Logout",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
