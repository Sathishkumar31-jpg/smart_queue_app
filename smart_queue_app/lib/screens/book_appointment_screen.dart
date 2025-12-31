import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String doctorUid;

  const BookAppointmentScreen({super.key, required this.doctorUid});

  @override
  State<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState
    extends State<BookAppointmentScreen> {
  String? selectedSlot;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Book Appointment")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('availability')
            .doc(widget.doctorUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Doctor not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          /// ✅ VERY IMPORTANT SAFETY CHECK
          if (!data.containsKey('slots')) {
            return const Center(
              child: Text(
                "Doctor slots not configured",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          List slots = data['slots'];

          return Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Select Time Slot",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView.builder(
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    return RadioListTile(
                      title: Text(slots[index]),
                      value: slots[index],
                      groupValue: selectedSlot,
                      onChanged: (value) {
                        setState(() {
                          selectedSlot = value.toString();
                        });
                      },
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: selectedSlot == null || loading
                      ? null
                      : () => bookAppointment(context),
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white)
                      : const Text("Confirm Appointment"),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  /// 🔥 REAL QUEUE + APPOINTMENT LOGIC
  Future<void> bookAppointment(BuildContext context) async {
    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final doctorQueueRef = FirebaseFirestore.instance
          .collection('doctor_queue')
          .doc(widget.doctorUid);

      int queueNumber = await FirebaseFirestore.instance
          .runTransaction((transaction) async {
        final snapshot = await transaction.get(doctorQueueRef);

        int lastQueue = snapshot.exists
            ? snapshot.get('lastQueue')
            : 0;

        int newQueue = lastQueue + 1;

        transaction.set(doctorQueueRef, {
          'lastQueue': newQueue,
        }, SetOptions(merge: true));

        transaction.set(
          FirebaseFirestore.instance
              .collection('appointments')
              .doc(),
          {
            'doctorUid': widget.doctorUid,
            'patientUid': user.uid,
            'slot': selectedSlot,
            'queueNumber': newQueue,
            'status': 'waiting',
            'createdAt': FieldValue.serverTimestamp(),
          },
        );

        return newQueue;
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Appointment Confirmed"),
          content:
              Text("Your Queue Number is $queueNumber"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }
}
