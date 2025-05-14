import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/screens/home.dart';
import 'package:ahakam_v8/screens/messagesScreen.dart';
import 'package:ahakam_v8/screens/request.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ahakam_v8/models/lawyer.dart';
import 'package:get/get.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/LawyerCardBrowse.dart';

class BrowseScreen extends StatefulWidget {
  final String? search;
  final Account account;
  final String? category;

  const BrowseScreen(
    this.search, {
    super.key,
    required this.account,
    this.category,
  });

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.search ?? '';
    searchController.text = _searchQuery;
  }

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
      case 3:
        Get.to(
          HomeScreen(account: widget.account),
          transition: Transition.noTransition,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Query query = _firestore
        .collection('account')
        .where('isLawyer', isEqualTo: true);

    if (widget.category != null) {
      query = query.where('specialization', isEqualTo: widget.category);
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.category ?? "Browse Lawyers",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color.fromARGB(255, 72, 47, 0),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_alt, size: 22, color: Colors.black),
            onPressed: () {
              setState(() {
                _searchQuery = searchController.text;
              });
            },
          ),
        ],
      ),
      body: LiquidPullToRefresh(
        onRefresh: _handleRefresh,
        color: const Color.fromARGB(255, 224, 191, 109),
        backgroundColor: Colors.white,
        animSpeedFactor: 2.0,
        height: 90,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: TextField(
                controller: searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search for a lawyer...",
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 255, 247, 247),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final lawyers =
                      snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return data['name'].toString().toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        );
                      }).toList();

                  if (lawyers.isEmpty) {
                    return Center(
                      child: Text(
                        'No lawyers found.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: lawyers.length,
                    itemBuilder: (context, index) {
                      final lawyerData =
                          lawyers[index].data() as Map<String, dynamic>;

                      Lawyer lawyer = Lawyer(
                        uid: lawyers[index].id,
                        name: lawyerData['name'] ?? 'Unknown',
                        email: lawyerData['email'] ?? 'Unknown',
                        specialization:
                            lawyerData['specialization'] ?? 'Unknown',
                        rating: lawyerData['rating'] ?? 0.0,
                        province: lawyerData['province'] ?? 'Unknown',
                        number: lawyerData['number'] ?? 'N/A',
                        desc: lawyerData['desc'] ?? '',
                      );

                      return LawyerCardBrowse(
                        lawyer: lawyer,
                        account: widget.account,
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
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 20,
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
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {});
  }
}
