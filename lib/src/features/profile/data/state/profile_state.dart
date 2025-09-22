// import 'package:fazt_order/src/features/manage_users/data/model/response/manager_list/manager_list.dart';
import 'package:fazt_order/src/features/profile/data/model/response/favourites_list.dart';
import 'package:fazt_order/src/features/profile/data/model/response/image_upload_response.dart';
import 'package:fazt_order/src/features/profile/data/model/response/store_details/store_details.dart';
import 'package:fazt_order/src/features/profile/data/model/response/user_wallet/user_wallet.dart';
import 'package:fazt_order/src/features/profile/data/model/response/transaction_history.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../auth/data/model/payload/profile_payload.dart';
import '../../../auth/data/model/response/user_model/user_model.dart';
import '../model/payload/sales_operation_payload.dart';

class ProfileState {
  final AsyncValue<ProfilePayload> profilePayload;
  final AsyncValue<UserModel> userDetails;
  final AsyncValue<String> createShop;
  final AsyncValue<String> storeDetails;
  final AsyncValue<String> bankDetails;
  final AsyncValue<String> shopSchedule;
  final AsyncValue<String> addManager;
  final AsyncValue<StoreDetails> storeInfo;
  final AsyncValue<TransactionHistoryResponse> transactionHistory;
  final AsyncValue<FavouritesListResponse> favouritesList;
  final AsyncValue<String> forgotPassword;
  final AsyncValue<ImageUploadResponse> imageUpload;
  final AsyncValue<String> feedBack;
  final AsyncValue<SchedulePayload> scheduleTime;
  final AsyncValue<String> addToFavorites;
  // final AsyncValue<ManagerList> managerList;
  final AsyncValue<String> addShop;
  final AsyncValue<String> loader;
  final AsyncValue<String> addMeal;
  final AsyncValue<UserWallet> wallet;

  const ProfileState({
    required this.favouritesList,
    required this.profilePayload,
    required this.userDetails,
    required this.storeDetails,
    required this.bankDetails,
    required this.createShop,
    required this.forgotPassword,
    required this.feedBack,
    required this.imageUpload,
    required this.scheduleTime,
    required this.shopSchedule,
    required this.addManager,
    required this.addToFavorites,
    // required this.managerList,
    required this.addShop,
    required this.loader,
    required this.addMeal,
    required this.storeInfo,
    required this.wallet,
    required this.transactionHistory,
  });

  factory ProfileState.initial() {
    return ProfileState(
      profilePayload: AsyncValue.data(ProfilePayload()),
      userDetails: AsyncValue.data(UserModel()),
      createShop: const AsyncValue.data(''),
      storeDetails: const AsyncValue.data(''),
      bankDetails: const AsyncValue.data(''),
      forgotPassword: const AsyncValue.data(''),
      feedBack: const AsyncValue.data(''),
      imageUpload: AsyncValue.data(ImageUploadResponse()),
      scheduleTime: AsyncValue.data(SchedulePayload()),
      shopSchedule: const AsyncValue.data(''),
      addManager: const AsyncValue.data(''),
      addToFavorites: const AsyncValue.data(''),
      favouritesList: AsyncValue.data(FavouritesListResponse()),
      // managerList: AsyncValue.data(ManagerList()),
      // managerList: AsyncValue.data(ManagerList()),
      addShop: const AsyncValue.data(''),
      loader: const AsyncValue.data(''),
      addMeal: const AsyncValue.data(''),
      storeInfo: AsyncData(StoreDetails()),
      wallet: AsyncValue.data(UserWallet()),
      transactionHistory: AsyncValue.data(TransactionHistoryResponse()),
    );
  }

  ProfileState copyWith({
    AsyncValue<ProfilePayload>? profilePayload,
    AsyncValue<String>? createShop,
    AsyncValue<String>? storeDetails,
    AsyncValue<String>? bankDetails,
    AsyncValue<UserModel>? userDetails,
    AsyncValue<String>? userName,
    AsyncValue<String>? emailChange,
    AsyncValue<String>? resetPin,
    AsyncValue<String>? feedBack,
    AsyncValue<String>? forgotPassword,
    AsyncValue<ImageUploadResponse>? imageUpload,
    AsyncValue<SchedulePayload>? scheduleTime,
    AsyncValue<String>? shopSchedule,
    AsyncValue<String>? addManager,
    AsyncValue<String>? addToFavorites,
    AsyncValue<FavouritesListResponse>? favouritesList,
    // AsyncValue<ManagerList>? managerList,
    AsyncValue<String>? addShop,
    AsyncValue<String>? loader,
    AsyncValue<String>? addMeal,
    AsyncValue<StoreDetails>? storeInfo,
    AsyncValue<UserWallet>? wallet,
    AsyncValue<TransactionHistoryResponse>? transactionHistory,
  }) {
    return ProfileState(
      profilePayload: profilePayload ?? this.profilePayload,
      userDetails: userDetails ?? this.userDetails,
      createShop: createShop ?? this.createShop,
      bankDetails: bankDetails ?? this.bankDetails,
      storeDetails: storeDetails ?? this.storeDetails,
      forgotPassword: forgotPassword ?? this.forgotPassword,
      feedBack: feedBack ?? this.feedBack,
      imageUpload: imageUpload ?? this.imageUpload,
      scheduleTime: scheduleTime ?? this.scheduleTime,
      shopSchedule: shopSchedule ?? this.shopSchedule,
      addManager: addManager ?? this.addManager,
      addToFavorites: addToFavorites ?? this.addToFavorites,
      favouritesList: favouritesList ?? this.favouritesList,
      // managerList: managerList ?? this.managerList,
      addShop: addShop ?? this.addShop,
      loader: loader ?? this.loader,
      addMeal: addMeal ?? this.addMeal,
      storeInfo: storeInfo ?? this.storeInfo,
      wallet: wallet ?? this.wallet,
      transactionHistory: transactionHistory ?? this.transactionHistory,
    );
  }
}
