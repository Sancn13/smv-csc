
class Payment {
  String id;
  String status;
  String method;
  String key;
  String sub_method;
  double surcharge_amount;
  double surcharge_percent;

  Payment.init();

  Payment(this.method);

  Payment.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      status = jsonMap['status'] ?? '';
      method = jsonMap['method'] ?? '';
      key = jsonMap['key'] ?? '';
      method = jsonMap['method'] ?? '';
      surcharge_amount = jsonMap['amount'] ?? 0.0;
      surcharge_percent = jsonMap['amount'] ?? 0.0;
    } catch (e) {
      id = '';
      status = '';
      method = '';
      key = '';
      method = '';
      surcharge_percent = 0.0;
      surcharge_percent = 0.0;
      print(e);
    }
  }

  Map<String, dynamic> toMap() {
    
    return {
      'id': id,
      'status': status,
      'method': method,
      'key': key,
      'sub_method': sub_method,
      'surcharge_amount' : surcharge_amount,
      'surcharge_percent' : surcharge_percent,
    };
  }

}
