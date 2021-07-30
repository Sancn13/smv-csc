import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/favorite.dart';
import '../models/filter.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Product>> getTrendingProducts(Address address) async {
  Uri uri = Helper.getUri('api/reportsMobile');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
  // filter.delivery = false;
  // filter.open = false;
  // _queryParams['limit'] = '6';
  // _queryParams['trending'] = 'week';
  // if (!address.isUnknown()) {
  //   _queryParams['myLon'] = address.longitude.toString();
  //   _queryParams['myLat'] = address.latitude.toString();
  //   _queryParams['areaLon'] = address.longitude.toString();
  //   _queryParams['areaLat'] = address.latitude.toString();
  // }
  _queryParams['days'] = '7';
  _queryParams['report'] = 'product';
  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  print(uri);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

Future<Stream<Product>> getProduct(String productId) async {
  Uri uri = Helper.getUri('api/productsMobile');
  uri = uri.replace(queryParameters: {
    'product_id': productId
    });
  print(uri);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));
    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}


// Future<Stream<Product>> getProduct(String productId) async {
//   Uri uri = Helper.getUri('api/products/$productId');
//   uri = uri.replace(queryParameters: {'with': 'market;category;options;optionGroups;productReviews;productReviews.user'});
//   try {
//     final client = new http.Client();
//     final streamedRest = await client.send(http.Request('get', uri));
//     return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).map((data) {
//       return Product.fromJSON(data);
//     });
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: e.toString()).toString());
//     return new Stream.value(new Product.fromJSON({}));
//   }
// }

Future<Stream<Product>> searchProducts(String search, Address address) async {
  Uri uri = Helper.getUri('api/searchMobile');
  Map<String, dynamic> _queryParams = {};
  _queryParams['product'] = search;
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

// Future<Stream<Product>> searchProducts(String search, Address address) async {
//   Uri uri = Helper.getUri('api/products');
//   Map<String, dynamic> _queryParams = {};
//   _queryParams['search'] = 'name:$search;description:$search';
//   _queryParams['searchFields'] = 'name:like;description:like';
//   _queryParams['limit'] = '5';
//   if (!address.isUnknown()) {
//     _queryParams['myLon'] = address.longitude.toString();
//     _queryParams['myLat'] = address.latitude.toString();
//     _queryParams['areaLon'] = address.longitude.toString();
//     _queryParams['areaLat'] = address.latitude.toString();
//   }
//   uri = uri.replace(queryParameters: _queryParams);
//   try {
//     final client = new http.Client();
//     final streamedRest = await client.send(http.Request('get', uri));

//     return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
//       return Product.fromJSON(data);
//     });
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
//     return new Stream.value(new Product.fromJSON({}));
//   }
// }

Future<Stream<Product>> getProductsByCategory(String categoryId) async {
  Uri uri = Helper.getUri('api/productsMobile');
  Map<String, dynamic> _queryParams = {};
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));

  uri = uri.replace(queryParameters: {
  'categoryId': categoryId,
  });

  // _queryParams['with'] = 'market';
  // _queryParams['search'] = 'category_id:1';
  // _queryParams['searchFields'] = 'category_id:=';

  // _queryParams = filter.toQuery(oldQuery: _queryParams);
  // uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}


// Future<Stream<Product>> getProductsByCategory(categoryId) async {
//   Uri uri = Helper.getUri('api/products');
//   Map<String, dynamic> _queryParams = {};
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   Filter filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
//   _queryParams['with'] = 'market';
//   _queryParams['search'] = 'category_id:$categoryId';
//   _queryParams['searchFields'] = 'category_id:=';

//   _queryParams = filter.toQuery(oldQuery: _queryParams);
//   uri = uri.replace(queryParameters: _queryParams);
//   try {
//     final client = new http.Client();
//     final streamedRest = await client.send(http.Request('get', uri));

//     return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
//       return Product.fromJSON(data);
//     });
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
//     return new Stream.value(new Product.fromJSON({}));
//   }
// }

Future<Stream<Favorite>> isFavoriteProduct(String productId) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Stream.value(null);
  }
  //final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}FavoriteProductsMobile?user_id=${_user.id}&product_id=${productId}&filter=is_favorite&token=${_user.apiToken}';
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getObjectData(data)).map((data) => Favorite.fromJSON(data));
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Favorite.fromJSON({}));
  }
}

// Future<Stream<Favorite>> isFavoriteProduct(String productId) async {
//   User _user = userRepo.currentUser.value;
//   if (_user.apiToken == null) {
//     return Stream.value(null);
//   }
//   final String _apiToken = 'api_token=${_user.apiToken}&';
//   final String url = '${GlobalConfiguration().getValue('api_base_url')}favorites/exist?${_apiToken}product_id=$productId&user_id=${_user.id}';
//   try {
//     final client = new http.Client();
//     final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

//     return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getObjectData(data)).map((data) => Favorite.fromJSON(data));
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: url).toString());
//     return new Stream.value(new Favorite.fromJSON({}));
//   }
// }

// Future<Stream<Favorite>> getFavorites() async {
//   User _user = userRepo.currentUser.value;
//   if (_user.apiToken == null) {
//     return Stream.value(null);
//   }
//   final String url = 'http://192.168.56.1/cscmultiShop/api/FavoriteProductsMobile?user_id=' + _user.id;

//   final client = new http.Client();
//   final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
//   try {
//     return streamedRest.stream
//         .transform(utf8.decoder)
//         .transform(json.decoder)
//         .map((data) => Helper.getData(data))
//         .expand((data) => (data as List))
//         .map((data) => Favorite.fromJSON(data));
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: url).toString());
//     return new Stream.value(new Favorite.fromJSON({}));
//   }
// }

Future<Stream<Favorite>> getFavorites() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return Stream.value(null);
  }
  final String url = '${GlobalConfiguration().getValue('api_base_url')}FavoriteProductsMobile?user_id=' + _user.id + '&token=' + _user.apiToken;

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
  try {
    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) => Favorite.fromJSON(data));
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return new Stream.value(new Favorite.fromJSON({}));
  }
}

// Future<Stream<Favorite>> getFavorites() async {
//   User _user = userRepo.currentUser.value;
//   if (_user.apiToken == null) {
//     return Stream.value(null);
//   }
//   final String _apiToken = 'api_token=${_user.apiToken}&';
//   final String url =
//       '${GlobalConfiguration().getValue('api_base_url')}favorites?${_apiToken}with=product;user;options&search=user_id:${_user.id}&searchFields=user_id:=';

//   final client = new http.Client();
//   final streamedRest = await client.send(http.Request('get', Uri.parse(url)));
//   try {
//     return streamedRest.stream
//         .transform(utf8.decoder)
//         .transform(json.decoder)
//         .map((data) => Helper.getData(data))
//         .expand((data) => (data as List))
//         .map((data) => Favorite.fromJSON(data));
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: url).toString());
//     return new Stream.value(new Favorite.fromJSON({}));
//   }
// }

Future<Favorite> addFavorite(Favorite favorite) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Favorite();
  }
  //final String _apiToken = 'api_token=${_user.apiToken}';
  favorite.userId = _user.id;
  final String url = '${GlobalConfiguration().getValue('api_base_url')}cartsMobile';
  favorite.toMap()['type'] = 'wish_list';
  print(favorite.toMap());
  try {
    final client = new http.Client();
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode({
        "id" : null,
        "product_id" : favorite.product.id,
        "user_id" : favorite.userId,
        "options" : [],
        "type" : "wish_list",
      }),
    );
    print(url);
    return Favorite.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Favorite.fromJSON({});
  }
}

// Future<Favorite> addFavorite(Favorite favorite) async {
//   User _user = userRepo.currentUser.value;
//   if (_user.apiToken == null) {
//     return new Favorite();
//   }
//   final String _apiToken = 'api_token=${_user.apiToken}';
//   favorite.userId = _user.id;
//   final String url = '${GlobalConfiguration().getValue('api_base_url')}favorites?$_apiToken';
//   try {
//     final client = new http.Client();
//     final response = await client.post(
//       url,
//       headers: {HttpHeaders.contentTypeHeader: 'application/json'},
//       body: json.encode(favorite.toMap()),
//     );
//     return Favorite.fromJSON(json.decode(response.body)['data']);
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: url).toString());
//     return Favorite.fromJSON({});
//   }
// }

Future<Favorite> removeFavorite(Favorite favorite, String product_id) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Favorite();
  }
  //final String _apiToken = 'api_token=${_user.apiToken}';
  final String url = '${GlobalConfiguration().getValue('api_base_url')}FavoriteProductsMobile/${_user.id}?product_id=${product_id}&token=${_user.apiToken}';
  try {
    final client = new http.Client();
    final response = await client.delete(
      url,
    );
    print(url);
    print(response.statusCode);
    return Favorite.fromJSON(json.decode(response.body)['data']);
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: url).toString());
    return Favorite.fromJSON({});
  }
}

// Future<Favorite> removeFavorite(Favorite favorite) async {
//   User _user = userRepo.currentUser.value;
//   if (_user.apiToken == null) {
//     return new Favorite();
//   }
//   final String _apiToken = 'api_token=${_user.apiToken}';
//   final String url = '${GlobalConfiguration().getValue('api_base_url')}favorites/${favorite.id}?$_apiToken';
//   try {
//     final client = new http.Client();
//     final response = await client.delete(
//       url,
//       headers: {HttpHeaders.contentTypeHeader: 'application/json'},
//     );
//     return Favorite.fromJSON(json.decode(response.body)['data']);
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: url).toString());
//     return Favorite.fromJSON({});
//   }
// }

Future<Stream<Product>> getProductsOfMarket(String marketId, {List<String> categories}) async {
  Uri uri = Helper.getUri('api/productsMobile');
  // print(categories);
  // String category_id_str = "";
  Map<String, dynamic> query = {
    'marketId' : marketId,
  };
  if (categories == null ) {
    query['order_by'] = 'all';
  }
  else{
    if(categories.length > 1 && categories[0] != '0'){
      var cate_str = getArrCategories(categories);
      query['categoryId'] = cate_str;
      query['listCate'] = 'yes';
    }
    else if(categories[0] == '0'){
      query['order_by'] = 'all';
    }
    else{
      query['categoryId'] = categories;
    }
  }
  uri = uri.replace(queryParameters: query);
  print(uri);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

String getArrCategories(List<String> categories){
  var cate = "";
  for(var i=0;i<categories.length;i++){
    cate = cate + categories[i] + ',';
  }
  cate = cate.substring(0,cate.length -1);
  return cate;
}

Future<Stream<Product>> getTrendingProductsOfMarket(String marketId) async {
  Uri uri = Helper.getUri('api/ProductsMobile');
  uri = uri.replace(queryParameters: {
    'order_by': 'new',
    'marketId': '$marketId',
  });
  // TODO Trending products only
  print(uri);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

// Future<Stream<Product>> getTrendingProductsOfMarket(String marketId) async {
//   Uri uri = Helper.getUri('api/products');
//   uri = uri.replace(queryParameters: {
//     'with': 'category;options;productReviews',
//     'search': 'market_id:$marketId;featured:1',
//     'searchFields': 'market_id:=;featured:=',
//     'searchJoin': 'and',
//   });
//   // TODO Trending products only
//   try {
//     final client = new http.Client();
//     final streamedRest = await client.send(http.Request('get', uri));

//     return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
//       return Product.fromJSON(data);
//     });
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
//     return new Stream.value(new Product.fromJSON({}));
//   }
// }

Future<Stream<Product>> getFeaturedProductsOfMarket(String marketId) async {
  Uri uri = Helper.getUri('api/productsMobile');
  uri = uri.replace(queryParameters: {
    'marketId': marketId,
    'order_by': "random",
  });
  print(uri);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
      return Product.fromJSON(data);
    });
  } catch (e) {
    print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Product.fromJSON({}));
  }
}

// Future<Stream<Product>> getFeaturedProductsOfMarket(String marketId) async {
//   Uri uri = Helper.getUri('api/products');
//   uri = uri.replace(queryParameters: {
//     'with': 'category;options;productReviews',
//     'search': 'market_id:$marketId;featured:1',
//     'searchFields': 'market_id:=;featured:=',
//     'searchJoin': 'and',
//   });
//   try {
//     final client = new http.Client();
//     final streamedRest = await client.send(http.Request('get', uri));

//     return streamedRest.stream.transform(utf8.decoder).transform(json.decoder).map((data) => Helper.getData(data)).expand((data) => (data as List)).map((data) {
//       return Product.fromJSON(data);
//     });
//   } catch (e) {
//     print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
//     return new Stream.value(new Product.fromJSON({}));
//   }
// }

Future<Review> addProductReview(Review review, Product product) async {
  final String url = '${GlobalConfiguration().getValue('api_base_url')}product_reviews';
  final client = new http.Client();
  review.user = userRepo.currentUser.value;
  try {
    final response = await client.post(
      url,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(review.ofProductToMap(product)),
    );
    if (response.statusCode == 200) {
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
