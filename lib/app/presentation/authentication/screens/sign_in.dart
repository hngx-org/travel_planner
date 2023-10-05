import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hng_authentication/authentication.dart';
import 'package:travel_planner/app/presentation/authentication/screens/sign_up.dart';
import 'package:travel_planner/app/presentation/authentication/widgets/button.dart';
import 'package:travel_planner/app/presentation/navigation.dart';
import 'package:travel_planner/app/router/base_navigator.dart';
import 'package:travel_planner/component/overlays/dialogs.dart';
import 'package:travel_planner/component/overlays/loader.dart';
import 'package:travel_planner/data/model/auth/auth_base_response.dart';
import 'package:travel_planner/data/model/auth/user.dart';
import 'package:travel_planner/services/local_storage/shared_prefs.dart';
import 'package:travel_planner/services/local_storage/sqflite/sqflite_service.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = "sign_in";
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final TextEditingController _userEmail;
  late final TextEditingController _userPassword;

  final sqlDb = SqfLiteService.instance;

  bool obscurePassword = true;
  // String? emailErrorText;
  // String? passwordErrorText;

  Icon passwordVisibilityIcon = const Icon(
    Icons.visibility,
  );

  ValueNotifier isLoading = ValueNotifier(false);

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final auth = Authentication();
  final storage = AppStorage.instance;

  bool validateEmail({required String email}) {
    return ((email.contains('@') &&
            email.contains('.') &&
            (email.substring(email.length - 1) != '.' &&
                email.substring(
                      email.length - 1,
                    ) !=
                    '@'))) ||
        email.isEmpty;
  }

  Function setPasswordVisibility({required bool obscureText}) {
    return () {
      obscureText = !obscureText;
      return obscureText ? Icons.visibility : Icons.visibility_off;
    };
  }

  bool get isLastPage => ModalRoute.of(context)!.isFirst;

  void closeAppUsingExit() {
    exit(0);
  }

  @override
  void initState() {
    final user = storage.getUserData();
    _userEmail = TextEditingController(text: user?.email ?? "");
    _userPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _userEmail.dispose();
    _userPassword.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isLastPage != false) {
          final s = await AppOverlays.showExitConfirmationDialog(context);
          if (mounted) {
            if (s) {
              closeAppUsingExit();
            }
          }
          return false;
        }
        return false;
      },
      child: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, value, _) {
          return Stack(
            children: [
              Scaffold(
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Hi There! 👋",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "Gain secure access to your account",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              "Email",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextFormField(
                              focusNode: _emailFocus,
                              onEditingComplete: () {
                                _passwordFocus.requestFocus();
                              },
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              controller: _userEmail,
                              onChanged: (_) {
                                setState(() {});
                              },
                              onTapOutside: (event) {
                                FocusScope.of(context).unfocus();
                              },
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your email";
                                }

                                if (!validateEmail(email: value)) {
                                  return "Enter a valid email";
                                }

                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'example@whatevermail.com',
                                prefixIcon: const Icon(
                                  Icons.mail,
                                  size: 20,
                                ),
                                prefixIconColor: Theme.of(context).colorScheme.onBackground,
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                ),
                                //  errorText: emailErrorText,
                              ),
                            ),
                            const SizedBox(
                              height: 12.0,
                            ),
                            const Text(
                              "Password",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextFormField(
                              focusNode: _passwordFocus,
                              obscureText: obscurePassword,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: _userPassword,
                              onChanged: (_) {
                                setState(() {});
                              },
                              onTapOutside: (event) {
                                FocusScope.of(context).unfocus();
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your password";
                                }

                                if (value.contains(" ")) {
                                  return "Password must not contain whitespaces";
                                }

                                if (value.trim().length < 8) {
                                  return "Password must be at least 8 characters";
                                }
                                return null;
                              },
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              decoration: InputDecoration(
                                //errorText: passwordErrorText,
                                hintText: 'password',
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  size: 20,
                                ),
                                prefixIconColor: Theme.of(context).colorScheme.onBackground,
                                suffixIconColor: Theme.of(context).colorScheme.onBackground,
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      final toggleVisibility = setPasswordVisibility(obscureText: obscurePassword);
                                      obscurePassword = !obscurePassword;
                                      final newIconData = toggleVisibility();
                                      passwordVisibilityIcon = Icon(newIconData);
                                    });
                                  },
                                  icon: passwordVisibilityIcon,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            CustomButton(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    isLoading.value = true;
                                    final result = await auth.signIn(
                                      _userEmail.text.trim(),
                                      _userPassword.text.trim(),
                                    );
                                    if (result != null) {
                                      final response = AuthBaseResponse.fromJson(result["response"]);
                                      if (response.error != null) {
                                        isLoading.value = false;
                                        if (mounted) {
                                          AppOverlays.authErrorDialog(
                                            context: context,
                                            message: response.message,
                                          );
                                        }
                                      } else {
                                        final user = User.fromJson(response.data);
                                        final storeUser = storage.getUserData();
                                        if (storeUser != null) {
                                          if (user.id != storeUser.id) {
                                            sqlDb.deleteDb();
                                            storage.clearToken();
                                          }
                                        }
                                        if (result["headers"] != null) {
                                          final headers = result["headers"];
                                          final headerString = headers["set-cookie"] as String;
                                          if (headers["set-cookie"] != null) {
                                            storage.saveUserToken(headerString.substring(0, headerString.indexOf(";")));
                                          }
                                        }
                                        storage.saveUser(user.toJson());
                                        isLoading.value = false;
                                        BaseNavigator.pushNamedAndclear(Navigation.routeName);
                                      }
                                    } else {
                                      isLoading.value = false;
                                      if (mounted) {
                                        AppOverlays.authErrorDialog(
                                          context: context,
                                        );
                                      }
                                    }
                                  } catch (e) {
                                    isLoading.value = false;
                                    if (mounted) {
                                      AppOverlays.authErrorDialog(
                                        context: context,
                                        message: e.toString(),
                                      );
                                    }
                                  }
                                }
                              },
                              title: 'Sign In',
                            ),
                            const SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Don't have an account?"),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    BaseNavigator.pushNamedAndReplace(SignUpScreen.routeName);
                                  },
                                  child: Text(
                                    "Sign up Here",
                                    style: TextStyle(color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (value) const Loader()
            ],
          );
        },
      ),
    );
  }
}
