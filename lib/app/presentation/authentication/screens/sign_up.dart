import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hng_authentication/authentication.dart';
import 'package:travel_planner/app/presentation/authentication/screens/sign_in.dart';
import 'package:travel_planner/app/presentation/authentication/widgets/button.dart';
import 'package:travel_planner/app/presentation/navigation.dart';
import 'package:travel_planner/app/router/base_navigator.dart';
import 'package:travel_planner/component/overlays/dialogs.dart';
import 'package:travel_planner/component/overlays/loader.dart';
import 'package:travel_planner/data/model/auth/auth_base_response.dart';
import 'package:travel_planner/data/model/auth/user.dart';
import 'package:travel_planner/services/local_storage/shared_prefs.dart';
import 'package:travel_planner/services/local_storage/sqflite/sqflite_service.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = "sign_up";
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController _userEmail;
  late final TextEditingController _userPassword;
  late final TextEditingController _username;
  late final TextEditingController _userPasswordConfirmation;

  bool obscurePassword = true;
  bool obscurePasswordConfirmation = true;

  // String? emailErrorText;
  // String? passwordErrorText;
  // String? confirmPasswordErrorText;
  // String? nameErrorText;

  Icon passwordVisibilityIcon = const Icon(Icons.visibility);
  Icon confirmPasswordVisibilityIcon = const Icon(Icons.visibility);

  bool passwordsMatch = true;

  final auth = Authentication();
  final storage = AppStorage.instance;

  final sqlDb = SqfLiteService.instance;

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();

  ValueNotifier isLoading = ValueNotifier(false);

  final _formKey = GlobalKey<FormState>();

  bool get isLastPage => ModalRoute.of(context)!.isFirst;

  void closeAppUsingExit() {
    exit(0);
  }

  bool validateEmail({required String email}) {
    return ((email.contains('@') && email.contains('.') && (email.substring(email.length - 1) != '.' && email.substring(email.length - 1) != '@'))) ||
        email.isEmpty;
  }

  bool checkPasswordLength(String password) {
    return password.length >= 8 || password.isEmpty;
  }

  Function setPasswordVisibility({required bool obscureText}) {
    return () {
      obscureText = !obscureText;
      return obscureText ? Icons.visibility : Icons.visibility_off;
    };
  }

  bool checkPasswordsMatch({
    required String password,
    required String passwordConfirmation,
  }) {
    return password == passwordConfirmation || passwordConfirmation.isEmpty;
  }

  @override
  void initState() {
    _userEmail = TextEditingController();
    _userPassword = TextEditingController();
    _username = TextEditingController();
    _userPasswordConfirmation = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _userEmail.dispose();
    _userPassword.dispose();
    _username.dispose();
    _userPasswordConfirmation.dispose();

    _usernameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
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
                backgroundColor: Theme.of(context).colorScheme.background,
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            const Text(
                              "Create your Account 😁",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              "Create a secure account with us",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 40),
                            const Text(
                              "Full name",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextFormField(
                              focusNode: _usernameFocus,
                              onEditingComplete: () {
                                _emailFocus.requestFocus();
                              },
                              enableSuggestions: false,
                              autocorrect: false,
                              keyboardType: TextInputType.name,
                              controller: _username,
                              onChanged: (_) {
                                setState(() {});
                              },
                              onTapOutside: (event) {
                                FocusScope.of(context).unfocus();
                              },
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Please enter your full name";
                                }

                                if (value.length < 2) {
                                  return "Name must be a minimum of 2 letters";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Mr travel planner',
                                prefixIcon: const Icon(
                                  Icons.person,
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
                                //errorText: nameErrorText,
                              ),
                            ),
                            const SizedBox(height: 12.0),
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
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              keyboardType: TextInputType.emailAddress,
                              controller: _userEmail,
                              onTapOutside: (event) {
                                FocusScope.of(context).unfocus();
                              },
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
                                // errorText: emailErrorText,
                              ),
                            ),
                            const SizedBox(height: 12.0),
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
                              onEditingComplete: () {
                                _confirmPasswordFocus.requestFocus();
                              },
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: _userPassword,
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
                                //  errorText: passwordErrorText,
                                hintText: 'min. 8 characters',
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
                            const SizedBox(
                              height: 12.0,
                            ),
                            const Text(
                              "Confirm Password",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextFormField(
                              focusNode: _confirmPasswordFocus,
                              obscureText: obscurePasswordConfirmation,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: _userPasswordConfirmation,
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

                                if (_userPassword.text != value) {
                                  return "! Password Mismatch";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
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
                                      final toggleConfirmVisibility = setPasswordVisibility(obscureText: obscurePasswordConfirmation);
                                      obscurePasswordConfirmation = !obscurePasswordConfirmation;
                                      final newIconData = toggleConfirmVisibility();
                                      confirmPasswordVisibilityIcon = Icon(newIconData);
                                    });
                                  },
                                  icon: confirmPasswordVisibilityIcon,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            CustomButton(
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    isLoading.value = true;
                                    final result = await auth.signUp(
                                      _userEmail.text.trim(),
                                      _username.text.replaceAll(" ", "_"),
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
                                  } on ApiException catch (e) {
                                    isLoading.value = false;
                                    if (mounted) {
                                      AppOverlays.authErrorDialog(
                                        context: context,
                                        message: e.message,
                                      );
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
                              title: "Sign up",
                            ),
                            const SizedBox(height: 15.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Already have an account?'),
                                const SizedBox(
                                  width: 5.0,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    BaseNavigator.pushNamedAndReplace(SignInScreen.routeName);
                                  },
                                  child: Text(
                                    "Login Here",
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
