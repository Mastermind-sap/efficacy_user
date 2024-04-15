import 'package:efficacy_user/config/config.dart';
import 'package:efficacy_user/controllers/services/user/user_controller.dart';
import 'package:efficacy_user/dialogs/loading_overlay/loading_overlay.dart';
import 'package:efficacy_user/models/user/user_model.dart';
import 'package:efficacy_user/pages/forgot_password/forgot_password.dart';
import 'package:efficacy_user/pages/homepage/homepage.dart';
import 'package:efficacy_user/pages/signup/signup_page.dart';
import 'package:efficacy_user/utils/validator.dart';
import 'package:efficacy_user/widgets/custom_text_field/custom_text_field.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool hidePassword = true;
  IconData passVisibility = Icons.visibility;

  @override
  Widget build(BuildContext context) {
    //screen height and width
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    //size constants
    double fieldGap = height * 0.005;
    double smallGap = height * 0.01;
    double formWidth = width * 0.8;
    double fieldHeight = height * 0.075 + 8;

    return Column(
      children: [
        Form(
            key: _formKey,
            child: SizedBox(
              width: formWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: "Email",
                    height: fieldHeight,
                    controller: _emailController,
                    validator: Validator.isEmailValid,
                    prefixIcon: Icons.email,
                  ),
                  CustomTextField(
                    label: "Password",
                    height: fieldHeight,
                    controller: _passController,
                    hiddenText: hidePassword,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) => Validator.isPasswordValid(value),
                    suffixIcon: IconButton(
                        onPressed: () {
                          if (passVisibility == Icons.visibility) {
                            setState(() {
                              passVisibility = Icons.visibility_off;
                              hidePassword = false;
                            });
                          } else {
                            setState(() {
                              passVisibility = Icons.visibility;
                              hidePassword = true;
                            });
                          }
                        },
                        icon: Icon(
                          passVisibility,
                          color: const Color.fromARGB(255, 67, 67, 67),
                        )),
                    prefixIcon: Icons.lock,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, ForgotPasswordPage.routeName);
                      },
                      child: Text(
                        "Forgot password?",
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              decoration: TextDecoration.underline,
                              color: dark,
                              decorationColor: dark,
                            ),
                      ),
                    ),
                  ),
                  Container(
                    width: width,
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          UserModel? user;
                          showLoadingOverlay(
                            context: context,
                            asyncTask: () async {
                              user = await UserController.login(
                                email: _emailController.text.toString(),
                                password: _passController.text.toString(),
                              );
                            },
                            onCompleted: () {
                              if (user != null && mounted) {
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  Homepage.routeName,
                                  (_) => false,
                                );
                              }
                            },
                          );
                        }
                      },
                      child: const Text("Login"),
                    ),
                  ),
                ].separate(fieldGap * 0.5),
              ),
            )),
        // Toggle button to signup page
        TextButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              SignUpPage.routeName,
              (Route<dynamic> route) => false,
            );
          },
          child: RichText(
            text: const TextSpan(
                text: "Don't have an account? ",
                children: [
                  TextSpan(
                      text: "Sign Up",
                      style: TextStyle(
                          color: dark, decoration: TextDecoration.underline))
                ],
                style: TextStyle(color: shadow)),
          ),
        ),
      ].separate(smallGap),
    );
  }
}
