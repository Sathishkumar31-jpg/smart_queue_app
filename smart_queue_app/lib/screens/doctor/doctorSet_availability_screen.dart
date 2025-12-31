// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class DoctorAvailabilityScreen extends StatefulWidget {
//   final String doctorUid;

//   const DoctorAvailabilityScreen({super.key, required this.doctorUid});

//   @override
//   State<DoctorAvailabilityScreen> createState() =>
//       _DoctorAvailabilityScreenState();
// }

// class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
//   List<String> slots = [];
//   final TextEditingController slotController = TextEditingController();

//   void saveAvailability() async {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     await FirebaseFirestore.instance
//         .collection('availability')
//         .doc(widget.doctorUid)
//         .set({
//           'date': DateTime.now().toString().substring(0, 10),
//           'slots': slots,
//         });

//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("Availability Saved")));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Set Availability")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: slotController,
//               decoration: const InputDecoration(
//                 labelText: "Add Slot (eg: 10:30)",
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   slots.add(slotController.text);
//                   slotController.clear();
//                 });
//               },
//               child: const Text("Add Slot"),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: slots.length,
//                 itemBuilder: (_, i) => ListTile(title: Text(slots[i])),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: saveAvailability,
//               child: const Text("Save Availability"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  final String doctorUid;

  const DoctorAvailabilityScreen({super.key, required this.doctorUid});

  @override
  State<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState
    extends State<DoctorAvailabilityScreen> {
  List<String> slots = [];
  final TextEditingController slotController = TextEditingController();

  Future<void> saveAvailability() async {
    await FirebaseFirestore.instance
        .collection('availability')
        .doc(widget.doctorUid)
        .set({
      'doctorUid': widget.doctorUid,
      'date': DateTime.now().toString().substring(0, 10),
      'slots': slots,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Availability Saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Availability")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: slotController,
              decoration: const InputDecoration(
                labelText: "Add Slot (eg: 10:30)",
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (slotController.text.isNotEmpty) {
                  setState(() {
                    slots.add(slotController.text);
                    slotController.clear();
                  });
                }
              },
              child: const Text("Add Slot"),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: slots.length,
                itemBuilder: (_, i) => ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(slots[i]),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: saveAvailability,
              child: const Text("Save Availability"),
            ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class DoctorQueueScreen extends StatelessWidget {
//   final String doctorUid;

//   const DoctorQueueScreen({super.key, required this.doctorUid});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Live Patient Queue")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('appointments')
//             .where('doctorUid', isEqualTo: doctorUid)
//             .where('status', whereIn: ['waiting', 'consulting'])
//             .orderBy('queueNumber')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("Queue is empty"));
//           }

//           return ListView(
//             padding: const EdgeInsets.all(10),
//             children: snapshot.data!.docs.map((doc) {
//               final data = doc.data() as Map<String, dynamic>;
//               final isCurrent = data['status'] == 'consulting';

//               return Card(
//                 color: isCurrent ? Colors.blue.shade50 : null,
//                 child: ListTile(
//                   title: Text(
//                     "Queue #${data['queueNumber']}",
//                     style: TextStyle(
//                       fontWeight:
//                           isCurrent ? FontWeight.bold : FontWeight.normal,
//                     ),
//                   ),
//                   subtitle: Text("Slot: ${data['slot']}"),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (data['status'] == 'waiting')
//                         ElevatedButton(
//                           child: const Text("Call"),
//                           onPressed: () async {
//                             await FirebaseFirestore.instance
//                                 .collection('appointments')
//                                 .doc(doc.id)
//                                 .update({'status': 'consulting'});
//                           },
//                         ),
//                       if (isCurrent)
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.green,
//                           ),
//                           child: const Text("Complete"),
//                           onPressed: () async {
//                             await FirebaseFirestore.instance
//                                 .collection('appointments')
//                                 .doc(doc.id)
//                                 .update({'status': 'completed'});
//                           },
//                         ),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }
// }
