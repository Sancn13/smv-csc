import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/credit_card.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

ValueNotifier<User> currentUser = new ValueNotifier(User());

Future<User> login(User user) async {
  final String csc_url = '${GlobalConfiguration().getValue('api_base_url')}';
  final client = new http.Client();
  final resAuth = await client.post(
    csc_url + 'AuthTokensApiMobile',
    body:{
      "email": user.email,
      "password": user.password
    }
  );
  print(resAuth.body);
  var resAuthJson = json.decode(resAuth.body);
  if(resAuthJson["token"] != null){
      var url = csc_url + 'usersMobile?app=driver&user_id=' + resAuthJson["user_id"] + '&token=' + resAuthJson["token"] + '&search_type=user_id';
      final response = await client.get(url);
      print(url);
      if (response.statusCode == 200) {
        currentUser.value = User.fromJSON(json.decode(response.body));
        currentUser.value.deviceToken = user.deviceToken;
        currentUser.value.password = user.password;
        setCurrentUser(response.body);
      } else {
        throw new Exception(response.body);
      }
  }
  else{
    currentUser.value = null;
  }
  return currentUser.value;
}

Future<void> logout() async {
  currentUser.value = new User();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('cscmultishop_current_user_owner');
}

void setCurrentUser(jsonString) async {
  if (json.decode(jsonString) != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cscmultishop_current_user_delivery', json.encode(json.decode(jsonString)));
  }
}

Future<void> setCreditCard(CreditCard creditCard) async {
  if (creditCard != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('credit_card', json.encode(creditCard.toMap()));
  }
}

Future<User> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
  if (currentUser.value.auth == null && prefs.containsKey('cscmultishop_current_user_delivery')) {
    currentUser.value = User.fromJSON(json.decode(await prefs.get('cscmultishop_current_user_delivery')));
    currentUser.value.auth = true;
  } else {
    currentUser.value.auth = false;
  }
  // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
  currentUser.notifyListeners();
  return currentUser.value;
}

Future<CreditCard> getCreditCard() async {
  CreditCard _creditCard = new CreditCard();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('credit_card')) {
    _creditCard = CreditCard.fromJSON(json.decode(await prefs.get('credit_card')));
  }
  return _creditCard;
}

Future<User> update(User user) async {
  final String csc_url = '${GlobalConfiguration().getValue('api_base_url')}';
  final client = new http.Client();
  final response = await client.put(
    csc_url + "usersMobile/" + user.id,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: jsonEncode({
      "firstname":user.firstname.toString(),
      "lastname":user.lastname.toString(),
      "email":user.email.toString(),
      "phone":user.phone.toString(),
      "address":user.address.toString(),
      "description":user.bio.toString(),
      "token":user.apiToken.toString(),
    }),
  );
  print(csc_url + "usersMobile/" + user.id + '?token=' + user.apiToken);
  print(response.statusCode);
  print(response.body);
  if(response.statusCode == 200){
    final dataUser = await client.get(
        csc_url + 'usersMobile?app=driver&user_id=' + user.id + '&token=' + currentUser.value.apiToken + '&search_type=user_id',
    );
    print(dataUser.statusCode);
      print(dataUser.body);
    if (dataUser.statusCode == 200) {
      currentUser.value = User.fromJSON(json.decode(dataUser.body));
      currentUser.value.deviceToken = user.deviceToken;
      setCurrentUser(dataUser.body);
    } else {
      throw new Exception(dataUser.body);
    }
  }
  else{
    print("update failed");
  }
  return currentUser.value;
}

Future<Stream<Address>> getAddresses() async {
  User _user = currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?$_apiToken&search=user_id:${_user.id}&searchFields=user_id:=&orderBy=is_default&sortedBy=desc';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Address.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url));
    return new Stream.value(new Address.fromJSON({}));
  }
}

Future<Address> addAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  address.userId = _user.id;
  final String url = '${GlobalConfiguration().getValue('api_base_url')}AddressMobile';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(address.toMap()),
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}

Future<Address> updateAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  address.userId = _user.id;
  final String url = '${GlobalConfiguration().getValue('api_base_url')}addressMobile/' + address.id.toString();
  final client = new http.Client();
  final response = await client.put(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(address.toMap()),
  );
  return Address.fromJSON(json.decode(response.body)['data']);
}

Future<Address> removeDeliveryAddress(Address address) async {
  User _user = userRepo.currentUser.value;
  final String url = '${GlobalConfiguration().getValue('api_base_url')}AddressMobile/' + address.id;
  final client = new http.Client();
  final response = await client.delete(url);
  return Address.fromJSON(json.decode(response.body)['data']);
}
