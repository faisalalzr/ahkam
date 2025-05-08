import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Lawsuit extends StatefulWidget {
  const Lawsuit({super.key, required this.rid});
  final String rid;

  @override
  State<Lawsuit> createState() => _LawsuitState();
}

class _LawsuitState extends State<Lawsuit> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? requestId;
  String? status; // Local status state

  Future<void> createPaymentForLawyer({
    required String lawyerId,
    required String clientId,
    required String requestId,
    required int fee,
  }) async {
    final paymentsRef = FirebaseFirestore.instance.collection('payments');

    await paymentsRef.add({
      'lawyerId': lawyerId,
      'clientId': clientId,
      'requestId': requestId,
      'fee': fee,
      'date': DateTime.now().toIso8601String(),
      'status':
          'completed', // You can change to 'pending' if you want manual approval
    });
  }

  @override
  void initState() {
    super.initState();
    //  status = widget.status; // Initialize local status
    fetchRequestId();
  }

  /// Fetch the Firestore document ID for this request
  Future<void> fetchRequestId() async {
    try {
      print("Fetching requestId for rid: ${widget.rid}");

      var querySnapshot =
          await _firestore
              .collection('requests')
              .where('rid', isEqualTo: widget.rid)
              .limit(1)
              .get();

      print("Query Result: ${querySnapshot.docs.length} documents found.");

      if (querySnapshot.docs.isNotEmpty) {
        requestId = querySnapshot.docs.first.id;
        print("Fetched requestId: $requestId");

        setState(() {}); // Update UI
      } else {
        print("No matching document found for rid: ${widget.rid}");
      }
    } catch (e) {
      print("Error fetching request: $e");
    }
  }

  /// Update request status in Firestore
  Future<void> updateRequestStatus(String newStatus) async {
    if (requestId == null) {
      print("Error: requestId is null. Cannot update status.");
      return;
    }

    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': newStatus,
      });

      if (mounted) {
        setState(() {
          status = newStatus;
        });
      }
    } catch (e) {
      print("Error updating Firestore: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update status: $e")));
    }
  }

  Future<List<Map<String, dynamic>>> fetchRequests() async {
    QuerySnapshot querySnapshot =
        await _firestore
            .collection('requests')
            .where('rid', isEqualTo: widget.rid)
            .get();

    return querySnapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>})
        .toList();
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMMMMd().format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String formatTimestamp(Timestamp ts) {
    try {
      final date = ts.toDate();
      return DateFormat.yMMMMd().add_jm().format(date);
    } catch (_) {
      return ts.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lawsuit Details')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No request found.'));
          }

          final request = snapshot.data![0];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                buildInfoCard("Title", request['title']),
                const SizedBox(height: 10),
                Text(
                  "Description",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    request['desc'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                buildInfoCard("fees", '${request['fees']}'),
                const SizedBox(height: 10),
                buildInfoCard("Client Name", request['username']),
                buildInfoCard("Date", formatDate(request['date'])),
                buildInfoCard("Time", request['time']),
                Text("Created At ${formatTimestamp(request['timestamp'])}"),
                const SizedBox(height: 20),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Accept logic here
                          updateRequestStatus('Accepted');
                          await createPaymentForLawyer(
                            lawyerId: request['lawyerId'],
                            clientId: request['userId'],
                            requestId: request['rid'],
                            fee: request['fees'], // example fee
                          );
                          Get.back();
                          Get.snackbar("case accepted", '');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 0, 116, 4),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Accept",
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (widget.rid != null) {
                            await _firestore
                                .collection('requests')
                                .doc(widget.rid)
                                .delete();
                          }
                          updateRequestStatus('Rejected');
                          Get.back();
                          Get.snackbar('Case dismissed', '');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            255,
                            17,
                            0,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "Reject",
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildInfoCard(String label, String value) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
