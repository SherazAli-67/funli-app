class HashtagHelper {
  static List<String> extractHashtags(String text) {
    final RegExp hashtagRegExp = RegExp(r'\B#\w\w+');
    final matches = hashtagRegExp.allMatches(text);
    return matches.map((match) => match.group(0)!.substring(1).toLowerCase()).toList();
  }
}