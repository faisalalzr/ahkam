import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/screens/about.dart';
import 'package:ahakam_v8/screens/browse.dart';
import 'package:ahakam_v8/screens/messagesScreen.dart';
import 'package:ahakam_v8/screens/profile.dart';
import 'package:ahakam_v8/screens/request.dart';
import 'package:ahakam_v8/widgets/lawyer_card.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:get/get.dart';
import '../widgets/category.dart';
import 'disclaimerPage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.account});
  final Account account;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 3;
  TextEditingController searchController = TextEditingController();

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Get.to(
          BrowseScreen('', account: widget.account),
          transition: Transition.noTransition,
        );
        break;
      case 1:
        Get.to(
          MessagesScreen(account: widget.account),
          transition: Transition.noTransition,
        );
        break;
      case 2:
        Get.to(
          RequestsScreen(account: widget.account),
          transition: Transition.noTransition,
        );
        break;

      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              leading: Icon(
                Icons.info_outline,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              title: Text(
                "Disclaimer",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              onTap: () => Get.to(DisclaimerPage()),
            ),
            ListTile(
              leading: Icon(Icons.info, color: Color.fromARGB(255, 0, 0, 0)),
              title: Text(
                "About",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              onTap: () => Get.to(AboutPage()),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0)),
              title: Text(
                "Profile",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              onTap:
                  () => Get.to(
                    ProfileScreen(account: widget.account),
                    transition: Transition.noTransition,
                  ),
            ),
            ListTile(
              leading: Icon(
                Icons.settings,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              title: Text(
                "Settings",
                style: GoogleFonts.lato(
                  textStyle: TextStyle(
                    fontSize: 17,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${widget.account.name ?? 'user'}',
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 72, 47, 0),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Get.to(DisclaimerPage(), transition: Transition.rightToLeft);
            },
          ),
          Stack(
            children: [
              Icon(Icons.notifications_none, size: 28),
              Positioned(
                top: 0,
                right: 0,
                child: CircleAvatar(radius: 7, backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(
                      () => BrowseScreen('', account: widget.account),
                      transition: Transition.downToUp,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutQuart,
                    );
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 65,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(128, 255, 224, 147),
                            Color.fromARGB(121, 255, 214, 110),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [0.0, 0.8],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Browse Lawyers",
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              color: const Color.fromARGB(255, 0, 0, 0),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 17),
            Text(
              "Categories",
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 72, 47, 0),
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 175,
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.3,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryCard(
                    category: categories[index],
                    account: widget.account,
                  );
                },
              ),
            ),
            Text(
              "Top Lawyers",
              style: GoogleFonts.lato(
                textStyle: TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 72, 47, 0),
                ),
              ),
            ),
            SizedBox(height: 10),
            FutureBuilder<List<Lawyer>>(
              future: Lawyer.getTopLawyers(limit: 2),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  ); // Loading spinner
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading lawyers"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No top-rated lawyers available"));
                }

                List<Lawyer> topLawyers = snapshot.data!;
                return Column(
                  children:
                      topLawyers.map((lawyer) {
                        return LawyerCard(
                          lawyer: lawyer,
                          account: widget.account,
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 300,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color.fromARGB(255, 72, 47, 0),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(LucideIcons.search), label: ""),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.messageCircle),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.clipboardList),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: ""),
        ],
      ),
    );
  }
}
