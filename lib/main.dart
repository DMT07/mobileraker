import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:logger/logger.dart';
import 'package:mobileraker/app/AppSetup.dart';
import 'package:mobileraker/app/AppSetup.locator.dart';
import 'package:stacked_services/stacked_services.dart';

import 'app/AppSetup.router.dart';

Future<void> main() async {
  Logger.level = Level.info;

  await Settings.init();
  await openBoxes();
  setupLocator();
  await registerViewmodels();
  await registerPrinters();


  setupDialogUi();
  setupNotifications();
  runApp(MyApp());

  AwesomeNotifications().actionStream.listen((receivedNotification) {
    print("Received Press-Notifi:$receivedNotification");
    // Navigator.of(context).pushName(context,
    //     '/NotificationPage',
    //     arguments: { id: receivedNotification.id } // your page params. I recommend to you to pass all *receivedNotification* object
    // );
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var accentColorDarkTheme = Color.fromRGBO(178,24,24,1);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          toggleButtonsTheme: ToggleButtonsThemeData(fillColor: accentColorDarkTheme, selectedColor: Colors.white),
          // primarySwatch: Colors.orange,
        accentColor: accentColorDarkTheme,

      ),
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
    );
  }
}
