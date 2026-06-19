class ActivityFilter {
  final Map<String, String>? query;
  final String label;
  ActivityFilter({required this.query, required this.label});

  static ActivityFilter get all => ActivityFilter(query: null, label: 'all');
  static ActivityFilter get weekly => ActivityFilter(query: {'weekly': 'weekly'}, label: 'weekly');
  static ActivityFilter get daily => ActivityFilter(query: { 'today': 'today'}, label: 'daily');
  static ActivityFilter get favouritedActivities => ActivityFilter(query: {'favourites': 'favourites'}, label: 'favourites');
  static ActivityFilter get monthly => ActivityFilter(query: {'monthly': 'month,year'}, label: 'monthly');
}