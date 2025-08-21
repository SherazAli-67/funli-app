import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:funli_app/src/models/like_model.dart';
import 'package:funli_app/src/widgets/primary_btn.dart';
import 'package:funli_app/src/widgets/profile_picture_widget.dart';
import 'package:funli_app/src/widgets/secondary_gradient_btn.dart';
import 'package:go_router/go_router.dart';
import '../app_router/router_enum.dart';
import '../models/user_model.dart';
import '../res/app_colors.dart';
import '../res/app_icons.dart';
import '../res/app_textstyles.dart';
import '../res/firebase_constants.dart';
import '../services/user_service.dart';
import 'loading_widget.dart';

class ReelLikedUsersWidget extends StatefulWidget {
  const ReelLikedUsersWidget({super.key, required String reelID}): _reelID = reelID;
  final String _reelID;
  @override
  State<ReelLikedUsersWidget> createState() => _ReelLikedUsersWidgetState();
}

class _ReelLikedUsersWidgetState extends State<ReelLikedUsersWidget> {
  final List<UserModel> _likedUsers = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();
  final int _limit = 10;

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
    final Query colRef = FirebaseFirestore.instance
        .collection(FirebaseConstants.reelsCollection)
        .doc(widget._reelID)
        .collection(FirebaseConstants.likesCollection)
        .orderBy('dateTime', descending: true)
        .limit(_limit);

    QuerySnapshot snapshot = _lastDoc == null
        ? await colRef.get()
        : await colRef.startAfterDocument(_lastDoc!).get();

    if (snapshot.docs.isEmpty) {
      setState(() => _hasMore = false);
      _isLoading = false;
      return;
    }

    _lastDoc = snapshot.docs.last;

    List<LikeModel> followModels = snapshot.docs
        .map((doc) => LikeModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    final userIDs = followModels.map((like) => like.likedBy).toList();

    final userSnapshot = await FirebaseFirestore.instance
        .collection(FirebaseConstants.userCollection)
        .where('userID', whereIn: userIDs)
        .get();

    List<UserModel> users = userSnapshot.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();

    setState(() {
      _likedUsers.addAll(users);
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
                    Text("Likes", style: AppTextStyles.headingTextStyle3,),
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
                  itemCount: _likedUsers.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _likedUsers.length) {
                      final user = _likedUsers[index];
                      return ListTile(
                        onTap: (){
                          context.push(RouterEnum.remoteUserProfileView.routeName, extra: {
                            'userID' : user.userID,
                            'userName' : user.userName,
                            'profilePicture' : user.profilePicture
                          });

                        },
                        dense: true,
                        horizontalTitleGap: 0,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        leading: ProfilePictureWidget(profilePicture: user.profilePicture),
                        title: Text(user.userName, style: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w700),),
                        trailing: ConstrainedBox(constraints: BoxConstraints(maxWidth: 120, minWidth: 80), child: StreamBuilder(stream: UserService.getIsFollowingStream(user.userID), builder: (ctx, snapshot){
                          if(snapshot.hasData){
                            return snapshot.requireData
                                ? SecondaryGradientBtn(btnText: "Following", icon: '', onTap: (){}, buttonHeight: 38,)
                                : SizedBox(
                              height: 38,
                              width: 75,
                              child: PrimaryBtn(btnText: "Follow", icon: '', onTap: (){}, bgGradient: AppIcons.primaryBgGradient, textStyle: AppTextStyles.smallBoldTextStyle,),
                            );
                          }else if(snapshot.connectionState == ConnectionState.waiting){
                            return LoadingWidget();
                          }

                          return LoadingWidget();
                        }),),
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