// import 'package:flutter/material.dart';
// import 'doctorSet_availability_screen.dart';

// class DoctorHome extends StatelessWidget {
//   const DoctorHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Doctor Home")),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text("Set Availability"),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const DoctorAvailabilityScreen(doctorUid: "",),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'doctor_availability_screen.dart';

// class DoctorHome extends StatelessWidget {
//   const DoctorHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Doctor Home")),
//       body: Center(
//         child: ElevatedButton(
//           child: const Text("Set Availability"),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const DoctorAvailabilityScreen(),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_queue_app/screens/doctor/available_doctor_Screen.dart';

import 'doctorSet_availability_screen.dart';
import 'doctor_queue_screen.dart';

class DoctorHome extends StatelessWidget {
  const DoctorHome({super.key});

  @override
  Widget build(BuildContext context) {
    final String doctorUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Home")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Set Availability"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorAvailabilityScreen(
                      doctorUid: doctorUid,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              child: const Text("View Patient Queue"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorQueueScreen(
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
  }
}



