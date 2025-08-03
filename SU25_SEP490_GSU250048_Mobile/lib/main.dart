import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/pages/app_route.dart';
import 'package:mobile/provider/author_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobile/services/navigation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //HttpOverrides.global = MyHttpOverride();
  await dotenv.load(fileName: ".env.prod");
  await Firebase.initializeApp();
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()..loadToken()),
          //ChangeNotifierProvider(create: (_) => BookingProvider()),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      scrollBehavior: const MaterialScrollBehavior()
          .copyWith(scrollbars: true),
      title: 'BOBTS',
       theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange.shade50),
      ),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
// class MyHttpOverride extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (cert, host, port) => true;
//   }
// }

