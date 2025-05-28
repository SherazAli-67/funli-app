
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class AuthService {
  // Step 1: Private constructor
  AuthService._privateConstructor();

  // Step 2: Static instance
  static final AuthService _instance =
  AuthService._privateConstructor();

  // Step 3: Public getter to access the instance
  static AuthService get instance => _instance;

  final CollectionReference _userColRef = FirebaseFirestore.instance.collection(FirebaseConstants.userCollection);
  // FirebaseAuth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Example method: Sign in anonymously
  Future<UserCredential?> signupUsingEmail({required String userName, required String email, required String password}) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    if (userCredential.user != null) {
      Map<String, dynamic> userMap = {
        'userID': userCredential.user!.uid,
        'name': userName,
        'email': email
      };
      await _userColRef.doc(userCredential.user!.uid).set(userMap);
      return userCredential;
    }

    return null;
  }

  Future<void> updateUserInfo({required Map<String, dynamic> updatedMap})async{
    if(FirebaseAuth.instance.currentUser != null){
      String userID = FirebaseAuth.instance.currentUser!.uid;
      await _userColRef.doc(userID).update(updatedMap);
    }
  }

  Future<User?> signInWithEmail({required String email, required String password})async{
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    if(userCredential.user != null){
      return userCredential.user;
    }
    return null;
  }

  
}