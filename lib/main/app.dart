import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../ai_chat/provider/chat_provider.dart';
import '../core/theme/app_theme.dart';
import 'navigation/routes/name.dart';
import 'navigation/routes/page.dart';
import '../utils/platform_utils.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set document title (web-only, safe for all platforms)
      PlatformUtils.setDocumentTitle('Hewar');
    });
  
    // initialization();
  }

  // void initialization() async {
  //   await Future.delayed(const Duration(seconds: 3));
  //   FlutterNativeSplash.remove();
  // }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      
      providers: [
        ...AppPage.allBlocProviders(context),
        ChangeNotifierProvider(create: (_) => ChatProvider()),

      ],
      child: ScreenUtilInit(
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            onGenerateRoute: AppPage.generateRouteSettings,
            initialRoute: AppRoutes.initial,
            themeMode: ThemeMode.light,
            theme: AppTheme(context: context).darkTheme,
            darkTheme: AppTheme(context: context).darkTheme,
          );
        },
      ),
    );
  }
}
