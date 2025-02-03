import 'package:flutter/material.dart';

TextFormField buildTextFormField({
  required screenWidth,
  required String hint,
  required String? Function(String?) validator,
  var suffixIcon,
  var prefixIcon,
  TextInputType keyboardType = TextInputType.text,
  bool isObsecure = false,
  required TextEditingController controller,
}) {
  return TextFormField(
    keyboardType: keyboardType,
    validator: validator,
    controller: controller,
    obscureText: isObsecure,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          fontSize: screenWidth * 0.032,
          fontWeight: FontWeight.w700,
          color: Color(0XFF8B8B8B),
          fontFamily: 'Inter'),
      errorStyle: TextStyle(fontSize: screenWidth * 0.032, fontWeight: FontWeight.w400),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Color(0XFF787878),
            width: 1,
          )),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Color(0XFF787878),
            width: 1,
          )),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          )),
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
    ),
  );
}
