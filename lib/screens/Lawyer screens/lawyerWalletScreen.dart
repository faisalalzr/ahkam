import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerHomeScreen.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerMessages.dart';
import 'package:ahakam_v8/screens/Lawyer%20screens/morelawyer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:google_fonts/google_fonts.dart';

class LawyerWalletScreen extends StatefulWidget {
  final Lawyer lawyer;

  const LawyerWalletScreen({super.key, required this.lawyer});
  @override
  _LawyerWalletScreenState createState() => _LawyerWalletScreenState();
}

class _LawyerWalletScreenState extends State<LawyerWalletScreen> {
  int _currentIndex = 1;
  List<Map<String, dynamic>> payments = [];
  double totalEarnings = 0.0;
  Map<String, double> monthlyEarnings = {};

  @override
  void initState() {
    super.initState();
    loadPayments();
  }

  Future<void> loadPayments() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance
            .collection('payments')
            .where('lawyerId', isEqualTo: widget.lawyer.uid)
            .orderBy('date', descending: true)
            .get();

    List<Map<String, dynamic>> fetchedPayments =
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    double total = 0.0;
    Map<String, double> monthlyData = {};

    for (var payment in fetchedPayments) {
      double amount = (payment['fee'] ?? 0).toDouble();
      total += amount;

      DateTime date = DateTime.parse(payment['date']);
      String month = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      monthlyData[month] = (monthlyData[month] ?? 0) + amount;
    }

    setState(() {
      payments = fetchedPayments;
      totalEarnings = total;
      monthlyEarnings = monthlyData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Wallet',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: "Home"),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEarningsCard(),
            SizedBox(height: 24),
            _buildTransactionsList(),
            SizedBox(height: 24),
            _buildAnalyticsChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Center(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: const Color.fromARGB(255, 0, 33, 90),
        child: Padding(
          padding: EdgeInsets.only(top: 25, bottom: 25, right: 70, left: 70),
          child: Column(
            children: [
              Text(
                'Total Earnings',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                '\$${totalEarnings.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12),
        if (payments.isEmpty)
          Center(
            child: Text(
              'No transactions yet.',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
        ...payments.map((payment) {
          DateTime date = DateTime.parse(payment['date']);
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.attach_money, color: Colors.green),
              title: Text(
                'Consultation ',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '${date.day}/${date.month}/${date.year}',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              trailing: Text(
                '\$${payment['fee']}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAnalyticsChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16),
        Container(
          height: 250,
          child:
              monthlyEarnings.isEmpty
                  ? Center(
                    child: Text(
                      'No data yet.',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  )
                  : BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              List<String> months =
                                  monthlyEarnings.keys.toList();
                              if (value.toInt() < months.length) {
                                return Text(
                                  months[value.toInt()].split('-')[1],
                                  style: GoogleFonts.poppins(fontSize: 12),
                                );
                              }
                              return Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      barGroups:
                          monthlyEarnings.entries.toList().asMap().entries.map((
                            entry,
                          ) {
                            int idx = entry.key;
                            var e = entry.value;
                            return BarChartGroupData(
                              x: idx,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value,
                                  color: Colors.blueAccent,
                                  width: 20,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
        ),
      ],
    );
  }

  void onItemTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);

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
