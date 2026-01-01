import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookAppointmentScreen extends StatefulWidget {
  final String doctorUid;

  const BookAppointmentScreen({super.key, required this.doctorUid});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
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
          if (snapshot.connectionState == ConnectionState.waiting) {
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirm Appointment"),
                ),
              ),
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
      final firestore = FirebaseFirestore.instance;

      final availabilityRef = firestore
          .collection('availability')
          .doc(widget.doctorUid);

      final doctorQueueRef = firestore
          .collection('doctor_queue')
          .doc(widget.doctorUid);

      int queueNumber = await firestore.runTransaction((transaction) async {
        // 🔹 GET AVAILABILITY
        final availabilitySnap = await transaction.get(availabilityRef);

        if (!availabilitySnap.exists) {
          throw "Doctor availability not found";
        }

        List slots = List.from(availabilitySnap.get('slots') ?? []);

        if (!slots.contains(selectedSlot)) {
          throw "Selected slot already booked";
        }

        // 🔒 REMOVE BOOKED SLOT
        transaction.update(
          FirebaseFirestore.instance
              .collection('availability')
              .doc(widget.doctorUid),
          {
            'slots': FieldValue.arrayRemove([selectedSlot]),
          },
        );

        // 🔹 QUEUE LOGIC
        final queueSnap = await transaction.get(doctorQueueRef);
        int lastQueue = queueSnap.exists ? queueSnap.get('lastQueue') : 0;

        int newQueue = lastQueue + 1;

        transaction.set(doctorQueueRef, {
          'lastQueue': newQueue,
        }, SetOptions(merge: true));

        // 🔹 CREATE APPOINTMENT
        transaction.set(firestore.collection('appointments').doc(), {
          'doctorUid': widget.doctorUid,
          'patientUid': user.uid,
          'slot': selectedSlot,
          'queueNumber': newQueue,
          'status': 'waiting',
          'createdAt': FieldValue.serverTimestamp(),
        });

        return newQueue;
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Appointment Confirmed"),
          content: Text("Slot: $selectedSlot\nYour Queue Number: $queueNumber"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    } finally {
      setState(() => loading = false);
    }
  }
}
