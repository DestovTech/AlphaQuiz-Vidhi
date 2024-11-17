import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {

  RazorpayService() {
    _razorpay = Razorpay();
    _razorpay..on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess)
    ..on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError)
    ..on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  Function(PaymentSuccessResponse)? onPaymentSuccess;
  Function(PaymentFailureResponse)? onPaymentFailure;
  late Razorpay _razorpay;

  void openCheckout(int amount, String? razorPayApiKey) {
    amount = amount * 100;
    final options = {
      'key': razorPayApiKey,
      'amount': amount,
      'name': 'Alpha Quiz.',
      'description': 'Coins Purchase',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'method': {
        'netbanking': true,
        'card': true,
        'upi': true,
      },
      'external': {
        'methods': ['upi'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
      msg: 'Payment Successful ${response.paymentId}',
      toastLength: Toast.LENGTH_SHORT,
    );
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: 'Payment Failed: ${response.message!}',
      toastLength: Toast.LENGTH_SHORT,
    );
    if (onPaymentFailure != null) {
      onPaymentFailure!(response);
    }
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
      msg: 'External Wallet: ${response.walletName!}',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  void dispose() {
    _razorpay.clear();
  }
}
