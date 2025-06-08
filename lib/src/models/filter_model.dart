enum Mood { happy, sad, angry, anxious, curious }
enum Popularity { topFeels, newestFeels, mostViewed }

class ReelFilter {
  Mood? selectedMood;
  Popularity? selectedPopularity;
  String? location;
  String? language;

  ReelFilter({this.selectedMood, this.selectedPopularity, this.location, this.language});
}