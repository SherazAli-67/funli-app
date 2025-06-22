import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:funli_app/src/features/main_menu/home_reels_page/comment_item_widget.dart';
import 'package:funli_app/src/models/comment_model.dart';
import 'package:funli_app/src/models/notification_model.dart';
import 'package:funli_app/src/models/reel_model.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_constants.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/services/comment_service.dart';
import 'package:funli_app/src/services/notifications_service.dart';
import 'package:funli_app/src/services/reels_service.dart';

class CommentsPage extends StatefulWidget{
  const CommentsPage(
      {super.key, required ReelModel reel, required bool comingFromHome})
      : _reel = reel,
        _comingFromHome = comingFromHome;
  final ReelModel _reel;
  final bool _comingFromHome;
  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  late final EmojiTextEditingController _commentController;
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;
  late final TextStyle _textStyle;
  final bool isApple = [TargetPlatform.iOS, TargetPlatform.macOS]
      .contains(foundation.defaultTargetPlatform);
  bool _isReplying = false;
  String? _replyingToUserName;
  String? _commentID;
  bool _emojiShowing = false;

  @override
  void initState() {
    final fontSize = 24 * (isApple ? 1.2 : 1.0);
    // Define Custom Emoji Font & Text Style
    _textStyle = DefaultEmojiTextStyle.copyWith(
      fontFamily: AppConstants.appFontFamily,
      fontSize: fontSize,
    );

    _commentController = EmojiTextEditingController(emojiTextStyle: _textStyle);
    _scrollController = ScrollController();
    _focusNode = FocusNode();
  super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(left: 23.0, right: 23, bottom: widget._comingFromHome ? 100 : 20, top: 20),
      child: Column(
        spacing: 14,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder(
                  stream: ReelsService.getReelCommentCount(reelID: widget._reel.reelID),
                  builder: (ctx, snapshot) {
                    if(snapshot.hasData && snapshot.requireData > 0){
                      return Text('Comments (${snapshot.requireData})', style: AppTextStyles.headingTextStyle3,);
                    }
                    return Text('Comments ', style: AppTextStyles.headingTextStyle3,);
                  }),
              IconButton(
                  style: IconButton.styleFrom(
                      backgroundColor: AppColors.lightGreyColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99))
                  ),
                  onPressed: ()=> Navigator.of(context).pop(), icon: Icon(Icons.close))
            ],
          ),

          StreamBuilder(stream: ReelsService.getReelsComment(reelID: widget._reel.reelID), builder: (ctx, snapshot){
            if(snapshot.hasData && snapshot.requireData.isNotEmpty){
              return Expanded(child: ListView.builder(
                  itemCount: snapshot.requireData.length,
                  itemBuilder: (ctx, index){
                    AddCommentModel comment = snapshot.requireData[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: CommentItemWidget(comment: comment, reelID:  widget._reel.reelID, onReplyTap:  _onReplyTap,)
                    );
                  }));
            }
            return Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                Text("No Comments Yet", style: AppTextStyles.headingTextStyle3,),
                Text("Be the first to comment on the reel", style: AppTextStyles.bodyTextStyle,),
              ],
            ));
          }),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start ,
            children: [
              if(_isReplying )
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Replying to $_replyingToUserName"),
                ),
              Container(
                height: 48.0,
                decoration: BoxDecoration(
                    color: AppColors.commentTextFieldFillColor,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.borderColor)
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(onPressed: (){
                            setState(() {
                              _emojiShowing = !_emojiShowing;
                              if (!_emojiShowing) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _focusNode.requestFocus();
                                });
                              } else {
                                _focusNode.unfocus();
                              }
                            });
                          }, icon: Icon(Icons.emoji_emotions_outlined)),
                          Expanded(child: TextField(
                            controller: _commentController,
                            focusNode: _focusNode,
                            scrollController: _scrollController,

                            onTap: (){
                              if(_emojiShowing){
                                _emojiShowing = false;
                                setState(() {});
                              }
                            },
                            onTapOutside: (val){
                              if(_emojiShowing){
                                _emojiShowing = false;
                                setState(() {});
                              }
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: "Say something nice...",
                                hintStyle: AppTextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.w400, color: AppColors.commentHintTextColor)
                            ),
                          ))
                        ],
                      ),
                    ),
                    IconButton(onPressed: _isReplying ? _addReply : _addComment, icon: SvgPicture.asset(AppIcons.icSendBtn))

                  ],
                ),
              ),
              Offstage(
                offstage: !_emojiShowing,
                child: EmojiPicker(
                  textEditingController: _commentController,
                  scrollController: _scrollController,

                  config: Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    emojiTextStyle: _textStyle,

                    viewOrderConfig: const ViewOrderConfig(),
                    emojiViewConfig: EmojiViewConfig(
                      horizontalSpacing: 10,
                      verticalSpacing: 10,

                    ),
                    skinToneConfig: const SkinToneConfig(),
                    categoryViewConfig: const CategoryViewConfig(),
                    bottomActionBarConfig: const BottomActionBarConfig(
                      backgroundColor: AppColors.purpleColor,
                      buttonColor: AppColors.purpleColor
                    ),
                    searchViewConfig: const SearchViewConfig(

                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _onReplyTap(String userName, String commentID){
    setState(()=>  _isReplying = true);
    _replyingToUserName = userName;
    _commentID = commentID;
    _focusNode.requestFocus();
  }

  Future<void> _addReply()async{
    String replyText = _commentController.text.trim();
    await CommentService.addReplyToComment(
        reelID: widget._reel.reelID,
        commentID: _commentID!,
        replyText: replyText);

    NotificationsService.sendNotificationToUser(
        receiverID: widget._reel.userID,
        reelID: widget._reel.reelID,
        description: "Wrote a reply on the feel" ,
        notificationType: NotificationType.reply);


    _reset();
  }

  Future<void> _addComment()async{
    String commentText = _commentController.text.trim();
    await CommentService.addCommentToReel(reelID: widget._reel.reelID, commentText: commentText);
    NotificationsService.sendNotificationToUser(
        receiverID: widget._reel.userID,
        reelID: widget._reel.reelID,
        description:  "Leave a comment on the feel",
        notificationType: NotificationType.comment);

    _reset();
  }

  void _reset() {
    _isReplying = false;
    _commentID = null;
    _replyingToUserName = null;
    _focusNode.unfocus();
    _commentController.clear();
    _emojiShowing = false;

    setState(() {});
  }
}

