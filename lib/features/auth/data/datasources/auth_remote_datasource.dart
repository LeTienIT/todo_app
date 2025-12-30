import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../core/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';

class AuthenticationRemoteDataSource {
  final auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthenticationRemoteDataSource({
    required this.firebaseAuth,
    required this.firestore,
  });

  Future<User> login(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw ServerException();

      final doc = await firestore.collection('users').doc(user.uid).get();
      return User(
        id: user.uid,
        email: user.email ?? '',
        displayName: doc.data()?['displayName'],
        createdAt: doc.data()?['createdAt']?.toDate(),
      );
    } on auth.FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Login failed');
    }
  }

  Future<User> register(String email, String fullName, String password) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw ServerException();

      await firestore.collection('users').doc(user.uid).set({
        'email': email,
        'displayName': fullName,  // Default name từ email
        'createdAt': FieldValue.serverTimestamp(),
      });

      return User(
        id: user.uid,
        email: email,
        displayName: fullName ,
        createdAt: DateTime.now(),
      );
    } on auth.FirebaseAuthException catch (e) {
      throw ServerException(message: e.message ?? 'Registration failed');
    }
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  Future<User?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    final doc = await firestore.collection('users').doc(user.uid).get();
    return User(
      id: user.uid,
      email: user.email ?? '',
      displayName: doc.data()?['displayName'],
      createdAt: doc.data()?['createdAt']?.toDate(),
    );
  }

  Stream<User?> authStateChanges() {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      final doc = await firestore.collection('users').doc(firebaseUser.uid).get();
      return User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: doc.data()?['displayName'],
        createdAt: doc.data()?['createdAt']?.toDate(),
      );
    });
  }
}