import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'social_text_editing_controller.dart';
import 'social_api_service.dart';

/// A Flutter widget that provides a text field with hashtag and mention functionality
class SocialTextField extends StatefulWidget {
  /// Initial text for the text field
  final String? initialText;
  
  /// Hint text to display when the field is empty
  final String? hintText;
  
  /// Maximum number of lines for the text field
  final int? maxLines;
  
  /// Minimum number of lines for the text field
  final int? minLines;
  
  /// Maximum length of the text field
  final int? maxLength;
  
  /// Whether to show a counter for the text length
  final bool showCounter;
  
  /// Text style for the input text
  final TextStyle? textStyle;
  
  /// Text style for hashtags
  final TextStyle? hashtagStyle;
  
  /// Text style for mentions
  final TextStyle? mentionStyle;
  
  /// Text style for the hint text
  final TextStyle? hintStyle;
  
  /// Decoration for the text field
  final InputDecoration? decoration;
  
  /// Focus node for the text field
  final FocusNode? focusNode;
  
  /// Maximum number of suggestions to show in the dropdown
  final int maxSuggestions;
  
  /// Debounce time for API calls in milliseconds
  final int debounceTimeMs;
  
  /// Callback when the text changes
  final ValueChanged<String>? onChanged;
  
  /// Callback when the text field is submitted
  final ValueChanged<String>? onSubmitted;
  
  /// API service for fetching suggestions
  final SocialApiService? apiService;
  
  /// Constructor
  const SocialTextField({
    Key? key,
    this.initialText,
    this.hintText,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.textStyle,
    this.hashtagStyle,
    this.mentionStyle,
    this.hintStyle,
    this.decoration,
    this.focusNode,
    this.maxSuggestions = 5,
    this.debounceTimeMs = 300,
    this.onChanged,
    this.onSubmitted,
    this.apiService,
  }) : super(key: key);
  
  @override
  _SocialTextFieldState createState() => _SocialTextFieldState();
}

class _SocialTextFieldState extends State<SocialTextField> {
  /// Controller for the text field
  late SocialTextEditingController _controller;
  
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
    
    // Initialize controller
    _controller = SocialTextEditingController(
      text: widget.initialText,
      onHashtagEntered: _onHashtagEntered,
      onMentionEntered: _onMentionEntered,
      hashtagStyle: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.purpleColor), mentionStyle: AppTextStyles.bodyTextStyle.copyWith(color: AppColors.purpleColor)
    );
    
    // Initialize focus node
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
    
    // Initialize API service
    _apiService = widget.apiService ?? SocialApiService();
  }
  
  @override
  void dispose() {
    // Clean up resources
    _hideOverlay();
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
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
    
    _debounceTimer = Timer(Duration(milliseconds: widget.debounceTimeMs), callback);
  }
  
  /// Fetch hashtag suggestions from API
  Future<void> _fetchHashtagSuggestions(String query) async {
    final suggestions = await _apiService.fetchTrendingHashtags(
      query,
      limit: widget.maxSuggestions,
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
      limit: widget.maxSuggestions,
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
          offset: Offset(0, 40), // Adjust based on your UI
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
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
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
            subtitle: Text('@${user.username}'),
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
          maxLength: widget.maxLength,
          buildCounter: widget.showCounter ? null : (_, {required currentLength, required isFocused, maxLength}) => null,
          decoration: widget.decoration ?? InputDecoration(
            hintText: widget.hintText ?? 'What\'s on your mind?',
            hintStyle: widget.hintStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.all(12),
          ),
          style: widget.textStyle,
          onChanged: (text) {
            if (widget.onChanged != null) {
              widget.onChanged!(text);
            }
          },
          onSubmitted: (text) {
            if (widget.onSubmitted != null) {
              widget.onSubmitted!(text);
            }
          },
        ),
      ),
    );
  }
}
