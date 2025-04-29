// import 'dart:convert';

// import 'package:hooks_riverpod/hooks_riverpod.dart';

// import '../../../shared/data/data.dart';
// import '../../../shared/shared.dart';
// import '../data.dart';
// import '../models/responses/device_visits.dart';

// final authenticationLocalServiceProvider =
//     Provider<AuthenticationLocalService>((ref) {
//   final storageService = ref.watch(secureStorageProvider);
//   return AuthenticationLocalService(storageService);
// });

// class AuthenticationLocalService {
//   AuthenticationLocalService(this.storageService);

//   final StorageService storageService;

//   final String userStorageKey = 'user_model';
//   final String userFcmToken = 'user_fcm_token';
//   final String firstTimeUserKey = 'user_first_time_tracker';
//   final String authCredentialKey = 'auth_credential';

//   Future<void> setUser(UserModel user) async {
//     final encodedUser = jsonEncode(user.toJson());

//     await storageService.set(userStorageKey, encodedUser);
//   }

//   Future<UserModel> getUser() async {
//     final user = await storageService.get(userStorageKey);

//     if (user != null) {
//       return UserModel.fromJson(user);
//     }
//     return UserModel();
//   }

//   Future<String> getToken() async {
//     final data = await storageService.get(userStorageKey);

//     if (data != null) {
//       final user = UserModel.fromJson(data);
//       return user.accessToken ?? '';
//     }
//     return '';
//   }

//   Future<String> geRefreshToken() async {
//     final data = await storageService.get(userStorageKey);

//     if (data != null) {
//       final user = UserModel.fromJson(data);
//       return user.refreshToken ?? '';
//     }
//     return '';
//   }

//   Future<void> removeUser() async {
//     await storageService.remove(userStorageKey);
//   }

//   Future<void> saveFcmToken(String fcmToken) async {
//     await storageService.set(userFcmToken, fcmToken);
//   }

//   Future<void> setUserFirstVisitOnDevice(DeviceVisit data) async {
//     DeviceVisits userVisits = await getUserVisitsOnDevice();
//     if (userVisits.visits.isEmpty) {
//       await storageService.set(
//         firstTimeUserKey,
//         DeviceVisits(visits: [data]).toJson(),
//       );
//     } else {
//       //check if the user has visited the app before
//       final visit = userVisits.visits.firstWhere(
//         (element) => element.identifier == data.identifier,
//         orElse: () => DeviceVisit(),
//       );

//       if (visit.identifier == null) {
//         userVisits = userVisits.copyWith(
//           visits: [...userVisits.visits, data],
//         );
//         await storageService.set(
//           firstTimeUserKey,
//           userVisits.toJson(),
//         );
//       } else {
//         userVisits = userVisits.copyWith(
//           visits: userVisits.visits.map((visit) {
//             if (visit.identifier == data.identifier) {
//               return data.copyWith(isFirstVisit: false);
//             }
//             return visit;
//           }).toList(),
//         );

//         await storageService.set(
//           firstTimeUserKey,
//           userVisits.toJson(),
//         );
//       }
//     }
//   }

//   Future<DeviceVisits> getUserVisitsOnDevice() async {
//     final data = await storageService.get(firstTimeUserKey);

//     if (data != null) {
//       return DeviceVisits.fromMap(data);
//     }
//     return DeviceVisits(visits: []);
//   }

//   Future<bool> isFirstTimeUser(String identifier) async {
//     final userVisits = await getUserVisitsOnDevice();
//     final visit = userVisits.visits.firstWhere(
//       (element) => element.identifier == identifier,
//       orElse: () => DeviceVisit(),
//     );
//     return visit.isFirstVisit == true;
//   }

//   Future<void> removeFirstTimeUser() async {
//     await storageService.remove(firstTimeUserKey);
//   }

//   Future<void> setUserAuthCredential({
//     required String email,
//     required String image,
//     required String firstName,
//     required String? password,
//   }) async {
//     String userPassword = password ?? '';
//     if (userPassword.isEmpty) {
//       Map data = await getUserAuthCredential();
//       userPassword = data['password'];
//     }
//     await storageService.set(
//       authCredentialKey,
//       jsonEncode({
//         'email': email,
//         'image': image,
//         'firstName': firstName,
//         'password': userPassword,
//       }),
//     );
//   }

//   Future<void> removeUserAuthCredential() async {
//     await storageService.remove(authCredentialKey);
//   }

//   Future<Map<String, dynamic>> getUserAuthCredential() async {
//     final data = await storageService.get(authCredentialKey);
//     return data ?? {};
//   }

//   // Future<void> updateTokenForBugFix() async {
//   //   final data = await storageService.get(userStorageKey);

//   //   if (data != null) {
//   //     final user = UserModel.fromJson(data);
//   //     UserModel updatedUser = user.copyWith(
//   //       accessToken: 'nwepifnpwenfpwefp',
//   //     );
//   //     final encodedUser = jsonEncode(updatedUser.toJson());
//   //     await storageService.set(userStorageKey, encodedUser);
//   //   }
//   // }
// }
