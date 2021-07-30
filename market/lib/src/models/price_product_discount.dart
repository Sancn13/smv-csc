import '../helpers/custom_trace.dart';

class PriceProductDiscount {
  String product_id;
  double price;

  PriceProductDiscount();

  PriceProductDiscount.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      product_id = jsonMap['product_id'].toString();
      price = jsonMap['price_product'] != null ? jsonMap['price_product'].toDouble() : 00.00;
    } catch (e) {
      product_id = '';
      price = 00.00;
      print(CustomTrace(StackTrace.current, message: e));
    }
  }
}