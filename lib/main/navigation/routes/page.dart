import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phychological_counselor/ai_chat/screens/chat_screen.dart';
import 'package:phychological_counselor/home/screens/home_screen.dart';
import 'package:phychological_counselor/frontend/TherapyBotPage.dart';
import 'package:phychological_counselor/frontend/home_page.dart';
import 'package:phychological_counselor/frontend/SignUpPage.dart';
import 'package:phychological_counselor/home/screens/home_screen.dart';
import '../../../../frontend/verify_email_page.dart';


import '../../../data/local/user_database.dart';
import '../../global.dart';
import 'name.dart';

class AppPage {
 static List<PageEntity> routes = [
  PageEntity(
    route: AppRoutes.therapyBot,
    page: TherapyBotPage(),
  ),
  PageEntity(
    route: AppRoutes.login,
    page: HomePage(), // זה מסך ה־Login
  ),
  PageEntity(
    route: AppRoutes.signup,
    page: SignUpPage(),
  ),
   PageEntity(
    route: AppRoutes.verifyEmail,
    page: VerifyEmailPage(),
  ),
  PageEntity(
    route: AppRoutes.home,
    page: HomeScreen(), // זה מסך הצ'אט
  ),
];

    // PageEntity(
    //   route: AppRoutes.login,
    //   page: const LoginScreen(),
    //   bloc: BlocProvider(
    //     create: (_) => LoginBloc(),
    //   ),
    // ),
    // PageEntity(
    //   route: AppRoutes.register,
    //   page: const RegistrationScreen(),
    //   bloc: BlocProvider(
    //     create: (_) => RegisterBloc(),
    //   ),
    // ),
    // PageEntity(
    //   route: AppRoutes.home,
    //   page: const HomeScreen(),
    //
    // ),
    // PageEntity(
    //   route: AppRoutes.application,
    //   page: const ApplicationPage(),
    //   bloc: BlocProvider(
    //     create: (_) => AppBlocs(),
    //   ),
    // ),
    // PageEntity(
    //   route: AppRoutes.forgetPassword,
    //   page: ForgotPasswordScreen(),
    // ),
    // PageEntity(
    //   route: AppRoutes.forgetNotification,
    //   page: const ForgotNotificationScreen(),
    // ),
    // PageEntity(
    //   route: AppRoutes.profile,
    //   page: const ProfileScreen(),
    //   bloc: BlocProvider(
    //     create: (_) => ProfileBloc(databaseHelper: DatabaseHelper()),
    //   ),
    // ),
  
  static List<BlocProvider> allBlocProviders(BuildContext context) {
    List<BlocProvider> blocProviders = <BlocProvider>[];
    for (var bloc in routes) {
      if (bloc.bloc != null) {
        blocProviders.add(bloc.bloc as BlocProvider);
      }
    }
    return blocProviders;
  }

  static MaterialPageRoute generateRouteSettings(RouteSettings settings) {
    var result = routes.where((element) => element.route == settings.name);
    if (result.isNotEmpty) {
      bool deviceFirstOpen = Global.storageServices.getDeviceFirstOpen();
      bool isLoggedIn = Global.storageServices.getIsLoggedIn();

   if (result.first.route == AppRoutes.initial) {
  bool isLoggedIn = Global.storageServices.getIsLoggedIn();
  bool isFirstTime = !Global.storageServices.getDeviceFirstOpen();

  if (isFirstTime) {
    return MaterialPageRoute(
        builder: (_) => TherapyBotPage(), settings: settings);
  } else if (isLoggedIn) {
    return MaterialPageRoute(
        builder: (_) => HomeScreen(), settings: settings);
  } else {
    return MaterialPageRoute(
        builder: (_) => HomePage(), settings: settings);
  }
}

      return MaterialPageRoute(
          builder: (_) => result.first.page, settings: settings);
    }
    return MaterialPageRoute(
        builder: (_) => HomeScreen(), settings: settings);
  }
}

class PageEntity {
  String route;
  Widget page;
  dynamic bloc;
  PageEntity({required this.route, required this.page, this.bloc});
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:phychological_counselor/ai_chat/screens/chat_screen.dart';
// import 'package:phychological_counselor/home/screens/home_screen.dart';
// import 'package:phychological_counselor/frontend/TherapyBotPage.dart';
// import 'package:phychological_counselor/frontend/home_page.dart';
// import 'package:phychological_counselor/frontend/SignUpPage.dart';
// import 'package:phychological_counselor/home/screens/home_screen.dart';


// import '../../../data/local/user_database.dart';
// import '../../global.dart';
// import 'name.dart';

// class AppPage {
//  static List<PageEntity> routes = [
//   PageEntity(
//     route: AppRoutes.therapyBot,
//     page: TherapyBotPage(),
//   ),
//   PageEntity(
//     route: AppRoutes.login,
//     page: HomePage(), // זה מסך ה־Login
//   ),
//   PageEntity(
//     route: AppRoutes.signup,
//     page: SignUpPage(),
//   ),
//   PageEntity(
//     route: AppRoutes.home,
//     page: HomeScreen(), // זה מסך הצ'אט
//   ),
// ];

//     // PageEntity(
//     //   route: AppRoutes.login,
//     //   page: const LoginScreen(),
//     //   bloc: BlocProvider(
//     //     create: (_) => LoginBloc(),
//     //   ),
//     // ),
//     // PageEntity(
//     //   route: AppRoutes.register,
//     //   page: const RegistrationScreen(),
//     //   bloc: BlocProvider(
//     //     create: (_) => RegisterBloc(),
//     //   ),
//     // ),
//     // PageEntity(
//     //   route: AppRoutes.home,
//     //   page: const HomeScreen(),
//     //
//     // ),
//     // PageEntity(
//     //   route: AppRoutes.application,
//     //   page: const ApplicationPage(),
//     //   bloc: BlocProvider(
//     //     create: (_) => AppBlocs(),
//     //   ),
//     // ),
//     // PageEntity(
//     //   route: AppRoutes.forgetPassword,
//     //   page: ForgotPasswordScreen(),
//     // ),
//     // PageEntity(
//     //   route: AppRoutes.forgetNotification,
//     //   page: const ForgotNotificationScreen(),
//     // ),
//     // PageEntity(
//     //   route: AppRoutes.profile,
//     //   page: const ProfileScreen(),
//     //   bloc: BlocProvider(
//     //     create: (_) => ProfileBloc(databaseHelper: DatabaseHelper()),
//     //   ),
//     // ),
  
//   static List<BlocProvider> allBlocProviders(BuildContext context) {
//     List<BlocProvider> blocProviders = <BlocProvider>[];
//     for (var bloc in routes) {
//       if (bloc.bloc != null) {
//         blocProviders.add(bloc.bloc as BlocProvider);
//       }
//     }
//     return blocProviders;
//   }

//   static MaterialPageRoute generateRouteSettings(RouteSettings settings) {
//     var result = routes.where((element) => element.route == settings.name);
//     if (result.isNotEmpty) {
//       bool deviceFirstOpen = Global.storageServices.getDeviceFirstOpen();
//       bool isLoggedIn = Global.storageServices.getIsLoggedIn();

//    if (result.first.route == AppRoutes.initial) {
//   bool isLoggedIn = Global.storageServices.getIsLoggedIn();
//   bool isFirstTime = !Global.storageServices.getDeviceFirstOpen();

//   if (isFirstTime) {
//     return MaterialPageRoute(
//         builder: (_) => TherapyBotPage(), settings: settings);
//   } else if (isLoggedIn) {
//     return MaterialPageRoute(
//         builder: (_) => HomeScreen(), settings: settings);
//   } else {
//     return MaterialPageRoute(
//         builder: (_) => HomePage(), settings: settings);
//   }
// }

//       return MaterialPageRoute(
//           builder: (_) => result.first.page, settings: settings);
//     }
//     return MaterialPageRoute(
//         builder: (_) => HomeScreen(), settings: settings);
//   }
// }

// class PageEntity {
//   String route;
//   Widget page;
//   dynamic bloc;
//   PageEntity({required this.route, required this.page, this.bloc});
// }
