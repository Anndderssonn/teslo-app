import 'package:formz/formz.dart';

enum FullNameError { empty, format }

class FullName extends FormzInput<String, FullNameError> {
  const FullName.pure() : super.pure('');
  const FullName.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == FullNameError.empty) return 'This field is required';
    if (displayError == FullNameError.format) return 'Minimum 3 characters';
    return null;
  }

  @override
  FullNameError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return FullNameError.empty;
    if (value.length <= 3) return FullNameError.format;
    return null;
  }
}
