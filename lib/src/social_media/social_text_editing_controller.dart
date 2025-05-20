import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom text editing controller that detects hashtags and mentions
class SocialTextEditingController extends TextEditingController {
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
  SocialTextEditingController({
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
