import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final userModel = UserModel(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      role: 'customer',
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(uid).set(userModel.toMap());
    return userModel;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Creates an employee or rider account without signing out the current admin.
  // Uses a temporary secondary Firebase app instance.
  Future<void> createStaffAccount({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role, // 'employee' or 'rider'
  }) async {
    assert(role == 'employee' || role == 'rider');
    const secondaryAppName = '_staff_creator';
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: secondaryAppName,
        options: DefaultFirebaseOptions.currentPlatform,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await _db.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    } finally {
      await secondaryApp?.delete();
    }
  }
}
