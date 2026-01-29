import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _saveProfile(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'userName',
      user?.displayName ?? user?.email ?? 'User',
    );
    await prefs.setString('email', user?.email ?? '');
    await prefs.setString('profilePhoto', user?.photoURL ?? '');
  }

  // GOOGLE LOGIN
  Future<UserCredential?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);
    await _saveProfile(userCred.user);
    return userCred;
  }

  // EMAIL LOGIN
  Future<UserCredential?> signInWithEmail(
      String email, String password) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveProfile(userCred.user);
    return userCred;
  }

  // REGISTER
  Future<UserCredential?> registerWithEmail(
      String email, String password) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _saveProfile(userCred.user);
    return userCred;
  }

  // LOGOUT
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
