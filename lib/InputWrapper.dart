import 'package:daily_log/InputField.dart';
import 'package:flutter/material.dart';

class InputWrapper extends StatelessWidget {
  const InputWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 48,
          ),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: InputField(),
          ),
          SizedBox(
            height: 8,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              child: Text(
                "Lupa password?",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.end,
              ),
            ),
          ),
          SizedBox(
            height: 16,
          ),
          MaterialButton(
            onPressed: () => {},
            height: 56,
            minWidth: 96,
            color: Colors.blue,
            textColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Text(
              "LOGIN",
              style: TextStyle(fontSize: 14),
            ),
          )
        ],
      ),
    );
  }
}
