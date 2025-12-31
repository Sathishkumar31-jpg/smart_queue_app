// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class PatientQueueStatus extends StatelessWidget {
//   final String doctorUid;

//   const PatientQueueStatus({super.key, required this.doctorUid});

//   @override
//   Widget build(BuildContext context) {
//     final String patientUid =
//         FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Queue Status"),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('appointments')
//             .where('doctorUid', isEqualTo: doctorUid)
//             .orderBy('queueNumber')
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState ==
//               ConnectionState.waiting) {
//             return const Center(
//                 child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//                 child: Text("No queue data available"));
//           }

//           final docs = snapshot.data!.docs;

//           QueryDocumentSnapshot? myAppointment;
//           int currentQueueNumber = -1;

//           for (var doc in docs) {
//             final data = doc.data() as Map<String, dynamic>;

//             if (data['status'] == 'in_consultation') {
//               currentQueueNumber = data['queueNumber'];
//             }

//             if (data['patientUid'] == patientUid &&
//                 data['status'] != 'completed') {
//               myAppointment = doc;
//             }
//           }

//           if (myAppointment == null) {
//             return const Center(
//               child: Text(
//                 "Your appointment is completed",
//                 style: TextStyle(fontSize: 18),
//               ),
//             );
//           }

//           final myData =
//               myAppointment.data() as Map<String, dynamic>;

//           final int myQueueNumber = myData['queueNumber'];

//           final int patientsBefore = currentQueueNumber == -1
//               ? myQueueNumber - 1
//               : myQueueNumber - currentQueueNumber - 1;

//           return Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),

//                 /// MY QUEUE NUMBER
//                 const Text(
//                   "Your Queue Number",
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 Center(
//                   child: CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.blue,
//                     child: Text(
//                       myQueueNumber.toString(),
//                       style: const TextStyle(
//                           fontSize: 30, color: Colors.white),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 30),

//                 /// CURRENT PATIENT
//                 const Text(
//                   "Current Patient Queue",
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   currentQueueNumber == -1
//                       ? "Consultation not started"
//                       : currentQueueNumber.toString(),
//                   style: const TextStyle(fontSize: 20),
//                 ),

//                 const SizedBox(height: 30),

//                 /// PATIENTS BEFORE
//                 const Text(
//                   "Patients Before You",
//                   style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   patientsBefore < 0
//                       ? "0"
//                       : patientsBefore.toString(),
//                   style: const TextStyle(fontSize: 20),
//                 ),

//                 const Spacer(),

//                 /// STATUS MESSAGE
//                 Center(
//                   child: Text(
//                     myData['status'] == 'in_consultation'
//                         ? "🟢 Please enter consultation room"
//                         : "⏳ Please wait for your turn",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: myData['status'] ==
//                               'in_consultation'
//                           ? Colors.green
//                           : Colors.orange,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 30),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class PatientQueueStatus extends StatelessWidget {
//   const PatientQueueStatus({super.key, required String doctorUid});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser!;
//     print("🔍 Patient UID: ${user.uid}");

//     return Scaffold(
//       appBar: AppBar(title: const Text("My Queue Status")),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('appointments')
//             .where('patientUid', isEqualTo: user.uid)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final activeAppointments = snapshot.data!.docs.where((doc) {
//             final status = doc['status'];
//             return status == 'waiting' ||
//                 status == 'in_consultation';
//           }).toList();

//           if (activeAppointments.isEmpty) {
//             return const Center(
//               child: Text("No queue data available"),
//             );
//           }

//           final appointment =
//               activeAppointments.first.data()
//                   as Map<String, dynamic>;

//           final myToken = appointment['queueNumber'];
//           final doctorUid = appointment['doctorUid'];

//           return StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('appointments')
//                 .where('doctorUid', isEqualTo: doctorUid)
//                 .snapshots(),
//             builder: (context, qSnap) {
//               if (!qSnap.hasData) {
//                 return const CircularProgressIndicator();
//               }

//               final queue = qSnap.data!.docs
//                   .where((d) =>
//                       d['status'] == 'waiting' ||
//                       d['status'] ==
//                           'in_consultation')
//                   .toList()
//                 ..sort((a, b) =>
//                     a['queueNumber']
//                         .compareTo(b['queueNumber']));

//               final currentToken =
//                   queue.first['queueNumber'];

//               final peopleAhead =
//                   myToken - currentToken;

//               return Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   mainAxisAlignment:
//                       MainAxisAlignment.center,
//                   children: [
//                     _card(
//                         "Your Token",
//                         myToken.toString(),
//                         Colors.blue),
//                     const SizedBox(height: 20),
//                     _card(
//                         "Now Serving",
//                         currentToken.toString(),
//                         Colors.green),
//                     const SizedBox(height: 20),
//                     _card(
//                       "People Ahead",
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

//   Widget _card(String title, String value, Color c) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(children: [
//           Text(title,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//           Text(value,
//               style: TextStyle(
//                   fontSize: 26,
//                   color: c,
//                   fontWeight: FontWeight.bold)),
//         ]),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientQueueStatusScreen extends StatelessWidget {
  const PatientQueueStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final patientId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("My Queue Status")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: patientId)
            .where('status', isEqualTo: 'waiting')
            .snapshots(), // 🔥 LIVE STREAM
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No queue data available"));
          }

          final appointment = snapshot.data!.docs.first;
          final data = appointment.data() as Map<String, dynamic>;

          return Center(
            child: Card(
              elevation: 5,
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Your Queue Number",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      data['queueNumber'].toString(),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
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




