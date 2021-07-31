import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/favorite.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Product>> getTrendingProducts() async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}products?with=market&limit=6';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    return Product.fromJSON(data);
  });
}

Future<Stream<Product>> getProduct(String productId) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}products/$productId?with=nutrition;market;category;extras;productReviews;productReviews.user';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).map((data) {
    print(Product.fromJSON(data).market.toMap());
    return Product.fromJSON(data);
  });
}

Future<Stream<Product>> getProductsByCategory(categoryId) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}products?with=market&search=category_id:$categoryId&searchFields=category_id:=';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    return Product.fromJSON(data);
  });
}