// import 'package:flutter/material.dart';
// import 'book_appointment_screen.dart';

// class PatientHome extends StatelessWidget {
//   const PatientHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Patient Home")),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text("Book Appointment"),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const BookAppointmentScreen(
//                   doctorUid: "HGfWICZX7HSDtYUWvf6BFC56I143",
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'book_appointment_screen.dart';

// class PatientHome extends StatelessWidget {
//   const PatientHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Patient Home")),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text("view book appoinment "),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const BookAppointmentScreen(
//                   doctorUid: "HGfWICZX7HSDtYUWvf6BFC56I143",
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:smart_queue_app/screens/patient_queue_status_screen.dart';
// import 'book_appointment_screen.dart';
// import 'patient_queue_status.dart' hide PatientQueueStatus;

// class PatientHome extends StatelessWidget {
//   const PatientHome({super.key});

//   static const String doctorUid = "HGfWICZX7HSDtYUWvf6BFC56I143";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Patient Home")),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // 🔹 BOOK APPOINTMENT
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text("Book Appointment"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) =>
//                         const BookAppointmentScreen(doctorUid: doctorUid),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 20),

//             // 🔹 VIEW QUEUE STATUS
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 50),
//                 backgroundColor: Colors.green,
//               ),
//               child: const Text("View My Queue Status"),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => const PatientQueueStatus(
//                       doctorUid: "HGfWICZX7HSDtYUWvf6BFC56I143",
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_queue_app/screens/doctor/available_doctor_Screen.dart';
import 'package:smart_queue_app/screens/patient/patient_queue_status_screen.dart';
// import 'package:smart_queue_app/screens/doctor/doctorSet_availability_screen.dart';
// import 'package:smart_queue_app/screens/doctor/doctor_availability_screen.dart';
// import 'book_appointment_screen.dart';
import 'patient_queue_status.dart' hide PatientQueueStatus;

class PatientHome extends StatelessWidget {
  const PatientHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Patient Home")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('availability')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No doctors available right now"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doctorUid = snapshot.data!.docs[index].id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(doctorUid)
                    .get(),
                builder: (context, doctorSnap) {
                  if (!doctorSnap.hasData) return const SizedBox();

                  final doctor =
                      doctorSnap.data!.data() as Map<String, dynamic>?;

                  if (doctor == null) return const SizedBox();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor['name'] ?? 'Doctor',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            doctor['specialization'] ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 15),

                          // 🔹 BOOK APPOINTMENT
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  const Size(double.infinity, 45),
                            ),
                            child: const Text("Book Appointment"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AvailableDoctorsScreen(
                                    doctorUid: doctorUid,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 10),

                          // 🔹 VIEW QUEUE STATUS
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize:
                                  const Size(double.infinity, 45),
                              backgroundColor: Colors.green,
                            ),
                            child: const Text("View My Queue Status"),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientQueueStatus(
                                    doctorUid: doctorUid,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
