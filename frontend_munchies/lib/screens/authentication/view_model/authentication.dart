import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend_munchies/models/user_profile.dart';
import 'package:frontend_munchies/services/auth/api_services.dart';
import 'package:frontend_munchies/services/auth/auth_exception.dart';
import 'package:frontend_munchies/services/auth/auth_services_repo.dart';

class Authentication {
  final FirebaseAuth firebaseAuth;
  final AuthServicesRepo apiServices;

  Authentication({required this.firebaseAuth, required this.apiServices});

  Authentication.real() 
  : firebaseAuth = FirebaseAuth.instance,
    apiServices = AuthServices();

  Future<UserProfile> login(String emailAddress, String password) async {
    try {
      final cred = await firebaseAuth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      final user = cred.user!;
      final String? idToken = await user.getIdToken();
      return apiServices.fetchProfileData(idToken!);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          throw AuthException('You have keyed in the wrong password');
        case 'invalid-email':
          throw AuthException(
            'Invalid email address. Please enter a valid email.',
          );
        case 'user-not-found':
          throw AuthException(
            'No users found with the given email address. Please sign up.',
          );
        case 'invalid-credential':
          throw AuthException('Wrong email or password. Please try again');
        default:
          throw Exception("Unexpected Error");
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> register(
    String emailAddress,
    String password,
    String firstName,
    String lastName,
  ) async {
    User? user;
    try {
      final cred = await firebaseAuth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      user = cred.user!;
      final String? idToken = await user.getIdToken();
      await apiServices.createProfile(
        idToken!,
        UserProfile(
          firebase_uid: user.uid,
          emailAddress: emailAddress,
          password: password,
          firstName: firstName,
          lastName: lastName,
        ),
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw AuthException('Email address already in use.');
        case 'invalid-email':
          throw AuthException(
            'Email Address is invalid. Please key in a valid email address.',
          );
        case 'weak-password':
          throw AuthException(
            'Password is too weak. Please fulfill password requirements.',
          );
      }
    } catch (e) {
      //if registering fails on backend, cannot create on firebase side either -> delete it 
      // print('outside here');
      if (user != null) {
        try {
          // print('preparing to delete');
          await user.delete();
        } catch (e) {
          // print('Critical error: Failed to delete Firebase user during rollback: $e');
          rethrow;
        }
      }
      rethrow;
    }
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> sendPasswordLink(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseException {
      rethrow;
    }
  }
}
