import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';
import 'package:funli_app/src/widgets/secondary_gradient_btn.dart';

import '../features/main_menu/profile/remote_user_profile_page.dart';
import '../models/follow_model.dart';
import '../models/user_model.dart';
import '../res/app_colors.dart';
import '../res/app_icons.dart';
import '../res/app_textstyles.dart';
import '../res/firebase_constants.dart';
import '../services/user_service.dart';
import 'loading_widget.dart';

class FollowingAndFollowersBottomSheet extends StatefulWidget {
  const FollowingAndFollowersBottomSheet({super.key, required this.isFollowing});
  final bool isFollowing;
  @override
  State<FollowingAndFollowersBottomSheet> createState() => _FollowingAndFollowersBottomSheetState();
}

class _FollowingAndFollowersBottomSheetState extends State<FollowingAndFollowersBottomSheet> {
  final List<UserModel> _followers = [];
  DocumentSnapshot? _lastFollowerDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final int _limit = 10;

  String currentUID = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    _loadFollowers();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300 &&
        !_isLoading &&
        _hasMore) {
      _loadFollowers();
    }
  }

  Future<void> _loadFollowers() async {
    _isLoading = true;
    late Query colRef;

    if(widget.isFollowing){
      colRef = FirebaseFirestore.instance
          .collection(FirebaseConstants.userCollection)
          .doc(currentUID)
          .collection(FirebaseConstants.followingCollection)
          .orderBy('dateTime', descending: true)
          .limit(_limit);
    }else{
      colRef = FirebaseFirestore.instance
          .collection(FirebaseConstants.userCollection)
          .doc(currentUID)
          .collection(FirebaseConstants.followersCollection)
          .orderBy('dateTime', descending: true)
          .limit(_limit);
    }


    QuerySnapshot snapshot = _lastFollowerDoc == null
        ? await colRef.get()
        : await colRef.startAfterDocument(_lastFollowerDoc!).get();

    debugPrint("Docs found: ${snapshot.docs.length}");
    if (snapshot.docs.isEmpty) {
      setState(() => _hasMore = false);
      _isLoading = false;
      return;
    }

    _lastFollowerDoc = snapshot.docs.last;

    List<FollowModel> followModels = snapshot.docs
        .map((doc) => FollowModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    final userIDs = followModels.map((f) => f.userID).toList();

    final userSnapshot = await FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .where('userID', whereIn: userIDs)
        .get();

    List<UserModel> users = userSnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();

    setState(() {
      _followers.addAll(users);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            spacing: 10,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Followers", style: AppTextStyles.headingTextStyle3,),
                    IconButton(
                        style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                            backgroundColor: AppColors.lightGreyColor
                        ),
                        onPressed: (){
                          Navigator.of(context).pop();
                        }, icon: Icon(Icons.close))
                  ],
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _followers.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _followers.length) {
                      final user = _followers[index];
                      return ListTile(
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=> RemoteUserProfilePage(userID: user.userID, userName: user.userName, profilePicture: user.profilePicture,)));
                        },
                        contentPadding: EdgeInsets.zero,
                        leading: ProfilePictureWidget(profilePicture: user.profilePicture),
                        title: Text(user.userName, style: AppTextStyles.buttonTextStyle,),
                        trailing: SizedBox(

                          width: 150,
                          child: StreamBuilder(stream: UserService.getIsFollowingStream(user.userID), builder: (ctx, snapshot){
                            if(snapshot.hasData){
                              return snapshot.requireData
                                  ? SecondaryGradientBtn(btnText: "Following", icon: '', onTap: (){}, buttonHeight: 38,)
                                  : SizedBox(
                                height: 38,
                                width: 75,
                                child: PrimaryBtn(btnText: "Follow", icon: '', onTap: (){}, bgGradient: AppIcons.primaryBgGradient,),
                              );
                            }else if(snapshot.connectionState == ConnectionState.waiting){
                              return LoadingWidget();
                            }

                            return LoadingWidget();
                          }),
                        ),
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}