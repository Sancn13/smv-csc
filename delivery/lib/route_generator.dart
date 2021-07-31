import 'package:flutter/material.dart';

import 'src/models/route_argument.dart';
import 'src/pages/languages.dart';
import 'src/pages/login.dart';
import 'src/pages/order.dart';
import 'src/pages/pages.dart';
import 'src/pages/settings.dart';
import 'src/pages/splash_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      case '/Splash':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/Login':
        return MaterialPageRoute(builder: (_) => LoginWidget());
      case '/Pages':
        return MaterialPageRoute(builder: (_) => PagesTestWidget(currentTab: args));
      case '/OrderDetails':
        return MaterialPageRoute(builder: (_) => OrderWidget(routeArgument: args as RouteArgument));
      case '/Languages':
        return MaterialPageRoute(builder: (_) => LanguagesWidget());
      case '/Settings':
        return MaterialPageRoute(builder: (_) => SettingsWidget());
      default:
        // If there is no such named route in the switch statement, e.g. /third
        return MaterialPageRoute(builder: (_) => Scaffold(body: SizedBox(height: 0)));
    }
  }
}
