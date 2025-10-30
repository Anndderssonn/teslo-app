import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teslo_shop/features/auth/domain/domain.dart';
import 'package:teslo_shop/features/auth/infrastructure/infrastructure.dart';

final authProvider =
    StateNotifierProvider.autoDispose<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  return AuthNotifier(authRepository: authRepository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;

  AuthNotifier({required this.authRepository}) : super(AuthState());

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

  void checkAuthStatus() async {}

  Future<void> logout([String? errorMessage]) async {
    state = state.copyWith(
        authStatus: AuthStatus.unauthenticated,
        user: null,
        errorMessage: errorMessage);
  }

  void _setLoggedUser(User user) {
    state = state.copyWith(user: user, authStatus: AuthStatus.authenticated);
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
