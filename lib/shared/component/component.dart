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

Widget buildTaskItem(Map model) => Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.blue,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '${model['time']}',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("${model['title']}",
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10,
              ),
              Text("${model['date']}",
                  style: const TextStyle(fontSize: 18, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
