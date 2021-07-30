import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/filter.dart';
import '../models/market.dart';
import '../models/review.dart';
import '../repository/user_repository.dart';

Future<Stream<Market>> getNearMarkets(Address myLocation, Address areaLocation) async {
  Uri uri = Helper.getUri('api/market');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  _queryParams['company_id'] = '0';
  // _queryParams['limit'] = '6';
  // if (!myLocation.isUnknown() && !areaLocation.isUnknown()) {
  //   _queryParams['myLon'] = myLocation.longitude.toString();
  //   _queryParams['myLat'] = myLocation.latitude.toString();
  //   _queryParams['areaLon'] = areaLocation.longitude.toString();
  //   _queryParams['areaLat'] = areaLocation.latitude.toString();
  // }
  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Market.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Market.fromJSON({}));
  }
}

Future<Stream<Market>> getPopularMarkets(Address myLocation) async {
  Uri uri = Helper.getUri('api/reportsMobile');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // _queryParams['limit'] = '6';
  // _queryParams['popular'] = 'all';
  // if (!myLocation.isUnknown()) {
  //   _queryParams['myLon'] = myLocation.longitude.toString();
  //   _queryParams['myLat'] = myLocation.latitude.toString();
  // }
  _queryParams['report'] = 'market';
  _queryParams['days'] = '30';
  uri = uri.replace(queryParameters: _queryParams);
  print(uri);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Market.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Market.fromJSON({}));
  }
}

Future<Stream<Market>> searchMarkets(String search, Address address) async {
  Uri uri = Helper.getUri('api/markets');
  Map<String, dynamic> _queryParams = {};
  _queryParams['search'] = 'name:$search;description:$search';
  _queryParams['searchFields'] = 'name:like;description:like';
  _queryParams['limit'] = '5';
  if (!address.isUnknown()) {
    _queryParams['myLon'] = address.longitude.toString();
    _queryParams['myLat'] = address.latitude.toString();
    _queryParams['areaLon'] = address.longitude.toString();
    _queryParams['areaLat'] = address.latitude.toString();
  }
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Market.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Market.fromJSON({}));
  }
}

Future<Stream<Market>> getMarket(String id, Address address) async {
  Uri uri = Helper.getUri('api/market');
  Map<String, dynamic> _queryParams = {};
  print(address.isUnknown());
  _queryParams['company_id'] = id;
  // if (!address.isUnknown()) {
  //   _queryParams['myLon'] = address.longitude.toString();
  //   _queryParams['myLat'] = address.latitude.toString();
  //   _queryParams['areaLon'] = address.longitude.toString();
  //   _queryParams['areaLat'] = address.latitude.toString();
  // }
  // else{
  //   _queryParams['company_id'] = id;
  // }
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).map((data) => Market.fromJSON(data[0]));
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Market.fromJSON({}));
  }
}

Future<Stream<Review>> getMarketReviews(String id) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}discussionsMobile?company_id=1&&object_type=M&&items_per_page=6';
  print(url);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Review.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Review.fromJSON({}));
  }
}

// Future<Stream<Review>> getMarketReviews(String id) async {
//   final String url = '${GlobalConfiguration().getValue('api_base_url')}market_reviews?with=user&search=market_id:$id';
//   try {
//     final client = new http.Client();
//     final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

//     return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
//       return Review.fromJSON(data);
//     });
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: url).toString());
//     return new Stream.value(new Review.fromJSON({}));
//   }
// }

Future<Stream<Review>> getRecentReviews() async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}DiscussionsMobile?sort_order=desc&&items_per_page=4';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Review.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Review.fromJSON({}));
  }
}


// Future<Stream<Review>> getRecentReviews() async {
//   final String url = '${GlobalConfiguration().getValue('api_base_url')}market_reviews?orderBy=updated_at&sortedBy=desc&limit=3&with=user';
//   try {
//     final client = new http.Client();
//     final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
//     return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
//       return Review.fromJSON(data);
//     });
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: url).toString());
//     return new Stream.value(new Review.fromJSON({}));
//   }
// }

Future<Review> addMarketReview(Review review, Market market) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}DiscussionsMobile';
  final client = new http.Client();
  review.user = currentUser.value;
  print(review.user.name);
  try {
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({
        "object_type": "M",
        "object_id": market.id,
        "name": review.user.name,
        "rating_value": review.rate,
        "message": review.review,
      }),
    );
    if (response.statusCode == 201) {
      return Review.fromJSON(json.decode(response.body)['data']);
    } else {
      print(CustomTrace(StackTrace.current, message: response.body).toString());
      return Review.fromJSON({});
    }
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Review.fromJSON({});
  }
}
