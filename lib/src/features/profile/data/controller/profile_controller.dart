import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';

import '../model/payload/add_shop_payload.dart';
import '../model/payload/sales_operation_payload.dart';
import '../repository/profile_repository.dart';
import '../state/profile_state.dart';

final logger = Logger();

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return ProfileController(
    profileRepository: profileRepository,
    ref: ref,
  );
});

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController({
    required ProfileRepository profileRepository,
    required this.ref,
  })  : _authenticationRepository = profileRepository,
        super(
          ProfileState.initial(),
        ) {
    // geAuthCredential();
  }

  final ProfileRepository _authenticationRepository;
  final Ref ref;

  Future<bool> createShop({
    required String businnessName,
    required String registrationNumber,
    required String proofOfRegistration,
  }) async {
    state = state.copyWith(createShop: const AsyncValue.loading());

    final result = await _authenticationRepository.createShop(
      businnessName: businnessName,
      registrationNumber: registrationNumber,
      proofOfRegistration: proofOfRegistration,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          createShop: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          createShop: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> storeDetails({
    required String storeName,
    required String storeDescription,
    required String storeDisplayImage,
    required String vendorType,
    required String officialEmail,
    required String officialPhone,
    required String storeAddress,
    required String storeId,
  }) async {
    state = state.copyWith(storeDetails: const AsyncValue.loading());

    final result = await _authenticationRepository.updatestoreDetails(
      storeName: storeName,
      storeDescription: storeDescription,
      storeDisplayImage: storeDisplayImage,
      vendorType: vendorType,
      officialEmail: officialEmail,
      officialPhone: officialPhone,
      storeAddress: storeAddress,
      storeId: storeId,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          storeDetails: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          storeDetails: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> bankDetails({
    required String bankName,
    required String accountNumber,
    required String accountName,
    required String storeId,
  }) async {
    state = state.copyWith(bankDetails: const AsyncValue.loading());

    final result = await _authenticationRepository.bankDetails(
      bankName: bankName,
      accountNumber: accountNumber,
      accountName: accountName,
      storeId: storeId,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          bankDetails: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          bankDetails: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> fetchProfile() async {
    state = state.copyWith(userDetails: const AsyncValue.loading());

    final result = await _authenticationRepository.fetchProfile();

    return result.when(
      (error) {
        state = state.copyWith(
          userDetails: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          userDetails: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> uploadFile({required File file}) async {
    state = state.copyWith(imageUpload: const AsyncValue.loading());

    final fileName = file.path.split('/').last;

    final formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        file.path,
        contentType: MediaType('image', fileName.split('.').last),
      ),
    });

    final result = await _authenticationRepository.uploadImage(formData);

    return result.when(
      (error) {
        state = state.copyWith(
          imageUpload: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          imageUpload: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> storeSchedule({
    required String storeId,
    required SchedulePayload payload,
  }) async {
    state = state.copyWith(shopSchedule: const AsyncValue.loading());

    final result = await _authenticationRepository.shopSchedule(
      payload: payload,
      storeId: storeId,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          shopSchedule: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          shopSchedule: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> addManager({
    required String storeId,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(addManager: const AsyncValue.loading());

    final result = await _authenticationRepository.addManager(
      storeId: storeId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          addManager: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          addManager: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  // Future<bool> listManager() async {
  //   state = state.copyWith(managerList: const AsyncValue.loading());

  //   final result = await _authenticationRepository.listManager();

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         managerList: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         managerList: AsyncValue.data(success),
  //       );
  //       return true;
  //     },
  //   );
  // }

  Future<bool> fetchStoreDetails() async {
    state = state.copyWith(storeInfo: const AsyncValue.loading());

    final result = await _authenticationRepository.storeDetails();

    return result.when(
      (error) {
        state = state.copyWith(
          storeInfo: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          storeInfo: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> addShop({
    required AddShopPayload payload,
  }) async {
    state = state.copyWith(addShop: const AsyncValue.loading());

    final result = await _authenticationRepository.addShop(
      payload: payload,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          addShop: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          addShop: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> addMealCategory({
    required String category,
  }) async {
    state = state.copyWith(storeInfo: const AsyncValue.loading());

    final result =
        await _authenticationRepository.addMealCategory(category: category);

    return result.when(
      (error) {
        state = state.copyWith(
          storeInfo: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          storeInfo: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> addMeal({
    required String category,
    required String mealName,
    required String mealDescription,
    required String priceDescription,
    required int price,
    required bool inStock,
    required String imageUrl,
    required String shopId,
  }) async {
    state = state.copyWith(addMeal: const AsyncValue.loading());

    final result = await _authenticationRepository.addMeal(
      category: category,
      mealName: mealName,
      mealDescription: mealDescription,
      priceDescription: priceDescription,
      price: price,
      inStock: inStock,
      imageUrl: imageUrl,
      shopId: shopId,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          addMeal: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          addMeal: AsyncValue.data(success),
        );
        return true;
      },
    );
  }

  Future<bool> updateNewProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    state = state.copyWith(loader: const AsyncValue.loading());

    final result = await _authenticationRepository.newProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );

    return result.when(
      (error) {
        state = state.copyWith(
          loader: AsyncValue.error(error, StackTrace.current),
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          loader: AsyncValue.data(success),
        );
        return true;
      },
    );
  }
}
