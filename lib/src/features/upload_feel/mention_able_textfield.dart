import 'package:flutter/material.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:funli_app/src/res/app_colors.dart';

class MentionHashtagTextField extends StatefulWidget {
  @override
  _MentionHashtagTextFieldState createState() => _MentionHashtagTextFieldState();
}

class _MentionHashtagTextFieldState extends State<MentionHashtagTextField> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  String _trigger = '';
  List<String> _suggestions = [];
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final selection = _controller.selection;
    if (selection.baseOffset < 0) return;

    final textUntilCursor = text.substring(0, selection.baseOffset);
    final lastWord = textUntilCursor.split(RegExp(r'\s')).last;

    if (lastWord.startsWith('@')) {
      _trigger = '@';
      _fetchSuggestions(lastWord.substring(1), isMention: true);
    } else if (lastWord.startsWith('#')) {
      _trigger = '#';
      _fetchSuggestions(lastWord.substring(1), isMention: false);
    } else {
      _removeOverlay();
    }
  }

  void _fetchSuggestions(String keyword, {required bool isMention}) async {
    // Simulate API call
    await Future.delayed(Duration(milliseconds: 200));
    _suggestions = isMention
        ? ['@SherazAli', '@AreebaMalik', '@ZeeshanDev']
        : ['#FlutterDev', '#AIApps', '#PakTech'];

    _showOverlay();
  }

  void _showOverlay() {
    _overlayEntry?.remove();
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !_focusNode.hasFocus) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: renderBox.size.width,
        child: CompositedTransformFollower(
          offset: Offset(0, 40),
          link: _layerLink,
          showWhenUnlinked: false,
          child: Material(
            elevation: 4,
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: _suggestions.map((suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  onTap: () => _insertSuggestion(suggestion),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true)?.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _insertSuggestion(String suggestion) {
    final selection = _controller.selection;
    final textUntilCursor = _controller.text.substring(0, selection.baseOffset);
    final lastWordStart = textUntilCursor.lastIndexOf(_trigger);
    final newText =
    _controller.text.replaceRange(lastWordStart, selection.baseOffset, suggestion);

    _controller.value = TextEditingValue(
      text: '$newText ',
      selection: TextSelection.collapsed(offset: lastWordStart + suggestion.length + 1),
    );

    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: ExtendedTextField(
        controller: _controller,
        onTapOutside: (_)=> FocusManager.instance.primaryFocus?.unfocus(),
        focusNode: _focusNode,
        specialTextSpanBuilder: MentionHashtagSpanBuilder(),
        maxLines: null,
        decoration: InputDecoration(
          hintText: 'Type something with @ or #',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class MentionHashtagSpanBuilder extends SpecialTextSpanBuilder {
  @override
  SpecialText? createSpecialText(String flag,
      {TextStyle? textStyle, required int index, SpecialTextGestureTapCallback? onTap}) {
    if (isStart(flag, '@')) {
      return MentionText(textStyle!, onTap);
    } else if (isStart(flag, '#')) {
      return HashtagText(textStyle!, onTap);
    }
    return null;
  }

  bool isStart(String value, String prefix) {
    return value == prefix;
  }
}

class MentionText extends SpecialText {
  static const String flag = '@';

  MentionText(TextStyle textStyle, SpecialTextGestureTapCallback? onTap)
      : super(flag, ' ', textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    final mention = getContent();
    return SpecialTextSpan(
      text: '$flag$mention',
      actualText: '$flag$mention',
      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      deleteAll: true,
    );
  }
}

class HashtagText extends SpecialText {
  static const String flag = '#';

  HashtagText(TextStyle textStyle, SpecialTextGestureTapCallback? onTap)
      : super(flag, ' ', textStyle, onTap: onTap);

  @override
  InlineSpan finishText() {
    final hashtag = getContent();
    return SpecialTextSpan(
      text: '$flag$hashtag',
      actualText: '$flag$hashtag',
      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      deleteAll: true,
    );
  }
}