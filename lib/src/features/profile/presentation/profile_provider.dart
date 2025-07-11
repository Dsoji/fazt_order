import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileState {
  final String name;
  final String phone;
  final String email;

  ProfileState({
    required this.name,
    required this.phone,
    required this.email,
  });

  ProfileState copyWith({
    String? name,
    String? phone,
    String? email,
  }) {
    return ProfileState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier()
      : super(ProfileState(
          name: "Agbejero Solomon",
          phone: "08012345678",
          email: "namedaebreath4here@gmail.com",
        ));

  void updateProfile(
      {required String name, required String phone, required String email}) {
    state = state.copyWith(name: name, phone: phone, email: email);
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});
