import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';
import 'package:flutterquiz/ui/widgets/alreadyLoggedInDialog.dart';
import 'package:flutterquiz/ui/widgets/circularProgressContainer.dart';
import 'package:flutterquiz/ui/widgets/errorContainer.dart';
import 'package:flutterquiz/utils/common_utils.dart';
import 'package:flutterquiz/utils/constants/assets_constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:flutterquiz/utils/constants/fonts.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Contest Type
const int _past = 0;
const int _live = 1;
const int _upcoming = 2;

class ContestScreen extends StatefulWidget {
  const ContestScreen({super.key});

  @override
  State<ContestScreen> createState() => _ContestScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<ContestCubit>(
            create: (_) => ContestCubit(QuizRepository()),
          ),
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) => UpdateScoreAndCoinsCubit(
              ProfileManagementRepository(),
            ),
          ),
        ],
        child: const ContestScreen(),
      ),
    );
  }
}

class _ContestScreen extends State<ContestScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    context
        .read<ContestCubit>()
        .getContest(languageId: UiUtils.getCurrentQuestionLanguageId(context));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,

              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: Text(
                context.tr('contestLbl')!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              // leading: const CustomBackButton(),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Theme.of(context)
                        .colorScheme
                        .onTertiary
                        .withOpacity(0.08),
                  ),
                  child: TabBar(
                    tabAlignment: TabAlignment.fill,
                    tabs: [
                      Tab(text: context.tr('pastLbl')),
                      Tab(text: context.tr('liveLbl')),
                      // Tab(text: context.tr('upcomingLbl')),
                    ],
                  ),
                ),
              ),
            ),
            body: BlocConsumer<ContestCubit, ContestState>(
              bloc: context.read<ContestCubit>(),
              listener: (context, state) {
                if (state is ContestFailure) {
                  if (state.errorMessage == errorCodeUnauthorizedAccess) {
                    showAlreadyLoggedInDialog(context);
                  }
                }
              },
              builder: (context, state) {
                if (state is ContestProgress || state is ContestInitial) {
                  return const Center(
                    child: CircularProgressContainer(),
                  );
                }
                if (state is ContestFailure) {
                  return ErrorContainer(
                    errorMessage:
                        convertErrorCodeToLanguageKey(state.errorMessage),
                    onTapRetry: () {
                      context.read<ContestCubit>().getContest(
                            languageId:
                                UiUtils.getCurrentQuestionLanguageId(context),
                          );
                    },
                    showErrorImage: true,
                  );
                }
                final contestList = (state as ContestSuccess).contestList;
                return TabBarView(
                  children: [
                    past(contestList.past),
                    live(contestList.live),
                    future(contestList.upcoming),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget past(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _past,
            ),
          );
  }

  Widget live(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _live,
            ),
          );
  }

  Widget future(Contest data) {
    return data.errorMessage.isNotEmpty
        ? contestErrorContainer(data)
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: data.contestDetails.length,
            itemBuilder: (_, i) => _ContestCard(
              contestDetails: data.contestDetails[i],
              contestType: _upcoming,
            ),
          );
  }

  ErrorContainer contestErrorContainer(Contest data) {
    return ErrorContainer(
      showBackButton: false,
      errorMessage: convertErrorCodeToLanguageKey(data.errorMessage),
      onTapRetry: () => context.read<ContestCubit>().getContest(
            languageId: UiUtils.getCurrentQuestionLanguageId(context),
          ),
      showErrorImage: true,
    );
  }
}

class _ContestCard extends StatefulWidget {
  const _ContestCard({required this.contestDetails, required this.contestType});

  final ContestDetails contestDetails;
  final int contestType;

  @override
  State<_ContestCard> createState() => _ContestCardState();
}

class _ContestCardState extends State<_ContestCard> {
  String _registerLabel = 'Leaderboard';

  @override
  void initState() {
    super.initState();
    if (widget.contestType == _upcoming) {
      if (widget.contestDetails.registered == '1') {
        _registerLabel = 'Registered';
      } else {
        _registerLabel = 'Register';
      }
    }
    if (widget.contestType == _live) {
      _registerLabel = 'Play Now';
    }
  }

  Future<void> _registerContest() async {
    if (int.parse(context.read<UserDetailsCubit>().getCoins()!) >=
        int.parse(widget.contestDetails.entry!)) {
      final result = await context.read<ContestCubit>().checkUserRegisteredContest(contestId: widget.contestDetails.id,  context: context);
      if (result.registered == 0) {
        CommonUtils.showInstructionBottomSheet(
            context: context,
            contest: widget.contestDetails,
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

  void _handleOnTap() {
    if (widget.contestType == _past) {
      Navigator.of(context).pushNamed(
        Routes.contestLeaderboard,
        arguments: {'contestId': widget.contestDetails.id},
      );
    }
    if (widget.contestType == _live) {
      CommonUtils.showInstructionBottomSheet(
          context: context,
          contest: widget.contestDetails,
          isPlayNowBtn: true,
      );
    }
    if (widget.contestType == _upcoming) {
      _registerContest();
    }
  }

  @override
  Widget build(BuildContext context) {
    final boldTextStyle = TextStyle(
      fontSize: 14,
      color: Theme.of(context).colorScheme.onTertiary,
      fontWeight: FontWeight.bold,
    );
    final normalTextStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeights.regular,
      color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.6),
    );
    final size = MediaQuery.of(context).size;

    final verticalDivider = SizedBox(
      width: 1,
      height: 30,
      child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
    );

    return Container(
      margin: const EdgeInsets.all(15),
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
            // Top Row: Date on the left, Instruction icon on the right
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          '${widget.contestDetails.entry!} ${context.tr('coinsLbl')!}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => CommonUtils.showInstructionBottomSheet(
                        context: context,
                        contest: widget.contestDetails,
                        isPlayNowBtn: false,
                        isInstructionBtn: true,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Info', // The clickable Info text
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                        ],
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
                imageUrl: widget.contestDetails.image!,
                placeholder: (_, i) => const Center(
                  child: CircularProgressContainer(),
                ),
                imageBuilder: (_, img) {
                  return Container(
                    height: 60, // Fixed height
                    width: 60, // Fixed width
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(image: img, fit: BoxFit.cover),
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
                widget.contestDetails.name!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Entry Icon and Participants Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      '${widget.contestDetails.endDate?.replaceAll('-', ' ')} @ ${widget.contestDetails.startTime}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface,
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
                      widget.contestType == _past
                          ? '${widget.contestDetails.participants} participants'
                          : '${widget.contestDetails.seatsLeft!}/${widget.contestDetails.contestParticipantLimit!} participants',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurface,
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
                onTap: _handleOnTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8), // Button padding
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).primaryColor, // Button background color
                  ),
                  child: Text(
                    _registerLabel, // Button text
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Button text color
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
