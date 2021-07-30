import 'package:global_configuration/global_configuration.dart';

class Media {
  String id;
  String name;
  String url;
  String thumb;
  String icon;
  String size;

  Media() {
    url = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQwTqn1ODDo1F9mufocVIyn3DNn-omZzTMkohqz-0L2nPL9OvBv8mmjVMPPxoorC40SDgA&usqp=CAU";
    thumb = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQwTqn1ODDo1F9mufocVIyn3DNn-omZzTMkohqz-0L2nPL9OvBv8mmjVMPPxoorC40SDgA&usqp=CAU";
    icon = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQwTqn1ODDo1F9mufocVIyn3DNn-omZzTMkohqz-0L2nPL9OvBv8mmjVMPPxoorC40SDgA&usqp=CAU";
  }

  Media.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      url = jsonMap['url'];
      thumb = jsonMap['thumb'];
      icon = jsonMap['icon'];
      size = jsonMap['formated_size'];
    } catch (e) {
      url = "https://image.flaticon.com/icons/png/512/1548/1548682.png";
      thumb = "https://image.flaticon.com/icons/png/512/1548/1548682.png";
      icon = "https://image.flaticon.com/icons/png/512/1548/1548682.png";
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["url"] = url;
    map["thumb"] = thumb;
    map["icon"] = icon;
    map["formated_size"] = size;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other.url == this.url;
  }

  @override
  int get hashCode => this.url.hashCode;

  @override
  String toString() {
    return this.toMap().toString();
  }
}
