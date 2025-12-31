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
            .orderBy('queueNumber')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No queue data"));
          }

          final docs = snapshot.data!.docs;

          QueryDocumentSnapshot? myDoc;
          int currentQueue = -1;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['status'] == 'in_consultation') {
              currentQueue = data['queueNumber'];
            }
            if (data['patientUid'] == patientUid &&
                data['status'] != 'completed') {
              myDoc = doc;
            }
          }

          if (myDoc == null) {
            return const Center(
              child: Text("Your appointment is completed"),
            );
          }

          final myData = myDoc.data() as Map<String, dynamic>;
          final myQueue = myData['queueNumber'];
          final peopleBefore = currentQueue == -1
              ? myQueue - 1
              : myQueue - currentQueue - 1;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Your Queue Number",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue,
                    child: Text(
                      myQueue.toString(),
                      style: const TextStyle(
                          fontSize: 30, color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Current Patient Queue",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  currentQueue == -1
                      ? "Not started yet"
                      : currentQueue.toString(),
                  style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 30),

                Text(
                  "Patients Before You",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  peopleBefore < 0 ? "0" : peopleBefore.toString(),
                  style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 40),

                Center(
                  child: Text(
                    myData['status'] == 'in_consultation'
                        ? "🟢 Please enter consultation room"
                        : "⏳ Please wait",
                    style: TextStyle(
                      fontSize: 18,
                      color: myData['status'] == 'in_consultation'
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
