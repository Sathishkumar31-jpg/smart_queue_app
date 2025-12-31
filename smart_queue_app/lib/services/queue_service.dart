import 'package:cloud_firestore/cloud_firestore.dart';

class QueueService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> bookAppointment({
    required String doctorId,
    required String patientId,
    required String slotTime,
  }) async {
    final doctorQueueRef =
        _firestore.collection('doctor_queue').doc(doctorId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(doctorQueueRef);

      int lastQueue = snapshot.get('lastQueue');
      int newQueue = lastQueue + 1;

      // Save appointment
      final appointmentRef =
          _firestore.collection('appointments').doc();

      transaction.set(appointmentRef, {
        'doctorId': doctorId,
        'patientId': patientId,
        'slotTime': slotTime,
        'queueNumber': newQueue,
        'status': 'waiting',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update doctor queue
      transaction.update(doctorQueueRef, {
        'lastQueue': newQueue,
      });

      return newQueue;
    });
  }
}

