import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/ads/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/rewarded_ad_cubit.dart';
import 'package:flutterquiz/features/auth/authRepository.dart';
import 'package:flutterquiz/features/auth/cubits/referAndEarnCubit.dart';
import 'package:flutterquiz/features/badges/cubits/badgesCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/battleRoomCubit.dart';
import 'package:flutterquiz/features/battleRoom/cubits/multiUserBattleRoomCubit.dart';
import 'package:flutterquiz/features/exam/cubits/examCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementLocalDataSource.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quizzone_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subCategoryCubit.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/features/systemConfig/cubits/appSettingsCubit.dart';
import 'package:flutterquiz/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:flutterquiz/features/systemConfig/system_config_repository.dart';
import 'package:flutterquiz/ui/screens/battle/create_or_join_screen.dart';
import 'package:flutterquiz/ui/screens/home/widgets/all.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/common_utils.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/Image_data.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.isGuest, super.key});

  final bool isGuest;

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static Route<HomeScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ReferAndEarnCubit>(
            create: (_) => ReferAndEarnCubit(AuthRepository()),
          ),
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
          BlocProvider<AppSettingsCubit>(
            create: (_) => AppSettingsCubit(SystemConfigRepository()),
          ),
        ],
        child: HomeScreen(isGuest: routeSettings.arguments! as bool),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  // final List<Widget> _pages = [
  //   Center(child: Text('Home Page')),
  //   Center(child: Text('My Quiz Page')),
  //   Center(child: Text('My Contest Page')),
  //   Center(child: Text('Leaderboard Page')),
  // ];
  late TabController _tabController;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Quiz Zone globals
  int oldCategoriesToShowCount = 0;
  bool isCateListExpanded = false;
  bool canExpandCategoryList = false;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  List<String> battleName = ['groupPlay', 'battleQuiz'];

  List<String> battleImg = [Assets.groupBattleIcon, Assets.oneVsOneIcon];

  List<String> examSelf = ['exam', 'selfChallenge'];

  List<String> examSelfDesc = ['desExam', 'challengeYourselfLbl'];

  List<String> examSelfImg = [Assets.examQuizIcon, Assets.selfChallengeIcon];

  List<String> battleDesc = ['desGroupPlay', 'desBattleQuiz'];

  List<String> playDifferentZone = [
    'dailyQuiz',
    'funAndLearn',
    'guessTheWord',
    'audioQuestions',
    'mathMania',
    'truefalse',
  ];

  List<String> playDifferentImg = [
    Assets.dailyQuizIcon,
    Assets.funNLearnIcon,
    Assets.guessTheWordIcon,
    Assets.audioQuizIcon,
    Assets.mathsQuizIcon,
    Assets.trueFalseQuizIcon,
  ];

  List<String> playDifferentZoneDesc = [
    'desDailyQuiz',
    'desFunAndLearn',
    'desGuessTheWord',
    'desAudioQuestions',
    'desMathMania',
    'desTrueFalse',
  ];

  // Screen dimensions
  double get scrWidth => MediaQuery.of(context).size.width;

  double get scrHeight => MediaQuery.of(context).size.height;

  // HomeScreen horizontal margin, change from here
  double get hzMargin => scrWidth * UiUtils.hzMarginPct;

  double get _statusBarPadding => MediaQuery.of(context).padding.top;

  // TextStyles
  // check build() method
  late var _boldTextStyle = TextStyle(
    fontWeight: FontWeights.bold,
    fontSize: 18,
    color: Theme.of(context).colorScheme.onTertiary,
  );

  ///
  late String _currLangId;
  late final SystemConfigCubit _sysConfigCubit;
  final _quizZoneId =
      UiUtils.getCategoryTypeNumberFromQuizType(QuizTypes.quizZone);

  @override
  void initState() {
    super.initState();
    showAppUnderMaintenanceDialog();
    setQuizMenu();
    _initLocalNotification();
    checkForUpdates();
    setupInteractedMessage();
    fetchAppSetting();
    _tabController = TabController(length: 2, vsync: this);

    /// Create Ads
    Future.delayed(Duration.zero, () async {
      await context.read<RewardedAdCubit>().createDailyRewardAd(context);
      context.read<InterstitialAdCubit>().createInterstitialAd(context);
    });

    WidgetsBinding.instance.addObserver(this);

    ///
    _currLangId = UiUtils.getCurrentQuestionLanguageId(context);
    _sysConfigCubit = context.read<SystemConfigCubit>();
    final quizCubit = context.read<QuizCategoryCubit>();
    final quizZoneCubit = context.read<QuizoneCategoryCubit>();

    if (widget.isGuest) {
      quizCubit.getQuizCategory(languageId: _currLangId, type: _quizZoneId);
      quizZoneCubit.getQuizCategory(languageId: _currLangId);
    } else {
      fetchUserDetails();

      quizCubit.getQuizCategoryWithUserId(
        languageId: _currLangId,
        type: _quizZoneId,
      );
      quizZoneCubit.getQuizCategoryWithUserId(languageId: _currLangId);
      context.read<ContestCubit>().getContest(languageId: _currLangId);
    }
  }


  void fetchAppSetting() {
    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().getAppSetting('contact_us');
    });
  }

  void showAppUnderMaintenanceDialog() {
    Future.delayed(Duration.zero, () {
      if (_sysConfigCubit.isAppUnderMaintenance) {
        showDialog<void>(
          context: context,
          builder: (_) => const AppUnderMaintenanceDialog(),
        );
      }
    });
  }

  Future<void> _initLocalNotification() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsIOS = DarwinInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payLoad) {
        log('For ios version <= 9 notification will be shown here');
      },
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onTapLocalNotification,
    );

    /// Request Permissions for IOS
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions();
    }
  }

  void setQuizMenu() {
    Future.delayed(Duration.zero, () {
      if (!_sysConfigCubit.isDailyQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == 'dailyQuiz');
        playDifferentImg.removeWhere((e) => e == Assets.dailyQuizIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desDailyQuiz');
      }

      if (!_sysConfigCubit.isTrueFalseQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == 'truefalse');
        playDifferentImg.removeWhere((e) => e == Assets.trueFalseQuizIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desTrueFalse');
      }

      if (!_sysConfigCubit.isFunNLearnEnabled) {
        playDifferentZone.removeWhere((e) => e == 'funAndLearn');
        playDifferentImg.removeWhere((e) => e == Assets.funNLearnIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desFunAndLearn');
      }

      if (!_sysConfigCubit.isGuessTheWordEnabled) {
        playDifferentZone.removeWhere((e) => e == 'guessTheWord');
        playDifferentImg.removeWhere((e) => e == Assets.guessTheWordIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desGuessTheWord');
      }

      if (!_sysConfigCubit.isAudioQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == 'audioQuestions');
        playDifferentImg.removeWhere((e) => e == Assets.guessTheWordIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desAudioQuestions');
      }

      if (!_sysConfigCubit.isMathQuizEnabled) {
        playDifferentZone.removeWhere((e) => e == 'mathMania');
        playDifferentImg.removeWhere((e) => e == Assets.mathsQuizIcon);
        playDifferentZoneDesc.removeWhere((e) => e == 'desMathMania');
      }

      if (!_sysConfigCubit.isExamQuizEnabled) {
        examSelf.removeWhere((e) => e == 'exam');
        examSelfDesc.removeWhere((e) => e == 'desExam');
        examSelfImg.removeWhere((e) => e == Assets.examQuizIcon);
      }

      if (!_sysConfigCubit.isSelfChallengeQuizEnabled) {
        examSelf.removeWhere((e) => e == 'selfChallenge');
        examSelfDesc.removeWhere((e) => e == 'challengeYourselfLbl');
        examSelfImg.removeWhere((e) => e == Assets.selfChallengeIcon);
      }

      if (!_sysConfigCubit.isGroupBattleEnabled) {
        battleName.removeWhere((e) => e == 'groupPlay');
        battleImg.removeWhere((e) => e == Assets.groupBattleIcon);
        battleDesc.removeWhere((e) => e == 'desGroupPlay');
      }

      if (!_sysConfigCubit.isOneVsOneBattleEnabled &&
          !_sysConfigCubit.isRandomBattleEnabled) {
        battleName.removeWhere((e) => e == 'battleQuiz');
        battleImg.removeWhere((e) => e == Assets.groupBattleIcon);
        battleDesc.removeWhere((e) => e == 'desBattleQuiz');
      }
      setState(() {});
    });
  }

  late bool showUpdateContainer = false;

  Future<void> checkForUpdates() async {
    await Future<void>.delayed(Duration.zero);
    if (_sysConfigCubit.isForceUpdateEnable) {
      try {
        final forceUpdate =
            await UiUtils.forceUpdate(_sysConfigCubit.appVersion);

        if (forceUpdate) {
          setState(() => showUpdateContainer = true);
        }
      } catch (e) {
        log('Force Update Error', error: e);
      }
    }
  }

  Future<void> setupInteractedMessage() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        announcement: true,
        provisional: true,
      );
    } else {
      final isGranted = (await Permission.notification.status).isGranted;
      if (!isGranted) await Permission.notification.request();
    }
    await FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    // handle background notification
    FirebaseMessaging.onBackgroundMessage(UiUtils.onBackgroundMessage);
    //handle foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Notification arrives : ${message.toMap()}');
      final data = message.data;
      log(data.toString(), name: 'notification data msg');
      final title = data['title'].toString();
      final body = data['body'].toString();
      final type = data['type'].toString();
      final image = data['image'].toString();

      //if notification type is badges then update badges in cubit list
      if (type == 'badges') {
        Future.delayed(Duration.zero, () {
          context.read<BadgesCubit>().unlockBadge(data['badge_type'] as String);
        });
      }

      if (type == 'payment_request') {
        Future.delayed(Duration.zero, () {
          context.read<UserDetailsCubit>().updateCoins(
                addCoin: true,
                coins: int.parse(data['coins'] as String),
              );
        });
      }
      log(image, name: 'notification image data');
      //payload is some data you want to pass in local notification
      if (image != 'null' && image.isNotEmpty) {
        log('image ${image.runtimeType}');
        generateImageNotification(title, body, image, type, type);
      } else {
        generateSimpleNotification(title, body, type);
      }
    });
  }

  //quiz_type according to the notification category
  QuizTypes _getQuizTypeFromCategory(String category) {
    return switch (category) {
      'audio-question-category' => QuizTypes.audioQuestions,
      'guess-the-word-category' => QuizTypes.guessTheWord,
      'fun-n-learn-category' => QuizTypes.funAndLearn,
      _ => QuizTypes.quizZone,
    };
  }

  // notification type is category then move to category screen
  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      if (message.data['type'].toString().contains('category')) {
        await Navigator.of(context).pushNamed(
          Routes.category,
          arguments: {
            'quizType':
                _getQuizTypeFromCategory(message.data['type'] as String),
          },
        );
      } else if (message.data['type'] == 'badges') {
        //if user open app by tapping
        UiUtils.updateBadgesLocally(context);
        await Navigator.of(context).pushNamed(Routes.badges);
      } else if (message.data['type'] == 'payment_request') {
        await Navigator.of(context).pushNamed(Routes.wallet);
      }
    } catch (e) {
      log(e.toString(), error: e);
    }
  }

  Future<void> _onTapLocalNotification(NotificationResponse? payload) async {
    final type = payload!.payload ?? '';
    if (type == 'badges') {
      await Navigator.of(context).pushNamed(Routes.badges);
    } else if (type.contains('category')) {
      await Navigator.of(context).pushNamed(
        Routes.category,
        arguments: {
          'quizType': _getQuizTypeFromCategory(type),
        },
      );
    } else if (type == 'payment_request') {
      await Navigator.of(context).pushNamed(Routes.wallet);
    }
  }

  Future<void> generateImageNotification(
    String title,
    String msg,
    String image,
    String payloads,
    String type,
  ) async {
    final largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: msg,
      htmlFormatSummaryText: true,
    );
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      packageName,
      appName,
      icon: '@drawable/ic_notification',
      channelDescription: appName,
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      msg,
      platformChannelSpecifics,
      payload: payloads,
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }

  // notification on foreground
  Future<void> generateSimpleNotification(
    String title,
    String body,
    String payloads,
  ) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      packageName, //channel id
      appName, //channel name
      channelDescription: appName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payloads,
    );
  }

  @override
  void dispose() {
    ProfileManagementLocalDataSource.updateReversedCoins(0);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    _tabController.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    //show you left the game
    if (state == AppLifecycleState.resumed) {
      UiUtils.needToUpdateCoinsLocally(context);
    } else {
      ProfileManagementLocalDataSource.updateReversedCoins(0);
    }
  }

  void _onTapProfile() => Navigator.of(context).pushNamed(
        Routes.menuScreen,
        arguments: widget.isGuest,
      );

  void _onTapLeaderboard() => Navigator.of(context).pushNamed(
        widget.isGuest ? Routes.otpScreen : Routes.leaderBoard,
      );

  void _onPressedZone(String index) {
    if (widget.isGuest) {
      _showLoginDialog();
      return;
    }

    switch (index) {
      case 'dailyQuiz':
        Navigator.of(context).pushNamed(
          Routes.quiz,
          arguments: {
            'quizType': QuizTypes.dailyQuiz,
            'numberOfPlayer': 1,
            'quizName': 'Daily Quiz',
          },
        );
        return;
      case 'funAndLearn':
        Navigator.of(context).pushNamed(
          Routes.category,
          arguments: {
            'quizType': QuizTypes.funAndLearn,
          },
        );
        return;
      case 'guessTheWord':
        Navigator.of(context).pushNamed(
          Routes.category,
          arguments: {
            'quizType': QuizTypes.guessTheWord,
          },
        );
        return;
      case 'audioQuestions':
        Navigator.of(context).pushNamed(
          Routes.category,
          arguments: {
            'quizType': QuizTypes.audioQuestions,
          },
        );
        return;
      case 'mathMania':
        Navigator.of(context).pushNamed(
          Routes.category,
          arguments: {
            'quizType': QuizTypes.mathMania,
          },
        );
        return;
      case 'truefalse':
        Navigator.of(context).pushNamed(
          Routes.quiz,
          arguments: {
            'quizType': QuizTypes.trueAndFalse,
            'numberOfPlayer': 1,
            'quizName': 'True/False Quiz',
          },
        );
        return;
    }
  }

  void _onPressedSelfExam(String index) {
    if (widget.isGuest) {
      _showLoginDialog();
      return;
    }

    if (index == 'exam') {
      context.read<ExamCubit>().updateState(ExamInitial());
      Navigator.of(context).pushNamed(Routes.exams);
    } else if (index == 'selfChallenge') {
      context.read<QuizCategoryCubit>().updateState(QuizCategoryInitial());
      context.read<SubCategoryCubit>().updateState(SubCategoryInitial());
      Navigator.of(context).pushNamed(Routes.selfChallenge);
    }
  }

  void _onPressedBattle(String index) {
    if (widget.isGuest) {
      _showLoginDialog();
      return;
    }

    context.read<QuizCategoryCubit>().updateState(QuizCategoryInitial());
    if (index == 'groupPlay') {
      context
          .read<MultiUserBattleRoomCubit>()
          .updateState(MultiUserBattleRoomInitial());

      Navigator.of(context).push(
        CupertinoPageRoute<void>(
          builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (context) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
            child: CreateOrJoinRoomScreen(
              quizType: QuizTypes.groupPlay,
              title: context.tr('groupPlay')!,
            ),
          ),
        ),
      );
    } else if (index == 'battleQuiz') {
      context.read<BattleRoomCubit>().updateState(
            BattleRoomInitial(),
            cancelSubscription: true,
          );

      if (_sysConfigCubit.isRandomBattleEnabled) {
        Navigator.of(context).pushNamed(Routes.randomBattle);
      } else {
        Navigator.of(context).push(
          CupertinoPageRoute<CreateOrJoinRoomScreen>(
            builder: (_) => BlocProvider<UpdateScoreAndCoinsCubit>(
              create: (_) =>
                  UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
              child: CreateOrJoinRoomScreen(
                quizType: QuizTypes.oneVsOneBattle,
                title: context.tr('playWithFrdLbl')!,
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showLoginDialog() {
    return showLoginDialog(
      context,
      onTapYes: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(Routes.otpScreen);
      },
    );
  }

  late String _userName = context.tr('guest')!;
  late String _userProfileImg = Assets.profile('2.png');

  Widget _buildProfileContainer() {
    return Align(
      alignment: Alignment.topCenter,
      child: GestureDetector(
        onTap: _onTapProfile,
        child: Container(
          margin: EdgeInsets.only(
            top: _statusBarPadding * .2,
            left: hzMargin,
            right: hzMargin,
          ),
          width: scrWidth,
          child: LayoutBuilder(
            builder: (_, constraint) {
              final size = MediaQuery.of(context).size;

              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    width: constraint.maxWidth * 0.15,
                    height: constraint.maxWidth * 0.15,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .onTertiary
                            .withOpacity(0.3),
                      ),
                    ),
                    child: QImage.circular(imageUrl: _userProfileImg),
                  ),
                  SizedBox(width: size.width * .03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: constraint.maxWidth * 0.5,
                        child: Text(
                          '${context.tr(helloKey)!} $_userName',
                          maxLines: 1,
                          style: _boldTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        context.tr(letsPlay)!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(0.3),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// LeaderBoard
                  Container(
                    width: size.width * 0.11,
                    height: size.width * 0.11,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: _onTapLeaderboard,
                      icon: widget.isGuest
                          ? const Icon(
                              Icons.login_rounded,
                              color: Colors.white,
                            )
                          : QImage(
                              imageUrl: Assets.leaderboardIcon,
                              color: Colors.white,
                              width: size.width * 0.08,
                              height: size.width * 0.08,
                            ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// Settings
                  Container(
                    width: size.width * 0.11,
                    height: size.width * 0.11,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(Routes.settings);
                      },
                      icon: QImage(
                        imageUrl: Assets.settingsIcon,
                        color: Colors.white,
                        width: size.width * 0.08,
                        height: size.width * 0.08,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategory() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hzMargin),
          child: Row(
            children: [
              Text(
                context.tr('quizZone')!,
                style: _boldTextStyle,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  widget.isGuest
                      ? _showLoginDialog()
                      : Navigator.of(context).pushNamed(
                          Routes.category,
                          arguments: {'quizType': QuizTypes.quizZone},
                        );
                },
                child: Text(
                  context.tr(viewAllKey) ?? viewAllKey,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(.6),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          // Adjust the values as needed
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    children: [
                      quizZoneCategories(),
                    ],
                  ),
                ),
              ),
              /*if (canExpandCategoryList)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCateListExpanded = !isCateListExpanded;
                  });
                },
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 10, bottom: 30),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCateListExpanded
                        ? Icons.keyboard_arrow_left_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 32,
                  ),
                ),1
              ),*/
            ],
          ),
        ),
      ],
    );
  }

  Widget quizZoneCategories() {
    return BlocConsumer<QuizoneCategoryCubit, QuizoneCategoryState>(
      bloc: context.read<QuizoneCategoryCubit>(),
      listener: (context, state) {
        if (state is QuizoneCategoryFailure) {
          if (state.errorMessage == errorCodeUnauthorizedAccess) {
            showAlreadyLoggedInDialog(context);
          }
        }
      },
      builder: (context, state) {
        if (state is QuizoneCategoryFailure) {
          return ErrorContainer(
            showRTryButton: false,
            showBackButton: false,
            showErrorImage: false,
            errorMessage: convertErrorCodeToLanguageKey(state.errorMessage),
            onTapRetry: () {
              context.read<QuizoneCategoryCubit>().getQuizCategoryWithUserId(
                    languageId: UiUtils.getCurrentQuestionLanguageId(context),
                  );
            },
          );
        }

        if (state is QuizoneCategorySuccess) {
          final categories = state.categories;
          final int categoriesToShowCount;

          /// Min/Max Categories to Show.
          const minCount = 5;
          const maxCount = 5;

          /// need to check old cate list with new cate list, when we change languages.
          /// and rebuild the list.
          if (oldCategoriesToShowCount != categories.length) {
            Future.delayed(Duration.zero, () {
              oldCategoriesToShowCount = categories.length;
              canExpandCategoryList = oldCategoriesToShowCount > minCount;
              setState(() {});
            });
          }

          if (!isCateListExpanded) {
            categoriesToShowCount =
                categories.length <= minCount ? categories.length : minCount;
          } else {
            categoriesToShowCount =
                categories.length <= maxCount ? categories.length : maxCount;
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(categoriesToShowCount, (i) {
                final category = categories[i];
                final colorScheme = Theme.of(context).colorScheme;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 8), // Add spacing between items
                  child: GestureDetector(
                    onTap: () {
                      if (widget.isGuest) {
                        _showLoginDialog();
                        return;
                      }

                      if (category.isPremium && !category.hasUnlocked) {
                        showUnlockPremiumCategoryDialog(
                          context,
                          categoryId: category.id!,
                          categoryName: category.categoryName!,
                          requiredCoins: category.requiredCoins,
                          isQuizZone: true,
                        );
                        return;
                      }

                      if (category.noOf == '0') {
                        if (category.maxLevel == '0') {
                          Navigator.of(context).pushNamed(
                            Routes.quiz,
                            arguments: {
                              'numberOfPlayer': 1,
                              'quizType': QuizTypes.quizZone,
                              'categoryId': category.id,
                              'subcategoryId': '',
                              'level': '0',
                              'subcategoryMaxLevel': '0',
                              'unlockedLevel': 0,
                              'contestId': '',
                              'comprehensionId': '',
                              'quizName': 'Quiz Zone',
                              'showRetryButton': category.noOfQues! != '0',
                            },
                          );
                        } else {
                          Navigator.of(context).pushNamed(
                            Routes.levels,
                            arguments: {
                              'Category': category,
                            },
                          );
                        }
                      } else {
                        Navigator.of(context).pushNamed(
                          Routes.subcategoryAndLevel,
                          arguments: {
                            'category_id': category.id,
                            'category_name': category.categoryName,
                          },
                        );
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 90, // Adjust width as needed
                          height: 90, // Adjust height as needed
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(1),
                            child: QImage(
                              imageUrl: category.image!,
                              fit: BoxFit.fill,
                              width: 50, // Adjust the width as needed
                              height: 50, // Adjust the height as needed
                            ),
                          ),
                        ),
                        const SizedBox(
                            height:
                                8), // Adjust spacing between image and title
                        Text(
                          category.categoryName!,
                          style: _boldTextStyle.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        }

        return const Center(child: CircularProgressContainer());
      },
    );
  }

  Widget _buildBattle() {
    return battleName.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              left: hzMargin,
              right: hzMargin,
              top: scrHeight * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Zone Title: Battle
                Text(
                  context.tr(battleOfTheDayKey) ?? battleOfTheDayKey, //
                  style: _boldTextStyle,
                ),

                /// Categories
                GridView.count(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this produces 2 rows.
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 20,
                  padding: EdgeInsets.only(top: _statusBarPadding * 0.2),
                  crossAxisSpacing: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(
                    battleName.length,
                    (i) => QuizGridCard(
                      onTap: () => _onPressedBattle(battleName[i]),
                      title: context.tr(battleName[i])!,
                      desc: context.tr(battleDesc[i])!,
                      img: battleImg[i],
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget _buildExamSelf() {
    return examSelf.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              left: hzMargin,
              right: hzMargin,
              top: scrHeight * 0.04,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(selfExamZoneKey) ?? selfExamZoneKey,
                  style: _boldTextStyle,
                ),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 20,
                  padding: EdgeInsets.only(top: _statusBarPadding * 0.2),
                  crossAxisSpacing: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(
                    examSelf.length,
                    (i) => QuizGridCard(
                      onTap: () => _onPressedSelfExam(examSelf[i]),
                      title: context.tr(examSelf[i])!,
                      desc: context.tr(examSelfDesc[i])!,
                      img: examSelfImg[i],
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget _buildZones() {
    return Padding(
      padding: EdgeInsets.only(
        left: hzMargin,
        right: hzMargin,
        top: scrHeight * 0.04,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (playDifferentZone.isNotEmpty)
            Text(
              context.tr(playDifferentZoneKey) ?? playDifferentZoneKey,
              style: _boldTextStyle,
            )
          else
            const SizedBox(),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            mainAxisSpacing: 20,
            padding: EdgeInsets.only(
              top: _statusBarPadding * 0.2,
              bottom: _statusBarPadding * 0.6,
            ),
            crossAxisSpacing: 20,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              playDifferentZone.length,
              (i) => QuizGridCard(
                onTap: () => _onPressedZone(playDifferentZone[i]),
                title: context.tr(playDifferentZone[i])!,
                desc: context.tr(playDifferentZoneDesc[i])!,
                img: playDifferentImg[i],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyAds() {
    var clicked = false;
    return BlocBuilder<RewardedAdCubit, RewardedAdState>(
      builder: (context, state) {
        if (state is RewardedAdLoaded &&
            context.read<UserDetailsCubit>().isDailyAdAvailable) {
          return GestureDetector(
            onTap: () async {
              if (!clicked) {
                await context
                    .read<RewardedAdCubit>()
                    .showDailyAd(context: context);
                clicked = true;
              }
            },
            child: Container(
              margin: EdgeInsets.only(
                left: hzMargin,
                right: hzMargin,
                top: scrHeight * 0.02,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).colorScheme.surface,
              ),
              width: scrWidth,
              height: scrWidth * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      Assets.dailyCoins,
                      width: scrWidth * .23,
                      height: scrWidth * .23,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('dailyAdsTitle')!,
                        style: TextStyle(
                          fontWeight: FontWeights.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onTertiary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${context.tr("get")!} "
                        '${_sysConfigCubit.coinsPerDailyAdView} '
                        "${context.tr("dailyAdsDesc")!}",
                        style: TextStyle(
                          fontWeight: FontWeights.regular,
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onTertiary
                              .withOpacity(.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLiveContestSection() {
    void onTapViewAll() {
      if (_sysConfigCubit.isContestEnabled) {
        Navigator.of(context).pushNamed(Routes.contest);
      } else {
        UiUtils.showSnackBar(
          context.tr(currentlyNotAvailableKey)!,
          context,
        );
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hzMargin, vertical: 10),
        child: Column(
          children: [
            /// Contest Section Title
            Row(
              children: [
                Text(
                  context.tr(contest) ?? contest,
                  style: _boldTextStyle,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onTapViewAll,
                  child: Text(
                    context.tr(viewAllKey) ?? viewAllKey,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .onTertiary
                          .withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
            //const SizedBox(height: 10),

            /// Contest Card
            BlocConsumer<ContestCubit, ContestState>(
              bloc: context.read<ContestCubit>(),
              listener: (context, state) {
                if (state is ContestFailure) {
                  if (state.errorMessage == errorCodeUnauthorizedAccess) {
                    showAlreadyLoggedInDialog(context);
                  }
                }
              },
              builder: (context, state) {
                if (state is ContestFailure) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 100,
                    alignment: Alignment.center,
                    child: Text(
                      context.tr(
                        convertErrorCodeToLanguageKey(state.errorMessage),
                      )!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeights.regular,
                        color: Theme.of(context).primaryColor,
                      ),
                      maxLines: 2,
                    ),
                  );
                }

                if (state is ContestSuccess) {
                  final colorScheme = Theme.of(context).colorScheme;
                  final textStyle = GoogleFonts.nunito(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeights.regular,
                      color: colorScheme.onTertiary.withOpacity(0.6),
                    ),
                  );

                  ///
                  final homeLive = state.contestList.homeLive;
                  final homeUpcoming = state.contestList.homeUpcoming;

                  /// No Contest
                  if (homeLive.errorMessage.isNotEmpty &&
                      homeUpcoming.errorMessage.isNotEmpty) {
                    return Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 100,
                      alignment: Alignment.center,
                      child: Text(
                        context.tr(
                          convertErrorCodeToLanguageKey(homeLive.errorMessage),
                        )!,
                        style: _boldTextStyle.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    );
                  }

                  final topContests = [
                    ...state.contestList.homeLive.contestDetails,
                    ...state.contestList.homeUpcoming.contestDetails,
                  ];

                  final size = MediaQuery.of(context).size;

                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 5),
                          blurRadius: 5,
                          color: Colors.black12,
                        ),
                      ],
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(99999),
                      ),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: topContests.length,
                      itemBuilder: (context, index) {
                        final contest = topContests[index];
                        final entryFee = int.parse(contest.entry!);
                        var labelText = 'Register';
                        if (homeLive.contestDetails.contains(contest)) {
                          labelText = 'Play Now';
                        } else {
                          labelText = contest.registered == '1'
                              ? 'Registered'
                              : 'Register';
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          width: size.width * .9,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            boxShadow: [
                              UiUtils.buildBoxShadow(
                                offset: const Offset(5, 5),
                                blurRadius: 10,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              Assets.coin,
                                              width: 18,
                                              height: 18,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              '$entryFee ${context.tr('coinsLbl')!}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Info', // The new info text you wanted
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () => CommonUtils
                                              .showInstructionBottomSheet(
                                            context: context,
                                            contest: contest,
                                            isPlayNowBtn: false,
                                            isInstructionBtn: true,
                                          ),
                                          child: Icon(
                                            Icons.info_outline,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Center Image
                                Center(
                                  child: CachedNetworkImage(
                                    imageUrl: contest.image!,
                                    placeholder: (_, i) => const Center(
                                      child: CircularProgressContainer(),
                                    ),
                                    imageBuilder: (_, img) {
                                      return Container(
                                        height: 60, // Fixed height
                                        width: 60, // Fixed width
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                              image: img, fit: BoxFit.cover),
                                        ),
                                      );
                                    },
                                    errorWidget: (_, i, e) => Center(
                                      child: Icon(
                                        Icons.error,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Centered Contest Name
                                Center(
                                  child: Text(
                                    contest.name!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Entry Icon and Participants Count
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          Assets.timerIcon,
                                          width: 18,
                                          height: 18,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${contest.endDate?.replaceAll('-', ' ')} @ ${contest.startTime}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          Assets.participantIcon,
                                          width: 18,
                                          height: 18,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${contest.seatsLeft!}/${contest.contestParticipantLimit!} participants',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                // Register Button
                                Center(
                                  child: GestureDetector(
                                    onTap: () =>
                                        _handleOnTap(contest, labelText),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8), // Button padding
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Theme.of(context)
                                            .primaryColor, // Button background color
                                      ),
                                      child: Text(
                                        labelText, // Button text
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Colors.white, // Button text color
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
                    ),
                  );
                }

                return const Center(child: CircularProgressContainer());
              },
            ),
          ],
        ),
      ),
    );
  }

  String _userRank = '0';
  String _userCoins = '0';
  String _userScore = '0';

  Widget _buildHome() {
    return Stack(
      children: [
        RefreshIndicator(
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onRefresh: () async {
            fetchUserDetails();

            _currLangId = UiUtils.getCurrentQuestionLanguageId(context);
            final quizCubit = context.read<QuizCategoryCubit>();
            final quizZoneCubit = context.read<QuizoneCategoryCubit>();

            if (widget.isGuest) {
              await quizCubit.getQuizCategory(
                languageId: _currLangId,
                type: _quizZoneId,
              );
              await quizZoneCubit.getQuizCategory(languageId: _currLangId);
            } else {
              await quizCubit.getQuizCategoryWithUserId(
                languageId: _currLangId,
                type: _quizZoneId,
              );

              await quizZoneCubit.getQuizCategoryWithUserId(
                languageId: _currLangId,
              );
              await context
                  .read<ContestCubit>()
                  .getContest(languageId: _currLangId);
            }
            setState(() {});
          },
          child: ListView(
            children: [
              if (_selectedIndex == 0) ...[
                _buildProfileContainer(),
               Image_Data(),

                // UserAchievements(
                //   userRank: _userRank,
                //   userCoins: _userCoins,
                //   userScore: _userScore,
                // ),

                // BlocBuilder<QuizoneCategoryCubit, QuizoneCategoryState>(
                //   builder: (context, state) {
                //     if (state is QuizoneCategoryFailure &&
                //         state.errorMessage == errorCodeDataNotFound) {
                //       return const SizedBox.shrink();
                //     }
                //   },),
                if (_sysConfigCubit.isQuizZoneEnabled)
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        // Tab Bar
                        TabBar(
                          tabs: [
                            Container(
                              width: 100.0,
                              child: Tab(text: 'Quiz'),
                            ),
                            Container(
                              width: 100.0,
                              child: Tab(text: 'Contest'),
                            ),
                          ],
                        ),

                        // Tab Views
                        Container(
                          child: SizedBox(
                            height: 500, 
                            child: TabBarView(
                              children: [
                                _buildCategory(),
                                _buildLiveContestSection(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_sysConfigCubit.isAdsEnable &&
                    _sysConfigCubit.isDailyAdsEnabled &&
                    !widget.isGuest) ...[
                  _buildDailyAds(),
                ],
              ] else if (_selectedIndex == 1) ...[
                // Content for My Quiz

                Center(child: Text('My Quiz Page')),
              ] else if (_selectedIndex == 2) ...[
                // // Content for My Contest
                // MyContestPage()
                // _buildLiveContestSection()
                // buildContestSection(context, _tabController)
              ] else if (_selectedIndex == 3) ...[
                // Content for Leaderboard
                Center(child: Text('Leaderboard Page')),
              ],
            ],
          ),
        ),
        if (showUpdateContainer) const UpdateAppContainer(),
      ],
    );
  }

  void fetchUserDetails() {
    context.read<UserDetailsCubit>().fetchUserDetails();
  }

  void _handleOnTap(ContestDetails contest, String labelText) {
    if (labelText == 'Play Now') {
      CommonUtils.showInstructionBottomSheet(
        context: context,
        contest: contest,
        isPlayNowBtn: true,
      );
    } else {
      _registerContest(contest);
    }
  }

  Future<void> _registerContest(ContestDetails contest) async {
    if (int.parse(context.read<UserDetailsCubit>().getCoins()!) >=
        int.parse(contest.entry!)) {
      final result = await context
          .read<ContestCubit>()
          .checkUserRegisteredContest(contestId: contest.id, context: context);
      if (result.registered == 0) {
        CommonUtils.showInstructionBottomSheet(
          context: context,
          contest: contest,
          isPlayNowBtn: false,
        );
      } else if (result.registered == 1) {
        await Fluttertoast.showToast(
          msg: 'User already registered for contest',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16,
        );
      }
    } else {
      UiUtils.showSnackBar(context.tr('noCoinsMsg')!, context);
    }
  }

  bool profileComplete = false;
  late String contactInformation = 'Contact information';
  late String contactNumber = '0123456789';

  @override
  Widget build(BuildContext context) {
    _boldTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Theme.of(context).colorScheme.onTertiary,
    );

    return Scaffold(
      body: SafeArea(
        child: widget.isGuest
            ? _buildHome()

            /// Build home with User
            : BlocConsumer<UserDetailsCubit, UserDetailsState>(
                bloc: context.read<UserDetailsCubit>(),
                listener: (context, state) {
                  if (state is UserDetailsFetchSuccess) {
                    UiUtils.fetchBookmarkAndBadges(
                      context: context,
                      userId: state.userProfile.userId!,
                    );
                    if (state.userProfile.profileUrl!.isEmpty ||
                        state.userProfile.name!.isEmpty) {
                      if (!profileComplete) {
                        profileComplete = true;

                        Navigator.of(context).pushNamed(
                          Routes.selectProfile,
                          arguments: false,
                        );
                      }
                      return;
                    }
                  } else if (state is UserDetailsFetchFailure) {
                    if (state.errorMessage == errorCodeUnauthorizedAccess) {
                      showAlreadyLoggedInDialog(context);
                    }
                  }
                },
                builder: (context, state) {
                  if (state is UserDetailsFetchInProgress ||
                      state is UserDetailsInitial) {
                    return const Center(child: CircularProgressContainer());
                  }
                  if (state is UserDetailsFetchFailure) {
                    if (state.errorMessage ==
                        errorCodeAccountHasBeenDeactivated) {
                      return Center(
                        child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
                          bloc: context.read<AppSettingsCubit>(),
                          builder: (context, successState) {
                            if (successState is AppSettingsFetchSuccess) {
                              contactInformation = successState.settingsData;
                              contactInformation = contactInformation
                                  .replaceAll(RegExp('</?p>'), '');
                              final regex = RegExp(r'\b\d{10}\b');
                              final Match? match =
                                  regex.firstMatch(contactInformation);
                              final mobileNumber = match?.group(0);
                              contactNumber = mobileNumber!;
                            }
                            return ErrorContainer(
                              showBackButton: true,
                              errorMessage: convertErrorCodeToLanguageKey(
                                  state.errorMessage),
                              onTapRetry: fetchUserDetails,
                              showErrorImage: false,
                              showConnectToAdminOption: true,
                              contactNumber: contactNumber,
                            );
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: ErrorContainer(
                          showBackButton: true,
                          errorMessage:
                              convertErrorCodeToLanguageKey(state.errorMessage),
                          onTapRetry: fetchUserDetails,
                          showErrorImage: false,
                        ),
                      );
                    }
                  }

                  final user = (state as UserDetailsFetchSuccess).userProfile;

                  _userName = user.name!;
                  _userProfileImg = user.profileUrl!;
                  _userRank = user.allTimeRank!;
                  _userCoins = user.coins!;
                  _userScore = user.allTimeScore!;
                  return _buildHome();
                },
              ),
      ),
    );
  }
}