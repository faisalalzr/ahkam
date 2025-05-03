import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/widgets/reviewWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LawyerDetailsScreen extends StatefulWidget {
  final Lawyer? lawyer;
  final Account? account;
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
  final _typeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  FirebaseFirestore fyre = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getinfo() async {
    var query =
        await fyre
            .collection('account')
            .where('email', isEqualTo: widget.lawyer!.email)
            .limit(1)
            .get();
    return query.docs.first;
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
    Get.back();
    if (_selectedDate == null || _selectedTime == null) {
      Get.snackbar('Invalid input', 'Please select both a date and time.');
      return;
    }
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDoc =
        await fyre.collection('account').doc(currentUser!.uid).get();
    final username = userDoc.data()?['name'] ?? 'Unknown';

    if (currentUser == null) {
      Get.snackbar('Error', 'You must be logged in to send a request.');
      return;
    }

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
    };

    try {
      await fyre.collection('requests').add(request);
      Get.snackbar('Success', 'Consultation request sent!');
      Get.back();
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField('Title', _titleCont, icon: Icons.edit),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Description',
                      _descriptionCont,
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Select Date',
                      _dateController,
                      icon: Icons.calendar_today,
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Select Time',
                      _timeController,
                      icon: Icons.access_time,
                      onTap: () => _selectTime(context),
                    ),
                  ],
                ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 0.01),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.black87),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
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
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new, size: 17),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Text(
          'Lawyer Details',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: getinfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: Text('No data found'));

          final data = snapshot.data!.data()!;
          final String fees = data['fees']?.toString() ?? '0';
          final String exp = data['exp'].toString() ?? '0';
          final String prov = data['province'].toString() ?? '0';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          (data['imageUrl'] != null &&
                                  data['imageUrl'].isNotEmpty)
                              ? NetworkImage(data['imageUrl'])
                              : AssetImage('assets/images/brad.webp')
                                  as ImageProvider,
                    ),
                    SizedBox(height: 16),
                    Text(
                      data['name'],
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      data['specialization'] ?? 'Unknown',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    Divider(height: 32, thickness: 1.2),
                    _infoRow(
                      Icons.work_history,
                      'years of experince: ${exp}',
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    _infoRow(
                      Icons.location_city,
                      'province: ${prov}',
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    _infoRow(
                      Icons.monetization_on,
                      'Consultation Fee: \$${fees}',
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      data['desc'] ?? 'No description available.',
                      style: GoogleFonts.lato(fontSize: 16, height: 1.5),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showRequestDialog,
                      icon: Icon(Icons.calendar_today),
                      label: Text('Request Consultation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 255, 255),
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
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
                    LawyerReviewsWidget(lawyerId: data['uid']),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
