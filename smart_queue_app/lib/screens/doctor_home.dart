// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class DoctorHome extends StatelessWidget {
//   final String doctorUid = "HGfWICZX7HSDtYUWvf6BFC56I143";

//   DoctorHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Doctor Queue")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('appointments')
//             .where('doctorUid', isEqualTo: doctorUid)
//             .where('status', whereIn: ['waiting', 'in_consultation'])
//             .orderBy('queueNumber')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No patients in queue"));
//           }

//           final patients = snapshot.data!.docs;

//           return Column(
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: patients.length,
//                   itemBuilder: (context, index) {
//                     final data =
//                         patients[index].data() as Map<String, dynamic>;
//                     final isCurrent =
//                         data['status'] == 'in_consultation';

//                     return Card(
//                       color: isCurrent
//                           ? Colors.green.shade100
//                           : Colors.white,
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           child: Text(data['queueNumber'].toString()),
//                         ),
//                         title: Text("Slot: ${data['slot']}"),
//                         subtitle: Text("Status: ${data['status']}"),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: ElevatedButton(
//                   onPressed: () => nextPatient(context, patients),
//                   child: const Text("Next Patient"),
//                 ),
//               )
//             ],
//           );
//         },
//       ),
//     );
//   }

//   /// 🔥 SMART QUEUE SHIFT LOGIC
//   Future<void> nextPatient(
//       BuildContext context, List<QueryDocumentSnapshot> patients) async {
//     final firestore = FirebaseFirestore.instance;

//     WriteBatch batch = firestore.batch();

//     for (var doc in patients) {
//       final data = doc.data() as Map<String, dynamic>;

//       if (data['status'] == 'in_consultation') {
//         batch.update(doc.reference, {'status': 'completed'});
//         break;
//       }
//     }

//     for (var doc in patients) {
//       final data = doc.data() as Map<String, dynamic>;

//       if (data['status'] == 'waiting') {
//         batch.update(doc.reference, {'status': 'in_consultation'});
//         break;
//       }
//     }

//     await batch.commit();
//   }
// }




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorHome extends StatelessWidget {
  final String doctorUid = "HGfWICZX7HSDtYUWvf6BFC56I143";

  DoctorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Queue")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorUid', isEqualTo: doctorUid)
            .orderBy('queueNumber')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No patients in queue"));
          }

          final patients = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final data =
                        patients[index].data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'waiting';
                    final isCurrent = status == 'in_consultation';

                    return Card(
                      color: isCurrent ? Colors.green.shade100 : Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(data['queueNumber']?.toString() ?? "-"),
                        ),
                        title: Text("Slot: ${data['slot'] ?? '-'}"),
                        subtitle: Text("Status: $status"),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => nextPatient(patients),
                  child: const Text("Next Patient"),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  /// 🔥 Smart Queue shift logic (fixed)
  Future<void> nextPatient(List<QueryDocumentSnapshot> patients) async {
    final firestore = FirebaseFirestore.instance;
    WriteBatch batch = firestore.batch();

    // Complete current
    for (var doc in patients) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] == 'in_consultation') {
        batch.update(doc.reference, {'status': 'completed'});
        break;
      }
    }

    // Move next waiting -> in_consultation
    for (var doc in patients) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] == 'waiting') {
        batch.update(doc.reference, {'status': 'in_consultation'});
        break;
      }
    }

    await batch.commit();
  }
}
