import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/auth/cubits/authCubit.dart';
import 'package:flutterquiz/features/settings/settingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/ui/widgets/custom_image.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoScaleUpAnimation;
  late Animation<double> _logoScaleDownAnimation;

  bool _systemConfigLoaded = false;

  final _appLogoPath = Assets.splashLogo;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchSystemConfig();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addListener(() {
        if (_logoAnimationController.isCompleted) {
          _navigateToNextScreen();
          // setState(() {});
        }
      });
    _logoScaleUpAnimation = Tween<double>(begin: 0, end: 1.1).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0, 0.4, curve: Curves.ease),
      ),
    );
    _logoScaleDownAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.4, 1, curve: Curves.easeInOut),
      ),
    );

    _logoAnimationController.forward();
  }

  Future<void> _initUnityAds() async {
    await UnityAds.init(
      gameId: context.read<SystemConfigCubit>().unityGameId,
      testMode: true,
      onComplete: () => log('Initialized', name: 'Unity Ads'),
      onFailed: (err, msg) =>
          log('Initialization Failed: $err $msg', name: 'Unity Ads'),
    );
  }

  Future<void> _fetchSystemConfig() async {
    await context.read<SystemConfigCubit>().getSystemConfig();
    await MobileAds.instance.initialize();
  }

  Future<void> _navigateToNextScreen() async {
    if (!_systemConfigLoaded) return;

    await _initUnityAds();

    final showIntroSlider =
        context.read<SettingsCubit>().state.settingsModel!.showIntroSlider;
    final currAuthState = context.read<AuthCubit>().state;

    if (showIntroSlider) {
      await Navigator.of(context).pushReplacementNamed(Routes.introSlider);
      return;
    }

    if (currAuthState is Authenticated) {
      await Navigator.of(context).pushReplacementNamed(
        Routes.bottomnavbar,
        arguments: false,
      );
    } else {
      await Navigator.of(context).pushReplacementNamed(
        Routes.bottomnavbar,
        arguments: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SystemConfigCubit, SystemConfigState>(
      bloc: context.read<SystemConfigCubit>(),
      listener: (context, state) {
        if (state is SystemConfigFetchSuccess) {
          if (!_systemConfigLoaded) {
            _systemConfigLoaded = true;
          }

          if (_logoAnimationController.isCompleted) {
            _navigateToNextScreen();
          }
        }
      },
      builder: (context, state) {
        if (state is SystemConfigFetchFailure) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              key: const Key('errorContainer'),
              child: ErrorContainer(
                showBackButton: true,
                errorMessageColor: Theme.of(context).colorScheme.onTertiary,
                errorMessage: convertErrorCodeToLanguageKey(state.errorCode),
                onTapRetry: () {
                  setState(_initAnimations);
                  _fetchSystemConfig();
                },
                showErrorImage: true,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).primaryColor,
          body: SizedBox.expand(
            child: Stack(
              children: [
                /// App Logo
                Align(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (_, __) => Transform.scale(
                        scale: _logoScaleUpAnimation.value -
                            _logoScaleDownAnimation.value,
                        child: QImage(
                          imageUrl: _appLogoPath,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
