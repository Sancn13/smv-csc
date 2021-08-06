import 'package:shared_preferences/shared_preferences.dart';

void setRecentSearch(search) async {
  if (search != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('recent_search_owner', search);
  }
}

Future<String> getRecentSearch() async {
  String _search = "";
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('recent_search_owner')) {
    _search = prefs.get('recent_search_owner').toString();
  }
  return _search;
}
