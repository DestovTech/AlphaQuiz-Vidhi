import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/common_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';

class ErrorContainer extends StatelessWidget {
  const ErrorContainer({
    required this.errorMessage,
    required this.onTapRetry,
    required this.showErrorImage,
    super.key,
    this.errorMessageColor,
    this.topMargin = 0.1,
    this.showBackButton,
    this.showRTryButton = true,
    this.showConnectToAdminOption = false,
    this.contactNumber = '1234567890',
  });

  final String errorMessage;
  final Function onTapRetry;
  final bool showErrorImage;
  final bool showRTryButton;
  final double topMargin;
  final Color? errorMessageColor;
  final bool? showBackButton;
  final bool? showConnectToAdminOption;
  final String contactNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.only(top: MediaQuery.of(context).size.height * topMargin),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showErrorImage) ...[
            SvgPicture.asset(
              Assets.error,
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 25),
          ],
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${context.tr(errorMessage) ?? errorMessage} :(',
              style: TextStyle(
                fontSize: 18,
                color: errorMessageColor ??
                    Theme.of(context).colorScheme.onTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 25),
          if (showRTryButton)
            CustomRoundedButton(
              widthPercentage: 0.375,
              backgroundColor: Theme.of(context).colorScheme.background,
              buttonTitle: context.tr(retryLbl),
              radius: 5,
              showBorder: false,
              height: 40,
              titleColor: Theme.of(context).colorScheme.onTertiary,
              elevation: 5,
              onTap: onTapRetry as VoidCallback,
            )
          else
            const SizedBox(),
          const SizedBox(height: 26),
          if (showConnectToAdminOption!)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    CommonUtils.launchPhoneDialer(contactNumber);
                  },
                  child: Image.asset(
                    Assets.contactPhoneIcon,
                    width: 42,
                    height: 42,
                  ),
                ),
                const SizedBox(width: 20),
                // Adjust the spacing between the images
                GestureDetector(
                  onTap: () {
                    CommonUtils.launchWhatsApp(contactNumber);
                  },
                  child: Image.asset(
                    Assets.contactWhatsappIcon,
                    width: 42,
                    height: 42,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
