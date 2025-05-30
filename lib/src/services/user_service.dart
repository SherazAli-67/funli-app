import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:funli_app/src/models/follow_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:funli_app/src/models/user_model.dart';
import 'package:funli_app/src/res/firebase_constants.dart';

class UserService {
  // final _auth = FirebaseAuth.instance;
  static final _fireStore = FirebaseFirestore.instance;

  static Future<UserModel?> getUserByID({required String userID})async{
    DocumentSnapshot docSnap = await _fireStore.collection(FirebaseConstants.userCollection).doc(userID).get();
    if(docSnap.exists){
      UserModel user = UserModel.fromMap(docSnap.data() as Map<String, dynamic>);
      return user;
    }

    return null;
  }

   static Future<bool> onFollowTap({required String remoteUID})async{
    bool result = false;
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    try{
      CollectionReference currentUserFollowingColRef = _fireStore.collection(
          FirebaseConstants.userCollection).doc(currentUID).collection(
          FirebaseConstants.followingCollection);

      CollectionReference remoteUserFollowerColRef = _fireStore.collection(
          FirebaseConstants.userCollection).doc(remoteUID).collection(
          FirebaseConstants.followersCollection);
      QuerySnapshot querySnapshot = await currentUserFollowingColRef.where('userID', isEqualTo: remoteUID).get();
      if(querySnapshot.size > 0){
        debugPrint("Found");
        await currentUserFollowingColRef.doc(remoteUID).delete();

        debugPrint("Removed from remote user");
        await remoteUserFollowerColRef.doc(currentUID).delete();
        //remove from following
        result = true;
      }else{
        //adding the remote user to the following list
        debugPrint("Not found");

        FollowModel remoteUserFollowingModel = FollowModel(userID: remoteUID, dateTime: DateTime.now());
        await currentUserFollowingColRef.doc(remoteUID).set(remoteUserFollowingModel.toMap());
        debugPrint("added to following list");

        //adding me to remote user followers list
        FollowModel currentUserFollowerModel = FollowModel(userID: currentUID, dateTime: DateTime.now());
        remoteUserFollowerColRef.doc(currentUID).set(currentUserFollowerModel.toMap());
        debugPrint("added to follower list");
        result = true;
      }
    }catch(e){
      debugPrint("Error while adding to followers list: ${e.toString()}");
    }


    return result;
  }

  static Stream<bool> getIsFollowing(String remoteUID) {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;

    return _fireStore.collection(
        FirebaseConstants.userCollection).doc(currentUID).collection(
        FirebaseConstants.followingCollection).doc(remoteUID).snapshots().map((snapshot)=> snapshot.exists);
  }

  static Stream<UserModel> getCurrentUserStream() {
    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    return _fireStore.collection(
        FirebaseConstants.userCollection).doc(currentUID).snapshots().map((snapshot)=> UserModel.fromMap(snapshot.data()!));
  }

  static Future<void> updateMoodTo(String mood)async {

    String currentUID = FirebaseAuth.instance.currentUser!.uid;
    await _fireStore.collection(
        FirebaseConstants.userCollection).doc(currentUID).update({
      'mood' : mood,
    });
  }

  static Future<int> getUserPostsCount({required String userID}) async{
    final countQuery = await FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(userID)
        .collection(FirebaseConstants.reelsCollection)
        .count()
        .get();

    final totalCount = countQuery.count ?? 0;
    return totalCount;
  }
  static Future<int> getUserFollowersCount({required String userID}) async{
    final countQuery = await FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(userID)
        .collection(FirebaseConstants.followersCollection)
        .count()
        .get();

    final totalCount = countQuery.count ?? 0;
    return totalCount;
  }
  static Future<int> getUserFollowingCount({required String userID}) async{
    final countQuery = await FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .doc(userID)
        .collection(FirebaseConstants.followingCollection)
        .count()
        .get();

    final totalCount = countQuery.count ?? 0;
    return totalCount;
  }
}
