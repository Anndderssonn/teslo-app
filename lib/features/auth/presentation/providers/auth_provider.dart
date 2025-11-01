import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/domain/domain.dart';
import 'package:teslo_shop/features/auth/infrastructure/infrastructure.dart';
import 'package:teslo_shop/features/shared/shared.dart';

final authProvider =
    StateNotifierProvider.autoDispose<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorage = KeyValueStorageImpl();
  return AuthNotifier(
      authRepository: authRepository, keyValueStorage: keyValueStorage);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorage keyValueStorage;

  AuthNotifier({required this.authRepository, required this.keyValueStorage})
      : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> loginUser(String email, String password) async {
    try {
      final user = await authRepository.login(email, password);
      _setLoggedUser(user);
    } on CustomError catch (error) {
      logout(error.message);
    } catch (error) {
      logout('Unknown error');
    }
  }

  void registerUser(String fullName, String email, String password,
      String confirmPassword) async {
    if (password != confirmPassword) {
      logout('Passwords are not the same');
      return;
    }
    try {
      final user = await authRepository.register(email, password, fullName);
      _setLoggedUser(user);
    } on CustomError catch (error) {
      logout(error.message);
    } catch (error) {
      logout('Unknown error');
    }
  }

  void checkAuthStatus() async {
    final token = await keyValueStorage.getValue<String>('token');
    if (token == null) return logout();

    try {
      final user = await authRepository.checkAuthStatus(token);
      _setLoggedUser(user);
    } catch (error) {
      logout();
    }
  }

  Future<void> logout([String? errorMessage]) async {
    await keyValueStorage.removeKey('token');
    state = state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        user: null,
        errorMessage: errorMessage);
  }

  void _setLoggedUser(User user) async {
    await keyValueStorage.setKeyValue('token', user.token);
    state = state.copyWith(
        user: user, authStatus: AuthStatus.authenticated, errorMessage: '');
  }
}

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState(
      {this.authStatus = AuthStatus.checking,
      this.user,
      this.errorMessage = ''});

  AuthState copyWith(
          {AuthStatus? authStatus, User? user, String? errorMessage}) =>
      AuthState(
          authStatus: authStatus ?? this.authStatus,
          user: user ?? this.user,
          errorMessage: errorMessage ?? this.errorMessage);
}
