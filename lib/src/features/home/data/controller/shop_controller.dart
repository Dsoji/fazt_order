import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../repository/shop_repository.dart';
import '../state/shop_state.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

final shopControllerProvider =
    StateNotifierProvider<ShopController, ShopState>((ref) {
  final authenticationRepository = ref.watch(shopRepositoryProvider);
  return ShopController(
    authenticationRepository: authenticationRepository,
    ref: ref,
  );
});

class ShopController extends StateNotifier<ShopState> {
  ShopController({
    required ShopRepository authenticationRepository,
    required this.ref,
  })  : _authenticationRepository = authenticationRepository,
        super(
          ShopState.initial(),
        ) {
    // geAuthCredential();
  }

  final ShopRepository _authenticationRepository;
  final Ref ref;

  Future<bool> fetchShops() async {
    state = state.copyWith(shops: const AsyncValue.loading());
    final result = await _authenticationRepository.fetchShops();

    return result.when(
      (error) {
        state =
            state.copyWith(shops: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(shops: AsyncValue.data(success));
        return true;
      },
    );
  }

  Future<bool> fetchShopFoodCategory(String shopId) async {
    state = state.copyWith(shopFoodCategory: const AsyncValue.loading());
    final result =
        await _authenticationRepository.fetchShopFoodCategory(shopId);

    return result.when(
      (error) {
        state = state.copyWith(
            shopFoodCategory: AsyncValue.error(error, StackTrace.current));
        return false;
      },
      (success) {
        state = state.copyWith(shopFoodCategory: AsyncValue.data(success));
        return true;
      },
    );
  }

  final debouncer = Debouncer(milliseconds: 350);

  Future<bool> globalSearch(
      String searchQuery, String latitude, String longitude) async {
    debouncer.run(() async {
      state = state.copyWith(searchQuery: const AsyncValue.loading());
      final result = await _authenticationRepository.globalSearch(
          searchQuery, latitude, longitude);

      return result.when(
        (error) {
          state = state.copyWith(
              searchQuery: AsyncValue.error(error, StackTrace.current));
          return false;
        },
        (success) {
          state = state.copyWith(searchQuery: AsyncValue.data(success));
          return true;
        },
      );
    });
    return true; // This return is to satisfy the function signature, but it's not actually used in this context.
  }

  // Future<bool> fetchProfile() async {
  //   state = state.copyWith(userDetails: const AsyncValue.loading());

  //   final result = await _authenticationRepository.fetchProfileDetails();

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         userDetails: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         userDetails: AsyncValue.data(success),
  //       );
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> updateUsername(
  //   String payload,
  // ) async {
  //   state = state.copyWith(userName: const AsyncValue.loading());

  //   final result = await _authenticationRepository.updateUsername(
  //     name: payload,
  //   );

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         userName: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         userName: AsyncValue.data(success),
  //       );
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> updateEmail(
  //   String payload,
  //   String code,
  // ) async {
  //   state = state.copyWith(emailChange: const AsyncValue.loading());

  //   final result = await _authenticationRepository.updateEmail(
  //     email: payload,
  //     code: code,
  //   );

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         emailChange: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         emailChange: AsyncValue.data(success),
  //       );
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> changePassword(
  //   String password,
  //   String oldPassword,
  // ) async {
  //   state = state.copyWith(forgotPassword: const AsyncValue.loading());

  //   final result = await _authenticationRepository.updatePswrd(
  //     password: password,
  //     oldPassword: oldPassword,
  //   );

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         forgotPassword: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         forgotPassword: AsyncValue.data(success),
  //       );
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> changePin(
  //   String email,
  //   String code,
  //   String pin,
  // ) async {
  //   state = state.copyWith(resetPin: const AsyncValue.loading());

  //   final result = await _authenticationRepository.updatePin(
  //     email: email,
  //     pin: pin,
  //     code: code,
  //   );

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         resetPin: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         resetPin: AsyncValue.data(success),
  //       );
  //       return true;
  //     },
  //   );
  // }

  // Future<bool> uploadMultipleFiles(List<File> files) async {
  //   state = state.copyWith(imageUpload: const AsyncValue.loading());

  //   final formData = FormData();

  //   for (var file in files) {
  //     final fileName = file.path.split('/').last;

  //     formData.files.add(
  //       MapEntry(
  //         "file", // 👈 This must match what the backend expects
  //         await MultipartFile.fromFile(
  //           file.path,
  //           filename: fileName,
  //           contentType: MediaType('image', fileName.split('.').last),
  //         ),
  //       ),
  //     );
  //   }

  //   final result = await _authenticationRepository.uploadImage(formData);

  //   return result.when(
  //     (error) {
  //       state = state.copyWith(
  //         imageUpload: AsyncValue.error(error, StackTrace.current),
  //       );
  //       return false;
  //     },
  //     (success) {
  //       state = state.copyWith(
  //         imageUpload: AsyncValue.data(success ?? UploadResponse()),
  //       );
  //       return true;
  //     },
  //   );
  // }
}
