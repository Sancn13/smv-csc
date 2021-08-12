class Payment {
  String id;
  String status;
  String method;
  String key;

  Payment.init();

  Payment(this.method);

  Payment.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      status = jsonMap['status'] ?? '';
      method = jsonMap['method'] ?? '';
      key = jsonMap['key'] ?? '';
    } catch (e) {
      id = '';
      status = '';
      method = '';
      key = '';
      print(e);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'method': method,
      'key': key,
    };
  }
}
