import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/credit_card.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Order>> getOrders() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  //final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}ordersMobile?user_id=' + _user.id + '&token=' + _user.apiToken + '&filter=order';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getOrder(orderId) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  //final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url ='${GlobalConfiguration().getValue('api_base_url')}ordersMobile?order_id=' + orderId +'&user_id=' + _user.id + '&token=' + _user.apiToken + '&filter=order';
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).map((data) {
    return Order.fromJSON(data);
  });
}

Future<Stream<Order>> getRecentOrders() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  final String url ='${GlobalConfiguration().getValue('api_base_url')}ordersMobile?user_id=1&recent=3' + 'user_id=' + _user.id + '&token=' + _user.apiToken + '&filter=order';
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    return Order.fromJSON(data);
  });
}

Future<Stream<OrderStatus>> getOrderStatus(String order_id,String payment_method) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(null);
  }
  final String url = '${GlobalConfiguration().getValue('api_base_url')}OrderStatusMobile?method=' + payment_method + '&order_id=' + order_id + '&user_id=' + _user.id + '&token=' + _user.apiToken + '&app=market';
  //final String url = '${GlobalConfiguration().getString('api_base_url')}order_statuses?$_apiToken';
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    return OrderStatus.fromJSON(data);
  });
}

Future addOrder(Order order, Payment payment,String code_coupon,bool canDelivery) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Order();
  }

    

    final client_address = new http.Client();
    String url_address = '${GlobalConfiguration().getValue('api_base_url')}AddressMobile?type=user&user_id=' + _user.id;
    final user_type_response = await client_address.get(url_address);
    var user_type_json = json.decode(user_type_response.body);

    var user_info = user_type_json['data'];

    String user_data = '"user_address": {' 
    +'"email": "${user_info['email']}",'
    +'"b_firstname": "${user_info['b_firstname']}",'
    +'"b_lastname": "${user_info['b_lastname']}",'
    +'"b_address": "${order.deliveryAddress.address}",'
    +'"b_city": "",'
    +'"b_state": "",'
    +'"b_country": "${user_info['b_country']}",'
    +'"b_zipcode": "",'
    +'"b_phone": "${user_info['b_phone']}",'
    +'"s_firstname": "${user_info['s_firstname']}",'
    +'"s_lastname": "${user_info['s_lastname']}",'
    +'"s_address": "${order.deliveryAddress.address}",'
    +'"s_city": "",'
    +'"s_state": "",'
    +'"s_country": "${user_info['s_country']}",'
    +'"s_zipcode": "",'
    +'"s_phone": "${user_info['s_phone']}"'
    + '}';

  var success = false;

  String shipping_id = '';

  CreditCard _creditCard = await userRepo.getCreditCard();
  order.user = _user;
  order.payment = payment;

  // print(order.productOrders[0].options.length);

  if(order.payment.method == "Cash on Delivery"){
    order.payment.id = '13'; 
  }
  else if(order.payment.method == "visacard" || order.payment.method == "mastercard"){
    order.payment.id = '1';
  }
  else if(order.payment.method == "paypal"){
    order.payment.id = '12';
  }
  else{
    //Pay on Pickup
    order.payment.id = '14';

  }

  if(order.payment.id == '14'){
    shipping_id = '6';
  }
  else{
    if(canDelivery == false){
      shipping_id = '1';
    }
    else{
      shipping_id = '7';
    }
  }

  final String url = '${GlobalConfiguration().getValue('api_base_url')}ordersMobile';
  final client = new http.Client();
  Map params = order.toMap();
  params.addAll(_creditCard.toMap());
  var str_product = "";

  for(var i=0;i<order.productOrders.length;i++){
    var str_options = "";
    for(var j=0;j<order.productOrders[i].options.length;j++){
      str_options = str_options + '"' + order.productOrders[i].options[j].optionGroupId + '"' + ':' + '"' + order.productOrders[i].options[j].id.split(":")[1] + '"';
      if(order.productOrders[i].options.length - j >1){
        str_options = str_options + ',';
      }
    }
    str_product += '"'+ (i+1).toString() +'":{"product_id":"'+ order.productOrders[i].product.id +'","amount":"'+ order.productOrders[i].quantity.toString() 
    + '","product_options":{' + str_options + '}},';
  }

  str_product = str_product.substring(0,str_product.length -1);
  str_product = '{' + str_product +'}';
  var msg = '{"user_id":"' + _user.id +'","shipping_id": "'+ shipping_id +'",'+ '"payment_id":' + order.payment.id + ',"coupon_codes":"' + code_coupon.toString() + '","products":' + str_product +',"address_id":'+ order.deliveryAddress.id +',"token":"' + _user.apiToken +'",' + user_data +'}';
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: msg
  );
  if(response.statusCode == 201){
      for(var i=0;i<order.productOrders.length;i++){
        final String url2 = '${GlobalConfiguration().getValue('api_base_url')}cartsMobile/'+ _user.id + '?product_id=' + order.productOrders[i].product.id;
        final client_2 = new http.Client();
        final deleted = await client_2.delete(url2);
        if(deleted.statusCode == 201){
          success = true;
        }
      }
  }

  success = true;

  return success;
}

Future<Order> cancelOrder(Order order) async {
  User _user = userRepo.currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}orders/${order.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.cancelMap()),
  );
  if (response.statusCode == 200) {
    return Order.fromJSON(json.decode(response.body)['data']);
  } else {
    throw new Exception(response.body);
  }
}
