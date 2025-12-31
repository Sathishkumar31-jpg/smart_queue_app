// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class PatientQueueStatus extends StatelessWidget {
//   const PatientQueueStatus({super.key, required String doctorUid});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser!;

//     return Scaffold(
//       appBar: AppBar(title: const Text("My Queue Status")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('appointments')
//             .where('patientUid', isEqualTo: user.uid)
//             .where('status', whereIn: ['waiting', 'in_consultation'])
//             .orderBy('queueNumber')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No queue data available",
//                 style: TextStyle(fontSize: 16),
//               ),
//             );
//           }

//           final appointment =
//               snapshot.data!.docs.first.data() as Map<String, dynamic>;

//           final int myQueueNumber = appointment['queueNumber'];

//           return StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('appointments')
//                 .where('doctorUid',
//                     isEqualTo: appointment['doctorUid'])
//                 .where('status', whereIn: ['waiting', 'in_consultation'])
//                 .orderBy('queueNumber')
//                 .snapshots(),
//             builder: (context, queueSnapshot) {
//               if (!queueSnapshot.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               final queueDocs = queueSnapshot.data!.docs;

//               final currentToken = queueDocs.first
//                   .get('queueNumber');

//               final peopleAhead = myQueueNumber - currentToken;

//               return Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _statusCard(
//                       "Your Token Number",
//                       myQueueNumber.toString(),
//                       Colors.blue,
//                     ),
//                     const SizedBox(height: 20),
//                     _statusCard(
//                       "Now Serving",
//                       currentToken.toString(),
//                       Colors.green,
//                     ),
//                     const SizedBox(height: 20),
//                     _statusCard(
//                       "People Ahead of You",
//                       peopleAhead <= 0
//                           ? "It's your turn!"
//                           : peopleAhead.toString(),
//                       Colors.orange,
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _statusCard(String title, String value, Color color) {
//     return Card(
//       elevation: 5,
//       color: color.withOpacity(0.1),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Text(title,
//                 style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold)),
//             const SizedBox(height: 10),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }







import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientQueueStatus extends StatelessWidget {
  final String doctorUid;
  const PatientQueueStatus({super.key, required this.doctorUid});

  @override
  Widget build(BuildContext context) {
    final patientUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Queue Status")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorUid', isEqualTo: doctorUid)
            .where('patientUid', isEqualTo: patientUid)
            .where('status', isEqualTo: 'waiting')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No queue data available"),
            );
          }

          final data =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return Center(
            child: Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Your Queue Number",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      data['queueNumber'].toString(),
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Slot: ${data['slot']}"),
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



