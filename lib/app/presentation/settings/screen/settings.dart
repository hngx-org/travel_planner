import 'package:flutter/material.dart';
import 'package:hng_authentication/authentication.dart';
import 'package:travel_planner/app/presentation/authentication/screens/sign_in.dart';
import 'package:travel_planner/app/presentation/settings/screen/edit_profile.dart';
import 'package:travel_planner/app/presentation/settings/screen/payment_screen.dart';
import 'package:travel_planner/app/router/base_navigator.dart';
import 'package:travel_planner/component/overlays/dialogs.dart';
import 'package:travel_planner/component/overlays/loader.dart';
import 'package:travel_planner/data/model/auth/auth_base_response.dart';
import 'package:travel_planner/data/model/auth/user.dart';
import 'package:travel_planner/main.dart';
import 'package:travel_planner/services/local_storage/shared_prefs.dart';
import 'package:travel_planner/services/local_storage/sqflite/sqflite_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final storage = AppStorage.instance;
  final auth = Authentication();
  final sqlDb = SqfLiteService.instance;

  ValueNotifier isLoading = ValueNotifier(false);

  late User user;

  getUser() async {
    try {
      final result = await auth.getUser(storage.getToken());
      if (result != null) {
        final response = AuthBaseResponse.fromJson(result["response"]);
        if (response.error == null) {
          final dbUser = User.fromJson(response.data);
          if (result["headers"] != null) {
            final headers = result["headers"];
            final headerString = headers["set-cookie"] as String;
            if (headers["set-cookie"] != null) {
              storage.saveUserToken(headerString.substring(0, headerString.indexOf(";")));
            }
          }
          storage.saveUser(dbUser.toJson());
          user = dbUser;
          setState(() {});
        }
      }
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    final storeUser = storage.getUserData();
    if (storeUser != null) {
      user = storeUser;
    } else {
      user = User(
        name: "Test planner",
        email: "example@test.com",
        credits: 2,
      );
    }
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, value, _) {
          return Stack(
            children: [
              Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 70,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 35,
                            child: Icon(
                              Icons.person,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name?.replaceAll("_", " ") ?? "",
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(user.email ?? ""),
                              const SizedBox(height: 5),
                              Text(
                                "${user.credits} credits",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 32.0),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Edit Profile'),
                        contentPadding: EdgeInsets.zero,
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                        onTap: () {
                          BaseNavigator.pushNamed(EditProfile.routeName);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.payment),
                        title: const Text('Payment'),
                        contentPadding: EdgeInsets.zero,
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                        onTap: () {
                          BaseNavigator.pushNamed(
                            PaymentScreen.routeName,
                            args: user.id,
                          );
                          // showModalBottomSheet(
                          //     context: context,
                          //     builder: (context) {
                          //       return const SelectPaymentType();
                          //     });
                        },
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () async {
                          final result = await _showLogoutConfirmationDialog(context);
                          if (!mounted) return;
                          if (result == true) {
                            try {
                              isLoading.value = true;
                              navigationIconLoading = true;
                              setState(() {});
                              final result = await auth.logout(user.email!);
                              final response = AuthBaseResponse.fromJson(result);
                              if (response.error != null) {
                                isLoading.value = false;
                                navigationIconLoading = false;
                                setState(() {});
                                if (mounted) {
                                  AppOverlays.authErrorDialog(
                                    context: context,
                                    message: response.message,
                                  );
                                }
                              } else {
                                if (response.message?.toLowerCase() == "success") {
                                  storage.clearToken();
                                  isLoading.value = false;
                                  navigationIconLoading = false;
                                  setState(() {});
                                  BaseNavigator.pushNamedAndclear(SignInScreen.routeName);
                                }
                              }
                            } catch (e) {
                              isLoading.value = false;
                              navigationIconLoading = false;
                              setState(() {});
                              if (mounted) {
                                AppOverlays.authErrorDialog(
                                  context: context,
                                  message: e.toString(),
                                );
                              }
                            }
                          }
                        },
                        overlayColor: const MaterialStatePropertyAll(Colors.transparent),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Log out",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
              if (value) const Loader()
            ],
          );
        });
  }

  _showLogoutConfirmationDialog(BuildContext context) async {
    final s = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const LogoutDialog();
      },
    );

    if (s != null) {
      return s;
    }

    return null;
  }
}

// class SelectPaymentType extends StatelessWidget {
//   const SelectPaymentType({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           const Text(
//             'Select Payment Method',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 20),
//           ListTile(
//             leading: const Icon(Icons.payment),
//             title: const Text('Google Pay'),
//             onTap: () {
//               Navigator.pop(context); // Close the modal sheet
//               // Navigate to the payment screen with Google Pay selected
//               Navigator.pushNamed(context, '/payment', arguments: 'Google Pay');
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.payment),
//             title: const Text('Apple Pay'),
//             onTap: () {
//               Navigator.pop(context); // Close the modal sheet
//               // Navigate to the payment screen with Apple Pay selected
//               Navigator.pushNamed(context, '/payment', arguments: 'Apple Pay');
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

class ExitDialog extends StatelessWidget {
  const ExitDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: Text(
        'Are you sure you want to exit the app?',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      )),
      content: const Text(
        " Stay a while longer and continue your journey of discovery with us!",
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            BaseNavigator.pop(false);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            BaseNavigator.pop(true);
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
          child: Text(
        'Are you sure you want to logout?',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      )),
      content: const Text(
        " Stay a while longer and continue your journey of discovery with us!",
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            BaseNavigator.pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            BaseNavigator.pop(true);
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
