import 'package:flutter/material.dart';
import 'package:markets/src/models/payment.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../elements/PaymentMethodListItemWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import '../controllers/cart_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'dart:convert';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

class PaymentMethodsWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  PaymentMethodsWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _PaymentMethodsWidgetState createState() => _PaymentMethodsWidgetState();
}

class _PaymentMethodsWidgetState extends StateMVC<PaymentMethodsWidget> {

  CartController _con;

  _PaymentMethodsWidgetState() : super(CartController()) {
    _con = controller;
  }

  PaymentMethodList list;

  List list_payment_info = [];

  double total_origin = 0.0;

  void getSubCharge() async{

    var url_surcharge = Uri.parse('${GlobalConfiguration().getValue('api_base_url')}paymentsMobile?mode=list');

    print(url_surcharge);

    var res_surcharge = await http.get(url_surcharge);

    if(res_surcharge.statusCode == 200){
      var res = jsonDecode(res_surcharge.body)["data"];
      list_payment_info = res;
    }
    else{
      print(res_surcharge.statusCode);
    }
  }

  bool loading = true;

  @override
  void initState(){
    _con.listenForCarts();
    getSubCharge();
    super.initState();
  }

  loadCart(controller){
    if(loading == true){
          return CartBottomDetailsWidget(con: controller);
    }
    else{
      return SizedBox();
    }
  }

  Widget paymentMethod(index,type){
    List<PaymentMethod> listPayment = [];
    if(type == 'brantree'){
      listPayment = list.paymentsList; 
    }
    else if(type == 'cash'){
      listPayment = list.cashList; 
    }

    return  InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: ()async{
        if( listPayment[index].name == 'Cash on delivery'){
          setState((){
            loading = false;
            for(int i =0;i<list_payment_info.length;i++){
              if(list_payment_info[i]['payment'] == listPayment[index].name){
                print('ok');
                _con.calcalateTotalWithSurcharge(total_origin,double.parse(list_payment_info[i]['a_surcharge']),double.parse(list_payment_info[i]['p_surcharge']));
                _con.done_checkout = true;
                _con.route_payment = listPayment[index].route;
                _con.name_payment = listPayment[index].name;
                print(_con.done_checkout);
                break;
              }
            }
            loading = true;
          });
        }
        // else{
        //   var request = BraintreeDropInRequest(
        //         tokenizationKey: 'sandbox_mfdvmsgn_b3wnsfy75d84r7k3',
        //         collectDeviceData: true,
        //         paypalRequest: BraintreePayPalRequest(
        //         ),
        //         cardEnabled: true
        //       );
        //     BraintreeDropInResult result = await BraintreeDropIn.start(request);
        //     if(result != null){
        //       print(result.paymentMethodNonce.typeLabel);
        //       //Navigator.of(context).pushNamed(this.paymentMethod.route,arguments: RouteArgument(param: paymentMethod.name,heroTag:result.paymentMethodNonce.typeLabel,id: result.paymentMethodNonce.nonce));
        //     }
        //   }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          boxShadow: [
            BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                image: DecorationImage(image: AssetImage(listPayment[index].logo), fit: BoxFit.fill),
              ),
            ),
            SizedBox(width: 15),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          listPayment[index].name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        Text(
                          listPayment[index].description,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Theme.of(context).focusColor,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    list = new PaymentMethodList(context);
    if (!setting.value.payPalEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "paypal";
      });
    if (!setting.value.razorPayEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "razorpay";
      });
    if (!setting.value.stripeEnabled)
      list.paymentsList.removeWhere((element) {
        return element.id == "visacard" || element.id == "mastercard";
      });
    if(total_origin == 0){
      total_origin = _con.total;
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).payment_mode,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      bottomNavigationBar: loadCart(_con),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SearchBarWidget(),
            ),
            SizedBox(height: 15),
            list.paymentsList.length > 0
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.payment,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).payment_options,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      subtitle: Text(S.of(context).select_your_preferred_payment_mode),
                    ),
                  )
                : SizedBox(
                    height: 0,
                  ),
            SizedBox(height: 10),
            ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: list.paymentsList.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                return paymentMethod(index,'brantree');
              },
            ),
            list.cashList.length > 0
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.monetization_on_outlined,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).cash_on_delivery,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      subtitle: Text(S.of(context).select_your_preferred_payment_mode),
                    ),
                  )
                : SizedBox(
                    height: 0,
                  ),
            ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: list.cashList.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                return paymentMethod(index,'cash');
              },
            ),
          ],
        ),
      ),
    );
  }
}
