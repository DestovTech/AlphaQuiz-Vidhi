import 'package:flutter/material.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return QImage(
      imageUrl: Assets.icLauncher,
      color: Theme.of(context).primaryColor,
      height: 100,
      width: 100,
    );
  }
}
