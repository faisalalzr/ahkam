import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/widgets/reviewWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart'; // NEW

class LawyerDetailsScreen extends StatefulWidget {
  final Lawyer lawyer;
  final Account account;
  const LawyerDetailsScreen({
    super.key,
    required this.lawyer,
    required this.account,
  });

  @override
  State<LawyerDetailsScreen> createState() => _LawyerDetailsScreenState();
}

class _LawyerDetailsScreenState extends State<LawyerDetailsScreen> {
  final _titleCont = TextEditingController();
  final _descriptionCont = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  FirebaseFirestore fyre = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getinfo() async {
    try {
      var query =
          await fyre
              .collection('account')
              .where('email', isEqualTo: widget.lawyer!.email)
              .limit(1)
              .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first;
      }
    } catch (e) {
      print('Error fetching lawyer info: $e');
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _sendRequest() async {
    if (_selectedDate == null || _selectedTime == null) {
      Get.snackbar('Invalid input', 'Please select both a date and time.');
      return;
    }
    if (_titleCont.text.trim().isEmpty ||
        _descriptionCont.text.trim().isEmpty) {
      Get.snackbar('Missing Information', 'Please fill in all fields.');
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar('Error', 'You must be logged in to send a request.');
      return;
    }

    final userDoc = await fyre.collection('account').doc(currentUser.uid).get();
    final username = userDoc.data()?['name'] ?? 'Unknown';

    final request = {
      'rid': '${currentUser.uid}${widget.lawyer!.uid}',
      'userId': currentUser.uid,
      'lawyerId': widget.lawyer!.uid,
      'lawyerName': widget.lawyer!.name,
      'username': username,
      'title': _titleCont.text,
      'desc': _descriptionCont.text,
      'date': _selectedDate!.toIso8601String(),
      'time': _selectedTime!.format(context),
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
      'started?': false,
      'ended?': false,
      'fees': widget.lawyer!.fees!,
    };

    try {
      await fyre.collection('requests').add(request);
      Get.back();
      Get.snackbar('Success', 'Consultation request sent!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send request: $e');
    }
  }

  void _showRequestDialog() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Center(
              child: Text(
                'Book Consultation',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            content: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField('Title', _titleCont, icon: Icons.edit),
                  SizedBox(height: 16),
                  _buildTextField(
                    'Description',
                    _descriptionCont,
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    'Select Date',
                    _dateController,
                    icon: Icons.calendar_today,
                    onTap: () => _selectDate(context),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    'Select Time',
                    _timeController,
                    icon: Icons.access_time,
                    onTap: () => _selectTime(context),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.only(
              bottom: 12,
              right: 16,
              left: 16,
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              ),
              ElevatedButton(
                onPressed: _sendRequest,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    IconData? icon,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      maxLines: maxLines,
      style: GoogleFonts.lato(fontSize: 15),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon:
            icon != null ? Icon(icon, size: 20, color: Colors.grey[700]) : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.grey[100],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black, width: 1.2),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color ?? Colors.black87),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, size: 17),
        ),
        backgroundColor: Colors.white,
        title: Text('Lawyer Details', style: GoogleFonts.lato()),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getinfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center();
          if (!snapshot.hasData || snapshot.data == null) return Center();

          final data = snapshot.data!.data()!;
          final String fees = data['fees']?.toString() ?? '0';
          final String exp = data['exp']?.toString() ?? '0';
          final String prov = data['province']?.toString() ?? 'Unknown';

          return LiquidPullToRefresh(
            onRefresh: _handleRefresh,
            showChildOpacityTransition: false,
            color: Color.fromARGB(255, 224, 191, 109),
            backgroundColor: Colors.white,
            animSpeedFactor: 2.0,
            height: 90,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage:
                                    (data['imageUrl'] != null &&
                                            data['imageUrl'].isNotEmpty)
                                        ? NetworkImage(data['imageUrl'])
                                        : AssetImage('assets/images/brad.webp')
                                            as ImageProvider,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['name'],
                                      style: GoogleFonts.lato(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      data['specialization'] ?? 'Unknown',
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 13),
                          Divider(height: 24, thickness: 1.2),
                          _infoRow(
                            Icons.work_history,
                            'Years of Experience: $exp',
                          ),
                          _infoRow(Icons.location_city, 'Province: $prov'),
                          _infoRow(
                            Icons.monetization_on,
                            'Consultation Fee: \$$fees',
                            color: Colors.green,
                          ),
                          SizedBox(height: 16),
                          Text(
                            data['desc'] ?? 'No description available.',
                            style: GoogleFonts.lato(fontSize: 14, height: 1.5),
                          ),
                          SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _showRequestDialog,
                            icon: Icon(Icons.calendar_today),
                            label: Text('Request Consultation'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: GoogleFonts.lato(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Reviews',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  LawyerReviewsWidget(lawyerId: data['uid']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Simulate network call
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {});
  }
}
