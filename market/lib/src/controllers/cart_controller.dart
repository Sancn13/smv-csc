import 'package:flutter/material.dart';
import 'package:markets/src/models/product_in_cart.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../repository/cart_repository.dart';
import '../repository/coupon_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class CartController extends ControllerMVC {
  List<Cart> carts = <Cart>[];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;
  int cartCount = 0;
  double subTotal = 0.0;
  double total = 0.0;
  List<ProductInCart> product_in_cart = [];
  GlobalKey<ScaffoldState> scaffoldKey;

  CartController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForCarts({String message}) async {
    carts.clear();
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      if(product_in_cart.length > 0){
        var index = -1;
        for(var i=0;i<product_in_cart.length;i++){
          if(product_in_cart[i].product_id == _cart.product.id){
            index = i;
          }
        }
        if(index == -1){
          ProductInCart product_temp = new ProductInCart();
          product_temp.product_id = _cart.product.id;
          product_temp.quantity = _cart.quantity;
          product_in_cart.add(product_temp);
        }
        else{
          product_in_cart[index].quantity = _cart.quantity;
        }
      }
      else{
        ProductInCart product_temp = new ProductInCart();
        product_temp.product_id = _cart.product.id;
        product_temp.quantity = _cart.quantity;
        product_in_cart.add(product_temp);
      }
      
      if (!carts.contains(_cart)) {
        setState(() {
          coupon = _cart.product.applyCoupon(coupon);
          carts.add(_cart);
        });
      }
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (carts.isNotEmpty) {
        calculateSubtotal();
      }
      if (message != null) {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
      }
      onLoadingCartDone();
    });
  }

  //   void listenForCarts({String message}) async {
  //   carts.clear();
  //   final Stream<Cart> stream = await getCart();
  //   stream.listen((Cart _cart) {
  //     if (!carts.contains(_cart)) {
  //       setState(() {
  //         coupon = _cart.product.applyCoupon(coupon);
  //         carts.add(_cart);
  //       });
  //     }
  //   }, onError: (a) {
  //     print(a);
  //     ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
  //       content: Text(S.of(state.context).verify_your_internet_connection),
  //     ));
  //   }, onDone: () {
  //     if (carts.isNotEmpty) {
  //       calculateSubtotal();
  //     }
  //     if (message != null) {
  //       ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
  //         content: Text(message),
  //       ));
  //     }
  //     onLoadingCartDone();
  //   });
  // }

  void onLoadingCartDone() {}

  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    });
  }

  Future<void> refreshCarts() async {
    setState(() {
      carts = [];
    });
    listenForCarts(message: S.of(state.context).carts_refreshed_successfuly);
  }

  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts.remove(_cart);
    });
    updateQuantityProductList(_cart.product.id,-0);
    removeCart(_cart).then((value) {
      calculateSubtotal();
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).the_product_was_removed_from_your_cart(_cart.product.name)),
      ));
    });
  }

  void calculateSubtotal() async {
    double cartPrice = 0;
    subTotal = 0;
    carts.forEach((cart) {
      cartPrice = cart.product.price;
      cart.options.forEach((element) {
        cartPrice += element.price;
      });
      cartPrice *= cart.quantity;
      subTotal += cartPrice;
    });
    if (Helper.canDelivery(carts[0].product.market, carts: carts)) {
      deliveryFee = carts[0].product.market.deliveryFee;
    }
    taxAmount = (subTotal + deliveryFee) * carts[0].product.market.defaultTax / 100;
    total = subTotal + taxAmount + deliveryFee;
    if(coupon.valid == true){
      total = coupon.total;
    }
    setState(() {});
  }

  void doApplyCoupon(String code, {String message}) async {
    coupon = new Coupon.fromJSON({"code": code, "valid": null});
    final Stream<Coupon> stream = await verifyCoupon(code,product_in_cart);
    stream.listen((Coupon _coupon) async {
      coupon = _coupon;
    }, onError: (a) {
      print(a);
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).verify_your_internet_connection),
      ));
    }, onDone: () {
      listenForCarts();
    });
  }

  incrementQuantity(Cart cart) {
    if (cart.quantity <= 99) {
      ++cart.quantity;
      updateCart(cart);
      updateQuantityProductList(cart.product.id,1);
      calculateSubtotal();
    }
  }

  decrementQuantity(Cart cart) {
    if (cart.quantity > 1) {
      --cart.quantity;
      updateCart(cart);
      updateQuantityProductList(cart.product.id,-1);
      calculateSubtotal();
    }
  }

  updateQuantityProductList(product_id,action){
    for(var i=0;i<product_in_cart.length;i++){
      if(product_in_cart[i].product_id == product_id && action == 1){
        product_in_cart[i].quantity ++; 
      }
      else if(product_in_cart[i].product_id == product_id && action == -1){
        product_in_cart[i].quantity --;
      }
      else if(product_in_cart[i].product_id == product_id && action == 0){
        product_in_cart.removeWhere((item) => item.product_id == product_id);
      }
    }
  }

  void goCheckout(BuildContext context) {
    if (!currentUser.value.profileCompleted()) {
      ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
        content: Text(S.of(state.context).completeYourProfileDetailsToContinue),
        action: SnackBarAction(
          label: S.of(state.context).settings,
          textColor: Theme.of(state.context).accentColor,
          onPressed: () {
            Navigator.of(state.context).pushNamed('/Settings');
          },
        ),
      ));
    } else {
      if (carts[0].product.market.closed) {
        ScaffoldMessenger.of(scaffoldKey?.currentContext).showSnackBar(SnackBar(
          content: Text(S.of(state.context).this_market_is_closed_),
        ));
      } else {
        Navigator.of(state.context).pushNamed('/DeliveryPickup');
      }
    }
  }

  Color getCouponIconColor() {
    if (coupon?.valid == true) {
      return Colors.green;
    } else if (coupon?.valid == false) {
      return Colors.redAccent;
    }
    return Theme.of(state.context).focusColor.withOpacity(0.7);
  }
}
