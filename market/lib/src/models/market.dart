import 'dart:math' show asin, cos, pow, sqrt;

import 'package:markets/src/models/address.dart';
import 'package:markets/src/repository/settings_repository.dart';

import '../models/media.dart';
import 'user.dart';
import '../repository/settings_repository.dart' as sett;

class Market {
  String id;
  String name;
  Media image;
  String rate;
  String address;
  String description;
  String phone;
  String mobile;
  String information;
  double deliveryFee;
  double adminCommission;
  double defaultTax;
  String latitude;
  String longitude;
  bool closed;
  bool availableForDelivery;
  double deliveryRange;
  double distance;
  List<User> users;
  Address currentAddress;
  double latd = 0.0;
  double lngd = 0.0;

  Market();

  Market.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      rate = jsonMap['rate'] ?? '0';
      deliveryFee = jsonMap['delivery_fee'] != null ? jsonMap['delivery_fee'].toDouble() : 0.0;
      adminCommission = jsonMap['admin_commission'] != null ? jsonMap['admin_commission'].toDouble() : 0.0;
      deliveryRange = jsonMap['delivery_range'] != null ? jsonMap['delivery_range'].toDouble() : 0.0;
      address = jsonMap['address'];
      //address = '392 Giovanny PineGorczanybury, CO 13600-6178';
      description = jsonMap['description'];
      phone = jsonMap['phone'];
      mobile = jsonMap['mobile'];
      defaultTax = jsonMap['default_tax'] != null ? jsonMap['default_tax'].toDouble() : 0.0;
      information = jsonMap['information'];
      latitude = jsonMap['latitude'].toString();
      longitude = jsonMap['longitude'].toString();
      closed = jsonMap['closed'] ?? false;
      availableForDelivery = jsonMap['available_for_delivery'] ?? false;
      //distance = jsonMap['distance'] != null ? double.parse(jsonMap['distance'].toString()) : 0.0;
      users = jsonMap['users'] != null && (jsonMap['users'] as List).length > 0 ? List.from(jsonMap['users']).map((element) => User.fromJSON(element)).toSet().toList() : [];
      distance = 0.0;
      if(latitude != null && longitude != null){
        latd = jsonMap['latitude'].toDouble();
        lngd = jsonMap['longitude'].toDouble();
        calcalateDistance();
      }
    } catch (e) {
      id = '';
      name = '';
      image = new Media();
      rate = '0';
      deliveryFee = 0.0;
      adminCommission = 0.0;
      deliveryRange = 0.0;
      address = '';
      description = '';
      phone = '';
      mobile = '';
      defaultTax = 0.0;
      information = '';
      latitude = '0';
      longitude = '0';
      closed = false;
      availableForDelivery = false;
      distance = 0.0;
      users = [];
      print(e);
    }
  }

  double _coordinateDistance(double lat1,double lon1,double lat2,double lon2) {
    double _distance = sqrt(pow(69.1 * (lat1 - currentAddress.latitude), 2) + pow(69.1 * (currentAddress.longitude - lngd) * cos(latd / 57.3), 2));
    return _distance;
  }

  void calcalateDistance()async{
    currentAddress = await sett.getCurrentLocation();
    distance = (_coordinateDistance(currentAddress.latitude,currentAddress.longitude,latd,lngd)/1.60934);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_fee': deliveryFee,
      'distance': distance,
    };
  }
}
