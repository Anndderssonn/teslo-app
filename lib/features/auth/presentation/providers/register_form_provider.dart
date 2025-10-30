import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:teslo_shop/features/auth/presentation/providers/providers.dart';
import 'package:teslo_shop/features/shared/shared.dart';

class RegisterFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final FullName fullName;
  final Email email;
  final Password password;
  final Password confirmPassword;

  RegisterFormState(
      {this.isPosting = false,
      this.isFormPosted = false,
      this.isValid = false,
      this.fullName = const FullName.pure(),
      this.email = const Email.pure(),
      this.password = const Password.pure(),
      this.confirmPassword = const Password.pure()});

  RegisterFormState copyWith(
          {bool? isPosting,
          bool? isFormPosted,
          bool? isValid,
          FullName? fullName,
          Email? email,
          Password? password,
          Password? confirmPassword}) =>
      RegisterFormState(
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
        fullName: fullName ?? this.fullName,
        email: email ?? this.email,
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
      );

  @override
  String toString() {
    return '''
      RegisterFormSate:
      isPosting: $isPosting
      isFormPosted: $isFormPosted
      isValid: $isValid
      fullName: $fullName
      email: $email
      password: $password
      confirmPassword: $confirmPassword
    ''';
  }
}

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final Function(String, String, String, String) registerUserCallback;

  RegisterFormNotifier({required this.registerUserCallback})
      : super(RegisterFormState());

  onFullNameChange(String value) {
    final newFullName = FullName.dirty(value);
    state = state.copyWith(
        fullName: newFullName,
        isValid: Formz.validate(
            [newFullName, state.email, state.password, state.confirmPassword]));
  }

  onEmailChange(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(
        email: newEmail,
        isValid: Formz.validate(
            [newEmail, state.fullName, state.password, state.confirmPassword]));
  }

  onPasswordChange(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
        password: newPassword,
        isValid: Formz.validate(
            [newPassword, state.fullName, state.email, state.confirmPassword]));
  }

  onConfirmPasswordChange(String value) {
    final newConfirmPassword = Password.dirty(value);
    state = state.copyWith(
        confirmPassword: newConfirmPassword,
        isValid: Formz.validate(
            [newConfirmPassword, state.fullName, state.email, state.password]));
  }

  onFormSubmit() async {
    _touchEveryField();
    if (!state.isValid) return;
    await registerUserCallback(state.fullName.value, state.email.value,
        state.password.value, state.confirmPassword.value);
  }

  _touchEveryField() {
    final fullName = FullName.dirty(state.fullName.value);
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final confirmPassword = Password.dirty(state.confirmPassword.value);
    state = state.copyWith(
        isFormPosted: true,
        fullName: fullName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        isValid: Formz.validate([fullName, email, password, confirmPassword]));
  }
}

final registerFormProvider =
    StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>(
        (ref) {
  final userRegisterCallback = ref.watch(authProvider.notifier).registerUser;
  return RegisterFormNotifier(registerUserCallback: userRegisterCallback);
});
