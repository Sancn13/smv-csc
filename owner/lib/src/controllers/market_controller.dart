import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../repository/market_repository.dart';
import '../repository/product_repository.dart';

class MarketController extends ControllerMVC {
  Market market;
  List<Market> markets = <Market>[];
  List<Product> products = <Product>[];
  List<Product> trendingProducts = <Product>[];
  List<Product> featuredProducts = <Product>[];
  List<Review> reviews = <Review>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  MarketController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForMarkets({String message}) async {
    final Stream<Market> stream = await getMarkets();
    stream.listen((Market _market) {
      setState(() => markets.add(_market));
    }, onError: (a) {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForMarket({String id, String message}) async {
    final Stream<Market> stream = await getMarket(id);
    stream.listen((Market _market) {
      setState(() => market = _market);
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForMarketReviews({String id, String message}) async {
    final Stream<Review> stream = await getMarketReviews(id);
    stream.listen((Review _review) {
      setState(() => reviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForProducts(String idMarket) async {
    final Stream<Product> stream = await getProductsOfMarket(idMarket);
    stream.listen((Product _product) {
      setState(() => products.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> refreshMarket() async {
    var _id = market.id;
    market = new Market();
    reviews.clear();
    featuredProducts.clear();
    listenForMarket(id: _id, message: S.of(state.context).market_refreshed_successfuly);
    listenForMarketReviews(id: _id);
  }

  Future<void> refreshMarkets() async {
    markets.clear();
    listenForMarkets(message: S.of(state.context).market_refreshed_successfuly);
  }
}
