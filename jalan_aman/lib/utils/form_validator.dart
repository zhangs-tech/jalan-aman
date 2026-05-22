String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your name';
  } else {
    return null;
  }
}

String? validateEmail(String? value) {
  RegExp regex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  if (value == null || value.isEmpty) {
    return 'Please enter an email';
  } else if (!regex.hasMatch(value)) {
    return 'Please enter a valid email';
  } else {
    return null;
  }
}

String? validatePhone(String? value) {
  RegExp regex = RegExp(r'^(?:\+62|62|0)8[1-9][0-9]{6,10}$');

  if (value == null || value.isEmpty) {
    return 'Please enter the phone number';
  } else if (!regex.hasMatch(value)) {
    return 'Please enter a valid phone number';
  } else {
    return null;
  }
}

String? validatePassword(String? value) {
  RegExp regex = RegExp(
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$',
  );

  if (value == null || value.isEmpty) {
    return 'Please enter password';
  } else if (!regex.hasMatch(value)) {
    return 'Password must meet the required criteria.';
  } else {
    return null;
  }
}
