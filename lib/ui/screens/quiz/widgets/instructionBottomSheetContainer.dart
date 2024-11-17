import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/quiz/cubits/contestCubit.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/features/quiz/models/quizType.dart';
import 'package:flutterquiz/ui/widgets/customRoundedButton.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstructionBottomSheetContainer extends StatefulWidget {
  const InstructionBottomSheetContainer({
    required this.contest,
    required this.context,
    required this.isPlayNowBtn,
    required this.isInstructionBtn,
    super.key,
  });

  final ContestDetails contest;
  final BuildContext context;
  final bool isPlayNowBtn;
  final bool isInstructionBtn;

  @override
  State<InstructionBottomSheetContainer> createState() =>
      _InstructionBottomSheetContainerState();
}

class _InstructionBottomSheetContainerState
    extends State<InstructionBottomSheetContainer> {

  late String errorMessage = '';

  late bool rulesAccepted = false;

  final double horizontalPaddingPercentage = 0.125;

  Widget _buildAcceptRulesContainer() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal:
            MediaQuery.of(context).size.width * horizontalPaddingPercentage,
        vertical: 10,
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          const SizedBox(width: 2),
          InkWell(
            onTap: () {
              setState(() {
                rulesAccepted = !rulesAccepted;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rulesAccepted
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 1.5,
                  color: rulesAccepted
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              child: Icon(
                Icons.check,
                color: rulesAccepted
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.onTertiary,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            context.tr(iAgreeWithContestRulesKey)!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
        ],
      ),
    );
  }

  late Color _onTertiary;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _onTertiary = Theme.of(context).colorScheme.onTertiary;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: BlocListener<ContestCubit, ContestState>(
        bloc: context.read<ContestCubit>(),
        listener: (context, state) {
          if (state is ContestFailure) {
            setState(() {
              errorMessage = context.tr(
                convertErrorCodeToLanguageKey(state.errorMessage),
              )!;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          padding: const EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Title
                Align(
                  child: Text(
                    'Contest Instructions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _onTertiary,
                    ),
                  ),
                ),
                Divider(
                  color: _onTertiary.withOpacity(0.6),
                  thickness: 1.5,
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1, // Adjust padding as needed
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     /* e_buildInfoRow('Total number of questions:',widget.contest.questionCount!),
                      const SizedBox(height: 10),
                      _buildInfoRow('Total time available:', DateTimeUtils.convertMinutes(int.tryParse(widget.contest.contestTime ?? '0') ?? 0)),
                      const SizedBox(height: 10),
                      _buildInfoRow('Marks for correct:', '${widget.context.read<SystemConfigCubit>().contestCorrectAnswerCreditScore}'),
                      const SizedBox(height: 10),
                      _buildInfoRow('Marks for wrong:', '${widget.context.read<SystemConfigCubit>().contestWrongAnswerDeductScore}'),
                      const SizedBox(height: 10),  // Optional: space between rows and text*/
                      Text(
                        '${widget.contest.description}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _onTertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (widget.contest.rangesList != null && widget.contest.rangesList!.isNotEmpty)
                        Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Rank label
                                Text(
                                  'Rank',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                // Value label
                                Text(
                                  'Winnings',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            ...widget.contest.rangesList!.entries.map((entry) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '# ${entry.key}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '₹ ${entry.value}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      // If rangesList is null or empty, you can show a message instead
                      if (widget.contest.rangesList == null || widget.contest.rangesList!.isEmpty)
                         const Text(
                          'No ranges available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey, // Adjust color as needed
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.isPlayNowBtn) const SizedBox(height: 40),
                if (widget.isPlayNowBtn) _buildAcceptRulesContainer(),
                //show any error message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: errorMessage.isEmpty
                      ? const SizedBox(height: 20)
                      : SizedBox(
                          height: 20,
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: _onTertiary,
                            ),
                          ),
                        ),
                ),

                //show submit button
                BlocBuilder<ContestCubit, ContestState>(
                  bloc: context.read<ContestCubit>(),
                  builder: (context, state) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width *
                            UiUtils.hzMarginPct,
                      ),
                      child: CustomRoundedButton(
                        widthPercentage: MediaQuery.of(context).size.width,
                        backgroundColor: rulesAccepted || !widget.isPlayNowBtn
                            ? Theme.of(context).primaryColor
                            : _onTertiary,
                        buttonTitle: widget.isPlayNowBtn ? 'Start Contest' : 'OK',
                        radius: 8,
                        showBorder: false,
                        onTap: state is ContestProgress
                            ? () {}
                            : () {
                                if (!rulesAccepted && widget.isPlayNowBtn) {
                                  setState(() {
                                    errorMessage = context.tr(
                                      pleaseAcceptContestRulesKey,
                                    )!;
                                  });
                                } else {
                                  if (widget.isInstructionBtn) {
                                    Navigator.pop(context);
                                  }
                                  else if (widget.isPlayNowBtn) {
                                    onTapPlayNow();
                                  } else {
                                    onTapRegister();
                                  }
                                }
                              },
                        fontWeight: FontWeight.bold,
                        titleColor: Theme.of(context).colorScheme.surface,
                        height: 45,
                      ),
                    );
                  },
                ),

                SizedBox(height: MediaQuery.of(context).size.height * .05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onTapPlayNow() {
    // Dismiss the bottom sheet
    Navigator.pop(context);
    // Navigate to the quiz screen
    Navigator.of(widget.context).pushNamed(
      Routes.quiz,
      arguments: {
        'numberOfPlayer': 1,
        'quizType': QuizTypes.contest,
        'contestId': widget.contest.id,
        'quizName': 'Contest',
        'contestTime': widget.contest.contestTime,
      },
    );
  }

  Future<void> onTapRegister() async {
    final result = await context.read<ContestCubit>().setUserRegisterContest(contestId: widget.contest.id, context: context);
    if (result.statusCode == '200') {
      await Fluttertoast.showToast(
        msg: 'User registered contest successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16,
      );
      await context.read<UpdateScoreAndCoinsCubit>().updateCoins(
        coins: int.parse(widget.contest.entry!),
        addCoin: false,
        title: context.tr(playedContestKey) ?? '-',
      );
      context.read<UserDetailsCubit>().updateCoins(
        addCoin: false,
        coins: int.parse(widget.contest.entry!),
      );
    }
    Navigator.pop(context);
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: _onTertiary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: _onTertiary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
