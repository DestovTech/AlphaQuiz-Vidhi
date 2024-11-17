import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutterquiz/features/systemConfig/cubits/appSettingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/system_config_repository.dart';
import 'package:flutterquiz/ui/widgets/customAppbar.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/common_utils.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/string_labels.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({required this.title, super.key});

  final String title;

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();

  static Route<ContactUsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<AppSettingsCubit>(
        create: (_) => AppSettingsCubit(SystemConfigRepository()),
        child: ContactUsScreen(title: routeSettings.arguments! as String),
      ),
    );
  }
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  late final _screenTitle = context.tr(widget.title)!;
  late String contactInformation = 'Contact information';
  late String contactNumber = '1234567890';

  late final _settingType = switch (widget.title) {
    aboutUs => 'about_us',
    privacyPolicy => 'privacy_policy',
    termsAndConditions => 'terms_conditions',
    contactUs => 'contact_us',
    howToPlayLbl => 'instructions',
    _ => '',
  };

  @override
  void initState() {
    super.initState();
    fetchAppSetting();
  }

  void fetchAppSetting() {
    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().getAppSetting(_settingType);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: QAppBar(title: Text(_screenTitle)),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        bloc: context.read<AppSettingsCubit>(),
        builder: (context, state) {
          if (state is AppSettingsFetchSuccess) {
              contactInformation = state.settingsData;
              contactInformation = contactInformation.replaceAll(RegExp('</?p>'), '');
              final regex = RegExp(r'\b\d{10}\b');
              final Match? match = regex.firstMatch(contactInformation);
              final mobileNumber = match?.group(0);
              contactNumber = mobileNumber!;
          }
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: size.height * UiUtils.vtMarginPct,
              horizontal: size.width * UiUtils.hzMarginPct + 10,
            ),
            child: Column(
              children: [
                 Text(
                  contactInformation,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      child: Image.asset(
                        Assets.contactPhoneIcon,
                        width: 42,
                        height: 42,
                      ),
                      onTap: () {
                        CommonUtils.launchPhoneDialer(contactNumber);
                      },
                    ),
                    const SizedBox(width: 20),
                    // Adjust the spacing between the images
                    GestureDetector(
                      child: Image.asset(
                        Assets.contactWhatsappIcon,
                        width: 42,
                        height: 42,
                      ),
                      onTap: () {
                        CommonUtils.launchWhatsApp(contactNumber);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

