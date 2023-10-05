import 'package:flutter/material.dart';
import 'package:travel_planner/app/presentation/settings/screen/payment_screen.dart';
import 'package:travel_planner/app/presentation/settings/screen/settings.dart';
import 'package:travel_planner/app/router/base_navigator.dart';

class AppOverlays {
  static showExitConfirmationDialog(BuildContext context) async {
    final s = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ExitDialog();
      },
    );

    if (s != null) {
      return s;
    }

    return null;
  }

  static dynamic showDeleteConversationDialog(
    BuildContext context,
  ) async {
    final s = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          titlePadding: const EdgeInsets.only(
            left: 24,
            top: 20,
          ),
          title: const Text(
            "Delete Conversation",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            "This conversation will be deleted. This action is irreversible, are you sure?",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          actions: [
            InkWell(
              overlayColor: const MaterialStatePropertyAll(Colors.transparent),
              onTap: () {
                BaseNavigator.pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              overlayColor: const MaterialStatePropertyAll(Colors.transparent),
              onTap: () async {
                BaseNavigator.pop(true);
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            )
          ],
          actionsPadding: const EdgeInsets.only(
            bottom: 20,
            right: 24,
          ),
        );
      },
    );

    if (s != null) {
      return s;
    }

    return null;
  }

  static dynamic authErrorDialog({
    required BuildContext context,
    String? message,
  }) async {
    final s = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          titlePadding: const EdgeInsets.only(
            left: 24,
            top: 20,
          ),
          title: const Text(
            "Authentication Error",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: Text(
            message ?? "Oops!! Something went wrong",
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          actions: [
            InkWell(
              overlayColor: const MaterialStatePropertyAll(Colors.transparent),
              onTap: () {
                BaseNavigator.pop();
              },
              child: const Text(
                "Ok",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.all(24),
        );
      },
    );

    if (s != null) {
      return s;
    }

    return null;
  }

  static dynamic chatErrorDialog({
    required BuildContext context,
    String? message,
  }) async {
    final s = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          titlePadding: const EdgeInsets.only(
            left: 24,
            top: 20,
          ),
          title: const Text(
            "Error",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: Text(
            message ?? "Oops!! Something went wrong",
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          actions: [
            InkWell(
              overlayColor: const MaterialStatePropertyAll(Colors.transparent),
              onTap: () {
                BaseNavigator.pop();
              },
              child: const Text(
                "Ok",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          actionsPadding: const EdgeInsets.all(24),
        );
      },
    );

    if (s != null) {
      return s;
    }

    return null;
  }

  static dynamic chatPaymentDialog(
    BuildContext context,
  ) async {
    final s = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          titlePadding: const EdgeInsets.only(
            left: 24,
            top: 20,
          ),
          title: const Text(
            "Subscription Required",
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            "You have exhausted your free credits. You need to make payment to continue usage",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 10,
          ),
          actions: [
            InkWell(
              overlayColor: const MaterialStatePropertyAll(Colors.transparent),
              onTap: () {
                BaseNavigator.pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              overlayColor: const MaterialStatePropertyAll(Colors.transparent),
              onTap: () async {
                BaseNavigator.pop(true);
              },
              child: const Text(
                "Continue",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
          actionsPadding: const EdgeInsets.only(
            bottom: 20,
            right: 24,
          ),
        );
      },
    );

    if (s != null) {
      return s;
    }

    return null;
  }
}
