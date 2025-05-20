import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// API service for fetching hashtag and mention suggestions
class SocialApiService {
  // Base URL for API endpoints
  final String baseUrl;
  
  // HTTP client for making requests
  final http.Client _client;
  
  // Cache for recent API results
  final Map<String, dynamic> _cache = {};
  
  // Cache expiration time (5 minutes)
  final Duration _cacheExpiration = Duration(minutes: 5);
  
  // Constructor
  SocialApiService({
    this.baseUrl = 'https://api.example.com',
    http.Client? client,
  }) : _client = client ?? http.Client();
  
  /// Fetch trending hashtags based on query
  Future<List<HashtagSuggestion>> fetchTrendingHashtags(String query, {int limit = 5}) async {
    try {
      // Check cache first
      final cacheKey = 'hashtags_$query';
      if (_cache.containsKey(cacheKey)) {
        final cachedData = _cache[cacheKey];
        if (cachedData['expiry'].isAfter(DateTime.now())) {
          return cachedData['data'];
        } else {
          // Remove expired cache entry
          _cache.remove(cacheKey);
        }
      }
      
      // In a real implementation, this would make an actual API call
      // For now, use mock data
      final suggestions = await _mockFetchHashtags(query, limit);
      
      // Cache the results
      _cache[cacheKey] = {
        'data': suggestions,
        'expiry': DateTime.now().add(_cacheExpiration),
      };
      
      return suggestions;
    } catch (e) {
      print('Error fetching trending hashtags: $e');
      return [];
    }
  }
  
  /// Fetch user suggestions based on query
  Future<List<UserSuggestion>> fetchUserSuggestions(String query, {int limit = 5}) async {
    try {
      // Check cache first
      final cacheKey = 'users_$query';
      if (_cache.containsKey(cacheKey)) {
        final cachedData = _cache[cacheKey];
        if (cachedData['expiry'].isAfter(DateTime.now())) {
          return cachedData['data'];
        } else {
          // Remove expired cache entry
          _cache.remove(cacheKey);
        }
      }
      
      // In a real implementation, this would make an actual API call
      // For now, use mock data
      final suggestions = await _mockFetchUsers(query, limit);
      
      // Cache the results
      _cache[cacheKey] = {
        'data': suggestions,
        'expiry': DateTime.now().add(_cacheExpiration),
      };
      
      return suggestions;
    } catch (e) {
      print('Error fetching user suggestions: $e');
      return [];
    }
  }
  
  /// Mock API call for hashtag suggestions
  Future<List<HashtagSuggestion>> _mockFetchHashtags(String query, int limit) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200));
    
    // Mock trending hashtags
    final allHashtags = [
      HashtagSuggestion(tag: 'flutter', count: 12345),
      HashtagSuggestion(tag: 'dart', count: 9876),
      HashtagSuggestion(tag: 'mobile', count: 8765),
      HashtagSuggestion(tag: 'app', count: 7654),
      HashtagSuggestion(tag: 'developer', count: 6543),
      HashtagSuggestion(tag: 'code', count: 5432),
      HashtagSuggestion(tag: 'programming', count: 4321),
      HashtagSuggestion(tag: 'ui', count: 3210),
      HashtagSuggestion(tag: 'design', count: 2109),
      HashtagSuggestion(tag: 'tech', count: 1098),
      HashtagSuggestion(tag: 'flutterando', count: 987),
      HashtagSuggestion(tag: 'devmobile', count: 876),
      HashtagSuggestion(tag: 'aplicativo', count: 765),
      HashtagSuggestion(tag: 'bolhadev', count: 654),
      HashtagSuggestion(tag: 'dev', count: 543),
      HashtagSuggestion(tag: 'desenvolvedor', count: 432),
    ];
    
    // Filter hashtags based on query
    final filteredHashtags = query.isEmpty
        ? allHashtags
        : allHashtags.where((h) => h.tag.toLowerCase().contains(query.toLowerCase())).toList();
    
    // Return limited number of suggestions
    return filteredHashtags.take(limit).toList();
  }
  
  /// Mock API call for user suggestions
  Future<List<UserSuggestion>> _mockFetchUsers(String query, int limit) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 200));
    
    // Mock user data
    final allUsers = [
      UserSuggestion(
        id: 'user1',
        username: 'johndoe',
        displayName: 'John Doe',
        avatarUrl: 'https://via.placeholder.com/32',
        verified: true,
      ),
      UserSuggestion(
        id: 'user2',
        username: 'janedoe',
        displayName: 'Jane Doe',
        avatarUrl: 'https://via.placeholder.com/32',
        verified: false,
      ),
      UserSuggestion(
        id: 'user3',
        username: 'bobsmith',
        displayName: 'Bob Smith',
        avatarUrl: 'https://via.placeholder.com/32',
        verified: false,
      ),
      UserSuggestion(
        id: 'user4',
        username: 'alicejones',
        displayName: 'Alice Jones',
        avatarUrl: 'https://via.placeholder.com/32',
        verified: true,
      ),
      UserSuggestion(
        id: 'user5',
        username: 'mikebrown',
        displayName: 'Mike Brown',
        avatarUrl: 'https://via.placeholder.com/32',
        verified: false,
      ),
      UserSuggestion(
        id: 'user6',
        username: 'sarahlee',
        displayName: 'Sarah Lee',
        avatarUrl: 'https://via.placeholder.com/32',
        verified: true,
      ),
      UserSuggestion(
        id: 'user7',
        username: 'davidwilson',
        displayName: 'David Wilson',
        avatarUrl: 'https://via.placeholder.com/32',
        verified: false,
      ),
      UserSuggestion(
        id: 'user8',
        username: 'emilyclark',
        displayName: 'Emily Clark',
        avatarUrl: 'https://via.placeholder.com/32',
        verified: false,
      ),
      UserSuggestion(
        id: 'user9',
        username: 'bluesky',
        displayName: 'Bluesky',
        avatarUrl: 'https://via.placeholder.com/32',
        verified: true,
      ),
      UserSuggestion(
        id: 'user10',
        username: 'safety.bsky.app',
        displayName: 'Bluesky Safety',
        avatarUrl: 'https://via.placeholder.com/32',
        verified: true,
      ),
      UserSuggestion(
        id: 'user11',
        username: 'blueskydirectory.com',
        displayName: 'Bluesky Directory',
        avatarUrl: 'https://via.placeholder.com/32',
        verified: false,
      ),
    ];
    
    // Filter users based on query
    final filteredUsers = query.isEmpty
        ? allUsers
        : allUsers.where((u) =>
            u.username.toLowerCase().contains(query.toLowerCase()) ||
            u.displayName.toLowerCase().contains(query.toLowerCase())
          ).toList();
    
    // Return limited number of suggestions
    return filteredUsers.take(limit).toList();
  }
  
  /// Real API call for trending hashtags (example implementation)
  Future<List<HashtagSuggestion>> _fetchTrendingHashtags(String query, int limit) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/trending-hashtags?query=${Uri.encodeComponent(query)}&limit=$limit'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> hashtags = data['hashtags'];
        
        return hashtags.map((json) => HashtagSuggestion.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load hashtags: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching trending hashtags: $e');
      return [];
    }
  }
  
  /// Real API call for user suggestions (example implementation)
  Future<List<UserSuggestion>> _fetchUserSuggestions(String query, int limit) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/user-suggestions?query=${Uri.encodeComponent(query)}&limit=$limit'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> users = data['users'];
        
        return users.map((json) => UserSuggestion.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user suggestions: $e');
      return [];
    }
  }
  
  /// Dispose resources
  void dispose() {
    _client.close();
  }
}

/// Model class for hashtag suggestions
class HashtagSuggestion {
  final String tag;
  final int count;
  
  HashtagSuggestion({
    required this.tag,
    required this.count,
  });
  
  factory HashtagSuggestion.fromJson(Map<String, dynamic> json) {
    return HashtagSuggestion(
      tag: json['tag'],
      count: json['count'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'count': count,
    };
  }
}

/// Model class for user suggestions
class UserSuggestion {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final bool verified;
  
  UserSuggestion({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.verified,
  });
  
  factory UserSuggestion.fromJson(Map<String, dynamic> json) {
    return UserSuggestion(
      id: json['id'],
      username: json['username'],
      displayName: json['display_name'],
      avatarUrl: json['avatar_url'],
      verified: json['verified'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'verified': verified,
    };
  }
}
