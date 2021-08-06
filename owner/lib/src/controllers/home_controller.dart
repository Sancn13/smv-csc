import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/category.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../repository/market_repository.dart';

class HomeController extends ControllerMVC {
  List<Category> categories = <Category>[];
  List<Market> topMarkets = <Market>[];
  List<Review> recentReviews = <Review>[];
  List<Product> trendingProducts = <Product>[];

  HomeController() {
    listenForRecentReviews();
  }


  void listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> refreshHome() async {
    categories = <Category>[];
    topMarkets = <Market>[];
    recentReviews = <Review>[];
    trendingProducts = <Product>[];
    listenForRecentReviews();
  }
}
