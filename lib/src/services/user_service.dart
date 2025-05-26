import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class UserService {
  // final _auth = FirebaseAuth.instance;
  static final _fireStore = FirebaseFirestore.instance;

  static Future<UserModel?> getUserByID({required String userID})async{
    DocumentSnapshot docSnap = await _fireStore.collection(userCollection).doc(userID).get();
    if(docSnap.exists){
      UserModel user = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
      return user;
    }

    return null;
  }
}