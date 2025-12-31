class UserModel {
  String uid;
  String email;
  String role; // 'patient', 'doctor', 'admin'

  UserModel({required this.uid, required this.email, required this.role});
}
