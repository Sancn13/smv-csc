import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Cart>> getCart() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  final String url = '${GlobalConfiguration().getValue('api_base_url')}cartsMobile?filter=cart&id=' + _user.id.toString();
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Cart.fromJSON(data);
  });
}

Future<Stream<int>> getCartCount() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(0);
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  //final String url = '${GlobalConfiguration().getString('api_base_url')}carts/count?${_apiToken}search=user_id:${_user.id}&searchFields=user_id:=';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}cartsMobile?filter=count&id=' + _user.id;
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map(
    (data) => Helper.getIntData(data),
  );
}

Future<Cart> addCart(Cart cart, bool reset) async {
  
  String product_options = "";

  if(cart.options.length >0){
    product_options = "{";
    for(int i =0 ;i<cart.options.length;i++){
      List<String> str;
      String options = "";
      str = cart.options[i].id.split(':');
      options = '"' + str[0] +'":' + str[1];
      product_options = product_options + options;
      if(cart.options.length - i ==1){
        product_options = product_options + "}";
      }
      else{
        product_options = product_options + ",";
      }
    }
  }
  else{
    product_options = "{}";
  }

  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Cart();
  }
  Map<String, dynamic> decodedJSON = {};
  cart.userId = _user.id;
  String body = '{' + 
    '"company_id":' + '"' + cart.product.market.id + '"' +
    ',"product_id":' + '"' +cart.product.id+'"' + 
    ',"amount":' + '"'+ cart.quantity.toString()+'"' + 
    ',"email":' + '"'+ _user.email+'"' + 
    ',"password":' + '"'+ _user.password.toString()+'"' + 
    ',"product_options":' + product_options + 
  "}";
  final String url = '${GlobalConfiguration().getValue('api_base_url')}cartMobile';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: body
  );
  try {
    decodedJSON = json.decode(response.body)['data'] as Map<String, dynamic>;
  } on FormatException catch (e) {
    print(e);
  }
  return cart;
}

Future<Cart> updateCart(Cart cart) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Cart();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  cart.userId = _user.id;
  final String url = '${GlobalConfiguration().getValue('api_base_url')}cartsMobile/'+ _user.id;
  //final String url = '${GlobalConfiguration().getString('api_base_url')}carts/${cart.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(cart.toMap()),
  );
  return Cart.fromJSON(json.decode(response.body)['data']);
}

Future<bool> removeCart(Cart cart) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return false;
  }
  //final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}cartMobile/' + cart.id + '?email=' + _user.email + '&password=' + _user.password.toString();
  //final String url = '${GlobalConfiguration().getString('api_base_url')}carts/${cart.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.delete(url);
  return Helper.getBoolData(json.decode(response.body));
  //return true;
}