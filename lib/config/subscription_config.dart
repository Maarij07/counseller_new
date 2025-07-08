// // import 'dart:async';
// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:in_app_purchase/in_app_purchase.dart';
//
// import 'dart:io';
//
// import 'package:purchases_flutter/purchases_flutter.dart';
//
// import '../core/global/widgets/toast_info.dart';
//
// abstract class PackagesInfo {
//   static final String _platform = Platform.operatingSystem;
//
//   static String get platform => _platform;
//   static String get weekly => _platform.weekly;
//   static String get monthly => _platform.monthly;
//   static String get annual => _platform.annual;
// }
//
// extension _PackageProperties on String {
//   static const _weeklyID = {
//     'android': 'veilnet_weekly',
//     'ios': 'com.example.refineAi.weekly',
//   };
//
//   static const _monthlyID = {
//     'android': 'veilnet_monthly',
//     'ios': 'veilnet_monthly_ios',
//   };
//
//   static const _annualID = {
//     'android': 'veilnet_annual',
//     'ios': 'com.example.refineAi.yearly',
//   };
//
//   String get weekly => _weeklyID[this]!;
//   String get monthly => _monthlyID[this]!;
//   String get annual => _annualID[this]!;
// }
// //
// // class SubscriptionConfig extends ChangeNotifier {
// //   final inAppPurchase = InAppPurchase.instance;
// //   bool _isPremium = false;
// //   bool _showAds = false;
// //   bool _isInappChecked = false;
// //   final bool _checkConsent = false;
// //   bool get isPremium => _isPremium;
// //   bool get showAds => _showAds;
// //   bool get checkConsent => _checkConsent;
// //   bool get isInappChecked => _isInappChecked;
// //
// //   List<String> productIds = <String>[
// //     PackagesInfo.weekly,
// //     PackagesInfo.monthly,
// //     PackagesInfo.annual,
// //   ];
// //
// //   SubscriptionConfig() {
// //     inAppPurchase.purchaseStream.listen(
// //       (List<PurchaseDetails> purchaseDetailsList) {
// //         updateIsCheceked();
// //         if (purchaseDetailsList.isEmpty) {
// //           updatePrimumFlag(false);
// //         } else {
// //           if (purchaseDetailsList
// //               .where((element) => element.status == PurchaseStatus.restored)
// //               .any((element) => productIds.contains(element.productID))) {
// //             updatePrimumFlag(true);
// //           } else {
// //             updatePrimumFlag(false);
// //           }
// //         }
// //       },
// //       onDone: () {},
// //       onError: (error) {},
// //     );
// //   }
// //
// //   Future initialize() async {
// //     await inAppPurchase.restorePurchases();
// //   }
// //
// //   void updatePrimumFlag(bool premium) {
// //     _isPremium = premium;
// //     _showAds = !premium; // Hide ads for premium users
// //     notifyListeners(); // Notify listeners of the updated state
// //   }
// //
// //   void updateIsChecked() {
// //     _isInappChecked = true;
// //     notifyListeners(); // Notify that the in-app check is completed
// //   }
// //
// //   updateIsCheceked() {
// //     _isInappChecked = true;
// //     notifyListeners();
// //   }
// // }
//
//
// class SubscriptionService {
//   Future<bool> checkIfPremium() async {
//     try {
//       final purchaserInfo = await Purchases.getCustomerInfo();
//       final entitlements = purchaserInfo.entitlements.active;
//
//       if (entitlements.containsKey('Premium Plans') &&
//           entitlements['Premium Plans']!.isActive) {
//         return true;
//       }
//     } catch (e) {
//       showToast(msg: e.toString());
//     }
//     return false;
//   }
// }
