
import 'package:flutter/material.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/ui/screens/quiz/widgets/instructionBottomSheetContainer.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class CommonUtils {

  static void showMessageBottomSheet(BuildContext context, String message, Widget icon1, Widget icon2, [String? contactNumber]) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              CustomRoundedButton(
                widthPercentage: 0.375,
                backgroundColor: Theme.of(context).colorScheme.background,
                buttonTitle: context.tr(retryLbl),
                radius: 5,
                showBorder: false,
                height: 40,
                titleColor: Theme.of(context).colorScheme.onTertiary,
                elevation: 5,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      launchPhoneDialer(contactNumber!);
                      Navigator.of(context).pop();
                    },
                    child: icon1,
                  ),
                  const SizedBox(width: 20), // Adjust the spacing between the images
                  GestureDetector(
                    onTap: () {
                      launchWhatsApp(contactNumber!); // Launch WhatsApp with the specified phone number
                      Navigator.of(context).pop();
                    },
                    child: icon2,
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static void launchWhatsApp(String phoneNumber) async {
    String countryCode = "+91"; // Replace with the appropriate country code
    String whatsappUrl = "https://wa.me/$countryCode$phoneNumber";
    Uri uri = Uri.parse(whatsappUrl); // Convert the String to a Uri object
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch WhatsApp.';
    }
  }

  static void launchPhoneDialer(String phoneNumber) async {
    if (await Permission.phone.request().isGranted) {
      String phoneUrl = "tel:$phoneNumber";
      Uri uri = Uri.parse(phoneUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch phone dialer.';
      }
    }
  }

  static void showInstructionBottomSheet({
    required BuildContext context,
    required ContestDetails contest,
    required bool isPlayNowBtn,
    bool isInstructionBtn = false,
  }) {
    showModalBottomSheet<void>(
      isDismissible: false,
      isScrollControlled: true,
      elevation: 5,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: UiUtils.bottomSheetTopRadius,
      ),
      builder: (_) => InstructionBottomSheetContainer(context: context, contest: contest, isPlayNowBtn: isPlayNowBtn, isInstructionBtn: isInstructionBtn),
    );
  }
}
