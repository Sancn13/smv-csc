import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/category.dart';

Future<Stream<Category>> getCategories() async {
  final String url = '${GlobalConfiguration().getValue('api_base_api')}categoriesMobile';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) => Category.fromJSON(data));
}

Future<Stream<Category>> getCategory(String id) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}categories/$id';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).map((data) => Category.fromJSON(data));
  } catch (e) {
    return new Stream.value(new Category.fromJSON({}));
  }
}