import 'package:html_unescape/html_unescape.dart';

class FilterAttribute {
  int? id;
  String? slug;
  String? name;

  FilterAttribute.fromJson(Map parsedJson) {
    id = parsedJson['id'];
    slug = parsedJson['slug'];
    name = HtmlUnescape().convert(parsedJson['name']);
  }
}

class SubAttribute {
  int? id;
  String? name;

  SubAttribute.fromJson(Map parsedJson) {
    id = parsedJson['id'];
    name = HtmlUnescape().convert(parsedJson['name']);
  }

  @override
  String toString() {
    return '[id: $id ===== name: $name]';
  }
}
