//flutter_inappwebview: pubget 해야됨
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
//
// Future main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(new MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => new _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   InAppWebViewController _webViewController;
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('InAppWebView Example'),
//         ),
//         body: Container(
//             child: Column(children: <Widget>[
//               Expanded(
//                 child:InAppWebView(
//                   initialData: InAppWebViewInitialData(
//                       data: """
// <!DOCTYPE html>
// <html lang="en">
//     <head>
//         <meta charset="UTF-8">
//         <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
//     </head>
//     <body>
//         <h1>JavaScript Handlers (Channels) TEST</h1>
//         <script>
//             window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
//                 window.flutter_inappwebview.callHandler('handlerFoo')
//                   .then(function(result) {
//                     // print to the console the data coming
//                     // from the Flutter side.
//                     console.log(JSON.stringify(result));
//
//                     window.flutter_inappwebview
//                       .callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}, result);
//                 });
//             });
//         </script>
//         <a href= 'https://id.passlogin.com/oauth2/authorize?client_id=fFjIAZ7F3hKOk0ExwbWw&redirect_uri=https%3a%2f%2f211.253.20.112%3a443%2fapi%2fauth%2fpasscallback&response_type=code&state=12345&isHybrid=Y'>
//           pass 로그인
//         </a>
//     </body>
// </html>
//                   """
//                   ),
//                   initialOptions: InAppWebViewGroupOptions(
//                       crossPlatform: InAppWebViewOptions(
//                         debuggingEnabled: true,
//                       )
//                   ),
//                   onWebViewCreated: (InAppWebViewController controller) {
//                     _webViewController = controller;
//
//                     _webViewController.addJavaScriptHandler(handlerName:'handlerFoo', callback: (args) {
//                       // return data to JavaScript side!
//                       return {
//                         'bar': 'bar_value', 'baz': 'baz_value'
//                       };
//                     });
//
//                     _webViewController.addJavaScriptHandler(handlerName: 'handlerFooWithArgs', callback: (args) {
//                       print(args);
//                       // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
//                     });
//                   },
//                   onConsoleMessage: (controller, consoleMessage) {
//                     print(consoleMessage);
//                     // it will print: {message: {"bar":"bar_value","baz":"baz_value"}, messageLevel: 1}
//                   },
//                 ),
//               ),
//             ])
//         ),
//       ),
//     );
//   }
// }