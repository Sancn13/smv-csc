import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Order>> getOrders({List<String> statusesIds}) async {

  statusesIds = statusesIds.toSet().toList();

  String status_ids = "";

  for(int i = 0;i<statusesIds.length;i++){
    if(statusesIds.length - i ==1){
      status_ids = status_ids + statusesIds[i];
    }
    else{
      status_ids = status_ids + statusesIds[i] + ',';
    };
  };
  Uri uri = Helper.getUri('api/ordersMobile');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;

  _queryParams['token'] = _user.apiToken;
  _queryParams['user_id'] = _user.id;
  _queryParams['status_ids'] = status_ids;
  _queryParams['filter'] = 'status_id';
  uri = uri.replace(queryParameters: _queryParams);
  print(uri);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<Order>> getNearOrders(Address myAddress, Address areaAddress) async {
  Uri uri = Helper.getUri('api/orders');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;

  _queryParams['api_token'] = _user.apiToken;
  _queryParams['limit'] = '6';
  _queryParams['with'] = 'productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress;payment';
  _queryParams['search'] = 'delivery_address_id:null';
  _queryParams['searchFields'] = 'delivery_address_id:<>';
  _queryParams['orderBy'] = 'id';
  _queryParams['sortedBy'] = 'desc';
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getValue('api_base_url')}orders?${_apiToken}with=driver;productOrders;productOrders.product;productOrders.options;orderStatus;deliveryAddress&search=driver.id:${_user.id};order_status_id:$orderStatusId&searchFields=driver.id:=;order_status_id:=&searchJoin=and&orderBy=id&sortedBy=desc';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}


Future<Stream<Order>> getOrder(orderId) async {
  Uri uri = Helper.getUri('api/ordersMobile');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(new Order());
  }

  _queryParams['token'] = _user.apiToken;
  _queryParams['user_id'] = _user.id;
  _queryParams['order_id'] = orderId;
  _queryParams['filter'] = 'order';
  uri = uri.replace(queryParameters: _queryParams);
  print(uri);
  //print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getObjectData(data)).map((data) {
      return Order.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Order.fromJSON({}));
  }
}

Future<Stream<OrderStatus>> getOrderStatuses() async {
  Uri uri = Helper.getUri('api/orderStatusMobile');
  Map<String, dynamic> _queryParams = {};
  User _user = userRepo.currentUser.value;

  _queryParams['token'] = _user.apiToken;
  _queryParams['user_id'] = _user.id;
  _queryParams['app'] = 'owner';
  //_queryParams['filter'] = 'id;status';
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    //print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return OrderStatus.fromJSON(data);
    });
  } catch (e) {
    //print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(OrderStatus.fromJSON({}));
  }
}

Future<Order> updateOrder(Order order) async {
  Uri uri = Helper.getUri('api/ordersMobile/'+ order.id);
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Order();
  }
  Map<String, dynamic> _queryParams = {};
  _queryParams['api_token'] = _user.apiToken;
  uri = uri.replace(queryParameters: _queryParams);
  print(uri);
  print(order.editableMap());
  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders/${order.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    uri.toString(),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.editableMap()),
  );
  print(response.body);
  return Order.fromJSON(json.decode(response.body)['data']);
}

Future<Order> cancelOrder(Order order) async {
  Uri uri = Helper.getUri('api/orders/${order.id}');
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Order();
  }
  Map<String, dynamic> _queryParams = {};
  _queryParams['api_token'] = _user.apiToken;
  uri = uri.replace(queryParameters: _queryParams);

  //final String url = '${GlobalConfiguration().getString('api_base_url')}orders/${order.id}?$_apiToken';
  final client = new http.Client();
  final response = await client.put(
    uri.toString(),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(order.cancelMap()),
  );
  return Order.fromJSON(json.decode(response.body)['data']);
}
