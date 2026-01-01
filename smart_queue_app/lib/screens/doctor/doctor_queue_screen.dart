// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class DoctorQueueScreen extends StatelessWidget {
//   const DoctorQueueScreen({super.key, required String doctorUid});

//   @override
//   Widget build(BuildContext context) {
//     final doctorUid = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(title: const Text("My Queue")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('appointments')
//             .where('doctorUid', isEqualTo: doctorUid)
//             .where('status', isEqualTo: 'waiting')
//             .orderBy('queueNumber')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No patients in queue"));
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.docs.length,
//             itemBuilder: (context, index) {
//               final doc = snapshot.data!.docs[index];
//               final data = doc.data() as Map<String, dynamic>;

//               return Card(
//                 margin: const EdgeInsets.all(10),
//                 child: ListTile(
//                   title: Text("Queue No: ${data['queueNumber']}"),
//                   subtitle: Text("Slot: ${data['slot']}"),
//                   trailing: ElevatedButton(
//                     child: const Text("Call"),
//                     onPressed: () async {
//                       await FirebaseFirestore.instance
//                           .collection('appointments')
//                           .doc(doc.id)
//                           .update({'status': 'consulting'});
//                     },
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class DoctorQueueScreen extends StatelessWidget {
//   final String doctorUid;

//   const DoctorQueueScreen({super.key, required this.doctorUid});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("My Queue")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('appointments')
//             .where('doctorUid', isEqualTo: doctorUid)
//             .orderBy('queueNumber')
//             .snapshots(),
//         builder: (context, snapshot) {

//           // 🔄 Loading
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           // ❌ Error
//           if (snapshot.hasError) {
//             return Center(
//               child: Text("Error: ${snapshot.error}"),
//             );
//           }

//           // ❌ Empty queue
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No patients in queue",
//                 style: TextStyle(fontSize: 16),
//               ),
//             );
//           }

//           final queueList = snapshot.data!.docs;

//           // ✅ Queue list
//           return ListView.builder(
//             itemCount: queueList.length,
//             itemBuilder: (context, index) {
//               final data =
//                   queueList[index].data() as Map<String, dynamic>;

//               return Card(
//                 margin:
//                     const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                 child: ListTile(
//                   leading: CircleAvatar(
//                     child: Text(
//                       data['queueNumber'].toString(),
//                     ),
//                   ),
//                   title: Text("Slot: ${data['slot']}"),
//                   subtitle: Text(
//                     "Status: ${data['status']}",
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorQueueScreen extends StatelessWidget {
  final String doctorUid;

  const DoctorQueueScreen({super.key, required this.doctorUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Patient Queue")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorUid', isEqualTo: doctorUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // 🔹 FILTER STATUS IN CODE
          final docs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] == 'waiting' ||
                data['status'] == 'consulting';
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text("Queue is empty"));
          }

          // 🔹 SORT BY QUEUE NUMBER IN CODE
          docs.sort((a, b) {
            final aQ = (a['queueNumber'] ?? 0) as int;
            final bQ = (b['queueNumber'] ?? 0) as int;
            return aQ.compareTo(bQ);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isCurrent = data['status'] == 'consulting';

              return Card(
                color: isCurrent ? Colors.blue.shade50 : null,
                child: ListTile(
                  title: Text(
                    "Queue #${data['queueNumber']}",
                    style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text("Slot: ${data['slot']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (data['status'] == 'waiting')
                        ElevatedButton(
                          child: const Text("Call"),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('appointments')
                                .doc(doc.id)
                                .update({'status': 'consulting'});
                          },
                        ),
                      if (isCurrent)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text("Complete"),
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('appointments')
                                .doc(doc.id)
                                .update({'status': 'completed'});
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
