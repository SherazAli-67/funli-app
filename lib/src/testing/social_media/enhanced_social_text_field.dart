import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'social_api_service.dart';

/// A simplified enhanced social text field with hashtag and mention functionality
/// Only includes the required parameters specified by the user
class EnhancedSocialTextField extends StatefulWidget {
  /// Hint text to display when the field is empty
  final String hintText;

  /// Maximum number of lines for the text field
  final int maxLines;

  /// Minimum number of lines for the text field
  final int minLines;

  /// Text style for hashtags
  final TextStyle hashtagStyle;

  /// Text style for mentions
  final TextStyle mentionStyle;

  /// Callback when the text changes
  final ValueChanged<String> onChanged;

  /// Constructor with only the required parameters
  const EnhancedSocialTextField({
    Key? key,
    required this.hintText,
    required this.maxLines,
    required this.minLines,
    required this.hashtagStyle,
    required this.mentionStyle,
    required this.onChanged,
  }) : super(key: key);

  @override
  _EnhancedSocialTextFieldState createState() => _EnhancedSocialTextFieldState();
}

class _EnhancedSocialTextFieldState extends State<EnhancedSocialTextField> {
  /// Controller for the text field
  late _SocialTextEditingController _controller;

  /// Focus node for the text field
  late FocusNode _focusNode;

  /// API service for fetching suggestions
  late SocialApiService _apiService;

  /// Overlay entry for the suggestions dropdown
  OverlayEntry? _overlayEntry;

  /// Current hashtag suggestions
  List<HashtagSuggestion> _hashtagSuggestions = [];

  /// Current user suggestions
  List<UserSuggestion> _userSuggestions = [];

  /// Selected index in the suggestions list
  int _selectedIndex = -1;

  /// Debounce timer for API calls
  Timer? _debounceTimer;

  /// Global key for positioning the overlay
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();

    // Initialize controller with the required styles
    _controller = _SocialTextEditingController(
      onHashtagEntered: _onHashtagEntered,
      onMentionEntered: _onMentionEntered,
      hashtagStyle: widget.hashtagStyle,
      mentionStyle: widget.mentionStyle,
    );

    // Initialize focus node
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);

    // Initialize API service
    _apiService = SocialApiService();
  }

  @override
  void dispose() {
    // Clean up resources
    _hideOverlay();
    _controller.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Handle focus changes
  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _hideOverlay();
    }
  }

  /// Handle hashtag entered
  void _onHashtagEntered(String query) {
    _debounce(() {
      _fetchHashtagSuggestions(query);
    });
  }

  /// Handle mention entered
  void _onMentionEntered(String query) {
    _debounce(() {
      _fetchUserSuggestions(query);
    });
  }

  /// Debounce function to prevent excessive API calls
  void _debounce(VoidCallback callback) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(Duration(milliseconds: 300), callback);
  }

  /// Fetch hashtag suggestions from API
  Future<void> _fetchHashtagSuggestions(String query) async {
    final suggestions = await _apiService.fetchTrendingHashtags(
      query,
      limit: 5,
    );

    if (mounted) {
      setState(() {
        _hashtagSuggestions = suggestions;
        _userSuggestions = [];
        _selectedIndex = -1;
      });

      if (suggestions.isNotEmpty) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    }
  }

  /// Fetch user suggestions from API
  Future<void> _fetchUserSuggestions(String query) async {
    final suggestions = await _apiService.fetchUserSuggestions(
      query,
      limit: 5,
    );

    if (mounted) {
      setState(() {
        _userSuggestions = suggestions;
        _hashtagSuggestions = [];
        _selectedIndex = -1;
      });

      if (suggestions.isNotEmpty) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    }
  }

  /// Show the suggestions overlay
  void _showOverlay() {
    if (_overlayEntry != null) {
      _hideOverlay();
    }

    // Create the overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 40),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: _buildSuggestionsWidget(),
          ),
        ),
      ),
    );

    // Add the overlay to the overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Hide the suggestions overlay
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Build the suggestions widget
  Widget _buildSuggestionsWidget() {
    if (_hashtagSuggestions.isNotEmpty) {
      return _buildHashtagSuggestions();
    } else if (_userSuggestions.isNotEmpty) {
      return _buildUserSuggestions();
    } else {
      return SizedBox.shrink();
    }
  }

  /// Build hashtag suggestions list
  Widget _buildHashtagSuggestions() {
    return Container(
      constraints: BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _hashtagSuggestions.length,
        itemBuilder: (context, index) {
          final hashtag = _hashtagSuggestions[index];
          return ListTile(
            dense: true,
            title: Row(
              children: [
                Text(
                  '#${hashtag.tag}',
                  style: widget.hashtagStyle,
                ),
                SizedBox(width: 8),
                Text(
                  '${hashtag.count} posts',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            tileColor: _selectedIndex == index ? Colors.grey.withOpacity(0.2) : null,
            onTap: () => _selectHashtagSuggestion(index),
          );
        },
      ),
    );
  }

  /// Build user suggestions list
  Widget _buildUserSuggestions() {
    return Container(
      constraints: BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _userSuggestions.length,
        itemBuilder: (context, index) {
          final user = _userSuggestions[index];
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.avatarUrl),
              radius: 16,
            ),
            title: Row(
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (user.verified)
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.verified,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ),
              ],
            ),
            subtitle: Text(
              '@${user.username}',
              style: widget.mentionStyle,
            ),
            tileColor: _selectedIndex == index ? Colors.grey.withOpacity(0.2) : null,
            onTap: () => _selectUserSuggestion(index),
          );
        },
      ),
    );
  }

  /// Select a hashtag suggestion
  void _selectHashtagSuggestion(int index) {
    if (index >= 0 && index < _hashtagSuggestions.length) {
      final hashtag = _hashtagSuggestions[index];
      _controller.insertSuggestion('#${hashtag.tag} ');
      _hideOverlay();

      // Clear suggestions to prevent dropdown from reappearing
      setState(() {
        _hashtagSuggestions = [];
      });
    }
  }

  /// Select a user suggestion
  void _selectUserSuggestion(int index) {
    if (index >= 0 && index < _userSuggestions.length) {
      final user = _userSuggestions[index];
      _controller.insertSuggestion('@${user.username} ');
      _hideOverlay();

      // Clear suggestions to prevent dropdown from reappearing
      setState(() {
        _userSuggestions = [];
      });
    }
  }

  /// Handle key events for navigation
  bool _handleKeyEvent(RawKeyEvent event) {
    if (_overlayEntry == null) return false;

    if (event is RawKeyDownEvent) {
      final suggestions = _hashtagSuggestions.isNotEmpty
          ? _hashtagSuggestions
          : _userSuggestions;

      switch (event.logicalKey.keyLabel) {
        case 'Arrow Down':
          setState(() {
            _selectedIndex = (_selectedIndex + 1) % suggestions.length;
          });
          return true;

        case 'Arrow Up':
          setState(() {
            _selectedIndex = (_selectedIndex - 1 + suggestions.length) % suggestions.length;
          });
          return true;

        case 'Enter':
          if (_selectedIndex >= 0) {
            if (_hashtagSuggestions.isNotEmpty) {
              _selectHashtagSuggestion(_selectedIndex);
            } else {
              _selectUserSuggestion(_selectedIndex);
            }
            return true;
          }
          break;

        case 'Escape':
          _hideOverlay();
          return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _handleKeyEvent,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.all(12),
          ),
          onChanged: (text) {
            widget.onChanged(text);
            setState(() {}); // Refresh to update the styled text
          },
          buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
        ),
      ),
    );
  }
}

/// A custom text editing controller that detects hashtags and mentions
class _SocialTextEditingController extends TextEditingController {
  // Regular expressions for detecting hashtags and mentions
  final RegExp _hashtagRegExp = RegExp(r'#[a-zA-Z0-9_]+');
  final RegExp _mentionRegExp = RegExp(r'@[a-zA-Z0-9_]+');

  // Callback for when a hashtag is detected
  final Function(String)? onHashtagEntered;

  // Callback for when a mention is detected
  final Function(String)? onMentionEntered;

  // Current trigger character being typed (# or @ or null)
  String? _currentTrigger;

  // Current query after the trigger character
  String _currentQuery = '';

  // Position of the current trigger in the text
  int _triggerPosition = -1;

  // Flag to prevent dropdown from showing immediately after insertion
  bool _preventTrigger = false;

  // Last inserted suggestion to prevent re-triggering
  String _lastInsertedSuggestion = '';

  // Text styles for hashtags and mentions
  final TextStyle hashtagStyle;
  final TextStyle mentionStyle;

  // Constructor
  _SocialTextEditingController({
    String? text,
    this.onHashtagEntered,
    this.onMentionEntered,
    required this.hashtagStyle,
    required this.mentionStyle,
  }) : super(text: text) {
    addListener(_textEditingListener);
  }

  /// Get the current trigger character
  String? get currentTrigger => _currentTrigger;

  /// Get the current query after the trigger
  String get currentQuery => _currentQuery;

  /// Get the position of the current trigger
  int get triggerPosition => _triggerPosition;

  /// Listener for text changes
  void _textEditingListener() {
    // If we're in prevention mode, skip this update
    if (_preventTrigger) {
      return;
    }

    // Get the current text and selection
    final text = this.text;
    final selection = this.selection;

    // Only process if we have a valid cursor position
    if (selection.baseOffset > 0) {
      // Get the text before the cursor
      final textBeforeCursor = text.substring(0, selection.baseOffset);

      // Find the start of the current word
      final wordStartIndex = _findWordStart(textBeforeCursor);

      // Get the current word being typed
      final currentWord = wordStartIndex >= 0
          ? textBeforeCursor.substring(wordStartIndex)
          : '';

      // Only trigger if the current word starts with # or @
      if (currentWord.startsWith('#') || currentWord.startsWith('@')) {
        // Check for hashtag trigger
        final hashtagMatch = _findLastTrigger(textBeforeCursor, '#');

        // Check for mention trigger
        final mentionMatch = _findLastTrigger(textBeforeCursor, '@');

        // Determine which trigger is active (if any)
        if (hashtagMatch != null && (mentionMatch == null || hashtagMatch.start > mentionMatch.start)) {
          _setCurrentTrigger('#', hashtagMatch.start, hashtagMatch.query);
        } else if (mentionMatch != null) {
          _setCurrentTrigger('@', mentionMatch.start, mentionMatch.query);
        } else {
          _clearTrigger();
        }
      } else {
        // Current word doesn't start with # or @, so clear trigger
        _clearTrigger();
      }
    } else {
      _clearTrigger();
    }
  }

  /// Find the start index of the current word
  int _findWordStart(String text) {
    // Find the last space or start of string
    for (int i = text.length - 1; i >= 0; i--) {
      if (text[i] == ' ' || text[i] == '\n') {
        return i + 1;
      }
    }
    return 0;
  }

  /// Find the last occurrence of a trigger character in the text
  _TriggerMatch? _findLastTrigger(String text, String trigger) {
    // Regular expression to find the last trigger that's not part of a word
    final pattern = RegExp('(^|\\s)\\$trigger([a-zA-Z0-9_]*)\\b');

    // Find all matches
    final matches = pattern.allMatches(text);

    // Return the last match if any
    if (matches.isNotEmpty) {
      final match = matches.last;
      final start = match.start + match.group(1)!.length;
      final query = match.group(2) ?? '';

      // Check if this is part of a previously inserted suggestion
      final fullMatch = match.group(0)!.trim();
      if (_lastInsertedSuggestion.isNotEmpty &&
          _lastInsertedSuggestion.startsWith(fullMatch) &&
          (text.length <= start + fullMatch.length || text[start + fullMatch.length] == ' ')) {
        // This is part of a previously inserted suggestion, don't trigger
        return null;
      }

      return _TriggerMatch(start, query);
    }

    return null;
  }

  /// Set the current trigger state
  void _setCurrentTrigger(String trigger, int position, String query) {
    // Only notify if the trigger or query changed
    final triggerChanged = _currentTrigger != trigger || _triggerPosition != position;
    final queryChanged = _currentQuery != query;

    _currentTrigger = trigger;
    _triggerPosition = position;
    _currentQuery = query;

    // Notify listeners if needed
    if (triggerChanged || queryChanged) {
      if (trigger == '#' && onHashtagEntered != null) {
        onHashtagEntered!(query);
      } else if (trigger == '@' && onMentionEntered != null) {
        onMentionEntered!(query);
      }
    }
  }

  /// Clear the current trigger state
  void _clearTrigger() {
    if (_currentTrigger != null) {
      _currentTrigger = null;
      _triggerPosition = -1;
      _currentQuery = '';
    }
  }

  /// Insert a suggestion at the current trigger position
  void insertSuggestion(String suggestion) {
    if (_currentTrigger == null || _triggerPosition < 0) return;

    // Set the prevention flag to avoid immediate re-triggering
    _preventTrigger = true;

    // Store the suggestion to prevent re-triggering
    _lastInsertedSuggestion = suggestion.trim();

    // Calculate the range to replace
    final start = _triggerPosition;
    final end = _triggerPosition + _currentQuery.length + 1; // +1 for the trigger character

    // Create the new text
    final newText = text.replaceRange(start, end, suggestion);

    // Update the text and move cursor to the end of the inserted suggestion
    value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + suggestion.length),
    );

    // Clear the trigger state
    _clearTrigger();

    // Reset the prevention flag after a short delay
    // This allows the text to update without triggering a new dropdown
    Future.delayed(Duration(milliseconds: 100), () {
      _preventTrigger = false;
    });
  }

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final spans = <TextSpan>[];
    final text = this.text;

    // Combine hashtag and mention patterns
    final pattern = RegExp('$_hashtagRegExp|$_mentionRegExp');

    // Split the text by hashtags and mentions
    int lastIndex = 0;
    for (final match in pattern.allMatches(text)) {
      // Add text before the match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style,
        ));
      }

      // Add the match with appropriate styling
      final matchText = match.group(0)!;
      if (matchText.startsWith('#')) {
        spans.add(TextSpan(
          text: matchText,
          style: hashtagStyle,
        ));
      } else if (matchText.startsWith('@')) {
        spans.add(TextSpan(
          text: matchText,
          style: mentionStyle,
        ));
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: style,
      ));
    }

    return TextSpan(children: spans, style: style);
  }

  @override
  void dispose() {
    removeListener(_textEditingListener);
    super.dispose();
  }
}

/// Helper class for trigger matches
class _TriggerMatch {
  final int start;
  final String query;

  _TriggerMatch(this.start, this.query);
}
