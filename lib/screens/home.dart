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
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
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
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.account!.imageUrl!),
                ),
                SizedBox(width: 5),
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: Text(
                        'Welcome, ${widget.account.name?.isNotEmpty == true ? widget.account.name : 'User'}',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
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
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        showChildOpacityTransition: false,
        color: Color.fromARGB(255, 224, 191, 109),
        backgroundColor: Colors.white,
        animSpeedFactor: 2.0,
        height: 90,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),

          padding: EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    print('Error: ${snapshot.error}');
                    return Center(
                      child: Text("Error loading lawyers: ${snapshot.error}"),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text("No top-rated lawyers available"),
                    );
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

  Future<void> _handleRefresh() async {
    // Simulate network call
    await Future.delayed(Duration(milliseconds: 200));
    setState(() {});
  }
}
