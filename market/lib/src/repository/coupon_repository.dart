import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:markets/src/models/product_in_cart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/coupon.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Coupon>> verifyCoupon(String code,List<ProductInCart> listProduct ) async {
  User _user = userRepo.currentUser.value;
  //create order
  final String url = '${GlobalConfiguration().getValue('api_base_url')}ordersMobile';
  final client = new http.Client();
  String list_product_id = "";
  var str_product = "";
  for(var i=0;i<listProduct.length;i++){
    str_product += '"'+ (i+1).toString() +'":{"product_id":"'+ listProduct[i].product_id +'","amount":"'+ listProduct[i].quantity.toString() +'"},';
    list_product_id += listProduct[i].product_id + ',';
  }
  str_product = str_product.substring(0,str_product.length -1);
  str_product = '{' + str_product +'}';
  list_product_id = list_product_id.substring(0,list_product_id.length -1);
  var msg = '{"user_id":"' + _user.id +'","shipping_id":"1",'+ '"payment_id":' + 1.toString() + ',"coupon_codes":"' + code.toString() + '","products":' + str_product +'}';
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json','Authorization': _user.apiToken},
    body: msg
  );
  var order_id = json.decode(response.body)['success']['order_id'];

  //coupon
  Uri uri = Helper.getUri('api/couponsMobile');
  Map<String, dynamic> _queryParams = {};
  _queryParams['order_id'] = order_id.toString();
  _queryParams['coupon_code'] = code.toString();
  // _queryParams['product_id'] = list_product_id.toString();
  // _queryParams['number_product'] = listProduct.length.toString();
  uri = uri.replace(queryParameters: _queryParams);
  print(uri);
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  print(CustomTrace(StackTrace.current, message: uri.toString()).toString());

  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      print('ok');
      return Coupon.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Coupon.fromJSON({}));
  }
}

Future<Coupon> saveCoupon(Coupon coupon) async {
  if (coupon != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('coupon', json.encode(coupon.toMap()));
  }
  return coupon;
}

Future<Coupon> getCoupon() async {
  Coupon _coupon = Coupon.fromJSON({});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('coupon')) {
    _coupon = Coupon.fromJSON(json.decode(await prefs.get('coupon')));
  }
  return _coupon;
}
