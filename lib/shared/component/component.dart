import 'package:flutter/material.dart';

Widget textForm({
  bool autoFocus = false,
  TextInputType? keyboardType,
  required String text,
  bool isPassword = false,
  bool ifPrefix = false,
  bool suffix = false,
  void Function()? onTap,
  Widget? prefix,
  TextEditingController? controller,
  String errorMessage = "It's empty",
}) =>
    TextFormField(
      cursorColor: const Color(0xffefa803),
      style: const TextStyle(color: Colors.black),
      autofocus: autoFocus,
      controller: controller,
      keyboardType: keyboardType,
      validator: (String? value) {
        if (value!.isEmpty) {
          return errorMessage;
        }
        return null;
      },
      onTap: onTap,
      decoration: InputDecoration(
          // fillColor: const Color(0xff292929),
          // filled: true,
          labelText: text,
          labelStyle: const TextStyle(
            color: Colors.black,
          ),
          prefixIcon: prefix,
          suffixIcon: suffix
              ? isPassword
                  ? IconButton(
                      onPressed: () {
                        isPassword = true;
                      },
                      icon: const Icon(
                        Icons.visibility_outlined,
                        color: Colors.black,
                      ),
                    )
                  : IconButton(
                      onPressed: () {
                        isPassword = false;
                      },
                      icon: const Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.black,
                      ),
                    )
              : null,
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Color(0xffefa803),
          ))),
    );

