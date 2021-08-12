import 'package:daily_log/HomePage.dart';
import 'package:daily_log/api/ApiService.dart';
import 'package:daily_log/model/Pengguna.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputField extends StatefulWidget {
  const InputField({Key? key}) : super(key: key);

  @override
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                          hintText: "Username",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Container(
                    child: TextFormField(
                      obscureText: true,
                      controller: _passwordController,
                      decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  )
                ],
              ),
            ),
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
            onPressed: () async {
              final sharedPreferences = await SharedPreferences.getInstance();
              Pengguna pengguna = Pengguna(
                  id: 1,
                  username: _usernameController.text.trim(),
                  password: _passwordController.text.trim(),
                  jabatan: 'staff');
              Pengguna api = await ApiService().login(pengguna);
              if (_usernameController.text.trim() == api.username) {
                sharedPreferences.setString("username", api.username);
                sharedPreferences.setBool("isLogin", true);
                sharedPreferences.setString("jabatan", api.jabatan);
                sharedPreferences.setInt("id_user", api.id);
                sharedPreferences.setBool("is_checkin", false);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              }
            },
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
