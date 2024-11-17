import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';

@immutable
abstract class UpdateUserDetailState {}

class UpdateUserDetailInitial extends UpdateUserDetailState {}

class UpdateUserDetailInProgress extends UpdateUserDetailState {}

class UpdateUserDetailSuccess extends UpdateUserDetailState {}

class UpdateUserDetailFailure extends UpdateUserDetailState {
  UpdateUserDetailFailure(this.errorMessage);

  final String errorMessage;
}

class UpdateUserDetailCubit extends Cubit<UpdateUserDetailState> {
  UpdateUserDetailCubit(this._profileManagementRepository)
      : super(UpdateUserDetailInitial());
  final ProfileManagementRepository _profileManagementRepository;

  void updateState(UpdateUserDetailState newState) {
    emit(newState);
  }

  void removeAdsForUser({required bool status}) {
    emit(UpdateUserDetailInProgress());
    _profileManagementRepository
        .removeAdsForUser(status: status)
        .then((value) => emit(UpdateUserDetailSuccess()))
        .catchError((Object e) => emit(UpdateUserDetailFailure(e.toString())));
  }

  Future<void> updateProfile({
    required String email,
    required String name,
    required String mobile,
  }) async {
    emit(UpdateUserDetailInProgress());
    await _profileManagementRepository
        .updateProfile(
      email: email,
      mobile: mobile,
      name: name,
    )
        .then((value) {
      emit(UpdateUserDetailSuccess());
    }).catchError((Object e) {
      emit(UpdateUserDetailFailure(e.toString()));
    });
  }

  Future<void> setUserInApp({
    required String productId,
    required String paymentId,
  }) async {
    emit(UpdateUserDetailInProgress());
    await _profileManagementRepository
        .setUserInApp(
      productId: productId,
      paymentId: paymentId,
    )
        .then((value) {
      emit(UpdateUserDetailSuccess());
    }).catchError((Object e) {
      emit(UpdateUserDetailFailure(e.toString()));
    });
  }

  Future<RazorPayDetailResult> getRazorPayDetail() async {
    try {
      final response = await _profileManagementRepository.getRazorPayDetail();
      final razorPayApiKey = response['razorpay_api_key'] as String;
      final razorPaySecretKey = response['razorpay_secret_key'] as String;
      return RazorPayDetailResult(razorPayApiKey: razorPayApiKey ?? '', razorPaySecretKey: razorPaySecretKey ?? '');
    } catch (e) {
      emit(UpdateUserDetailFailure(e.toString()));
      return RazorPayDetailResult(razorPayApiKey: '', razorPaySecretKey: '');
    }
  }
}

class RazorPayDetailResult {
  RazorPayDetailResult({this.razorPayApiKey, this.razorPaySecretKey});

  final String? razorPayApiKey;
  final String? razorPaySecretKey;
}
