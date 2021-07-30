import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/credit_card.dart';
import '../models/user.dart' as userModel;
import '../repository/user_repository.dart' as userRepo;

ValueNotifier<userModel.User> currentUser = new ValueNotifier(userModel.User());

// Future<userModel.User> login(userModel.User user) async {
//   final String url = '${GlobalConfiguration().getValue('api_base_url')}login';
//   final client = new http.Client();
//   final response = await client.post(
//     url,
//     headers: {HttpHeaders.contentTypeHeader: 'application/json'},
//     body: json.encode(user.toMap()),
//   );
//   if (response.statusCode == 200) {
//     setCurrentUser(response.body);
//     currentUser.value = userModel.User.fromJSON(json.decode(response.body)['data']);
//   } else {
//     throw new Exception(response.body);
//   }
//   return currentUser.value;
// }

Future<userModel.User> login(userModel.User user) async {
  final String csc_url = '${GlobalConfiguration().getValue('api_base_url')}';
  final client = new http.Client();
  final resAuth = await client.post(
    csc_url + 'AuthTokensApiMobile',
    body:{
      "email": user.email,
      "password": user.password
    }
  );
  var resAuthJson = json.decode(resAuth.body);
  if(resAuthJson["token"] != null){
      print(resAuthJson);
      final response = await client.get(
        csc_url + 'usersMobile?app=market&user_id=' + resAuthJson["user_id"] + '&token=' + resAuthJson["token"] + '&search_type=user_id',
      );
      if (response.statusCode == 200) {
        currentUser.value = userModel.User.fromJSON(json.decode(response.body));
        currentUser.value.deviceToken = user.deviceToken;
        currentUser.value.password = user.password;
        var jsonUser = json.decode(response.body);
        jsonUser['password'] = user.password;
        print(json.encode(jsonUser));
        setCurrentUser(jsonUser);
      } else {
        throw new Exception(response.body);
      }
  }
  else{
    currentUser.value = null;
  }
  return currentUser.value;
}

// Future<userModel.User> register(userModel.User user) async {
//   final String url = '${GlobalConfiguration().getValue('api_base_url')}register';
//   final client = new http.Client();
//   final response = await client.post(
//     url,
//     headers: {HttpHeaders.contentTypeHeader: 'application/json'},
//     body: json.encode(user.toMap()),
//   );
//   if (response.statusCode == 200) {
//     setCurrentUser(response.body);
//     currentUser.value = userModel.User.fromJSON(json.decode(response.body)['data']);
//   } else {
//     throw new Exception(response.body);
//   }
//   return currentUser.value;
// }

Future<bool> register(userModel.User user) async {
  final String csc_url = '${GlobalConfiguration().getValue('api_base_url')}';
  bool success = false;
  final client = new http.Client();
  final response = await client.post(
    csc_url + 'usersMobile',
    body: {
      "email": user.email,
      "password": user.password
    },
  );
  if (response.statusCode == 201) {
    success = true;
  } else {
    throw new Exception(response.body);
  }
  return success;
}

Future<bool> resetPassword(userModel.User user) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}send_reset_link_email';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    throw new Exception(response.body);
  }
}

Future<void> logout() async {
  currentUser.value = new userModel.User();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('cscmultishop_current_user');
}

void setCurrentUser(jsonString) async {
  if (jsonString != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cscmultishop_current_user', json.encode(jsonString));
  }
}

Future<void> setCreditCard(CreditCard creditCard) async {
  if (creditCard != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('credit_card', json.encode(creditCard.toMap()));
  }
}

Future<userModel.User> getCurrentUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //prefs.clear();
  if (currentUser.value.auth == null && prefs.containsKey('cscmultishop_current_user')) {
    currentUser.value = userModel.User.fromJSON(json.decode(await prefs.get('cscmultishop_current_user')));
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

// Future<userModel.User> update(userModel.User user) async {
//   final String _apiToken = 'api_token=${currentUser.value.apiToken}';
//   final String url = '${GlobalConfiguration().getValue('api_base_url')}users/${currentUser.value.id}?$_apiToken';
//   final client = new http.Client();
//   print(user.toMap());
//   final response = await client.post(
//     url,
//     headers: {HttpHeaders.contentTypeHeader: 'application/json'},
//     body: json.encode(user.toMap()),
//   );
//   setCurrentUser(response.body);
//   currentUser.value = userModel.User.fromJSON(json.decode(response.body)['data']);
//   return currentUser.value;
// }

Future<userModel.User> update(userModel.User user) async {
  final String csc_url = '${GlobalConfiguration().getValue('api_base_url')}';
  final client = new http.Client();
  final response = await client.put(
    csc_url + "usersMobile/" + user.id + '?token=' + user.apiToken,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: jsonEncode({
      "firstname":user.firstname.toString(),
      "lastname":user.lastname.toString(),
      "email":user.email.toString(),
      "phone":user.phone.toString(),
      "address":user.address.toString(),
      "description":user.bio.toString(),
      "token":user.apiToken,
    }),
  );
  if(response.statusCode == 200){
    final dataUser = await client.get(
        csc_url + 'usersMobile?email=' + user.email + '&token=' + currentUser.value.apiToken,
    );
    if (dataUser.statusCode == 200) {
      currentUser.value = userModel.User.fromJSON(json.decode(dataUser.body));
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

List<Address> listAddress = [];

Future<Stream<Address>> getAddresses() async {
  userModel.User _user = currentUser.value;
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
        '${GlobalConfiguration().getValue('api_base_url')}AddressMobile?user_id=' + _user.id + '&type=location';
      //'${GlobalConfiguration().getValue('api_base_url')}delivery_addresses?$_apiToken&search=user_id:${_user.id}&searchFields=user_id:=&orderBy=updated_at&sortedBy=desc';
  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
    return Address.fromJSON(data);
  });
}

Future<Address> addAddress(Address address) async {
  userModel.User _user = userRepo.currentUser.value;
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
  userModel.User _user = userRepo.currentUser.value;
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
  userModel.User _user = userRepo.currentUser.value;
  final String url = '${GlobalConfiguration().getValue('api_base_url')}AddressMobile/' + address.id;
  final client = new http.Client();
  final response = await client.delete(url);
  return Address.fromJSON(json.decode(response.body)['data']);
}
