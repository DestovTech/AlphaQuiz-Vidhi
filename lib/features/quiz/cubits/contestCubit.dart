import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/quiz/models/contest.dart';
import 'package:flutterquiz/features/quiz/quizRepository.dart';

@immutable
abstract class ContestState {}

class ContestInitial extends ContestState {}

class ContestProgress extends ContestState {}

class ContestSuccess extends ContestState {
  ContestSuccess(this.contestList);

  final Contests contestList;
}

class ContestFailure extends ContestState {
  ContestFailure(this.errorMessage);

  final String errorMessage;
}

class ContestCubit extends Cubit<ContestState> {
  ContestCubit(this._quizRepository) : super(ContestInitial());
  final QuizRepository _quizRepository;

  Future<void> getContest({required String languageId}) async {
    emit(ContestProgress());
    await _quizRepository.getContest(languageId: languageId).then((val) {
      emit(ContestSuccess(val));
    }).catchError((Object e) {
      emit(ContestFailure(e.toString()));
    });
  }

  Future<ContestRegisterResult> setUserRegisterContest({required String? contestId, required BuildContext context}) async {
    try {
      final response = await _quizRepository.setUserRegisterContest(contestId: contestId);
      final statusCode = response['status'] as String;
      final message = response['msg'] as String;
      return ContestRegisterResult(message: message, statusCode: statusCode);
    } catch (e) {
      emit(ContestFailure(e.toString()));
    }
    return ContestRegisterResult(message: 'Register');
  }

  Future<ContestRegisteredResult> checkUserRegisteredContest({required String? contestId, required BuildContext context}) async {
    try {
      final response = await _quizRepository.checkUserRegisteredContest(contestId: contestId);
      final statusCode = response['status'] as int?;
      final registered = response['registered'] as int?;

      return ContestRegisteredResult(registered: registered, statusCode: statusCode);
    } catch (e) {
      emit(ContestFailure(e.toString()));
    }
    return ContestRegisteredResult(registered: 0);
  }
}

class ContestRegisterResult {
  ContestRegisterResult({this.label, this.message, this.statusCode});

  final String? label;
  final String? message;
  final String? statusCode;
}

class ContestRegisteredResult {
  ContestRegisteredResult({this.registered, this.statusCode});

  final int? registered;
  final int? statusCode;
}
