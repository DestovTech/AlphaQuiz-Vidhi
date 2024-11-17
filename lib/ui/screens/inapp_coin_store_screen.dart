import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/app/routes.dart';
import 'package:flutterquiz/features/inAppPurchase/inAppPurchaseCubit.dart';
import 'package:flutterquiz/features/inAppPurchase/in_app_product.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateScoreAndCoinsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/updateUserDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/cubits/userDetailsCubit.dart';
import 'package:flutterquiz/features/profileManagement/profileManagementRepository.dart';
import 'package:flutterquiz/ui/screens/razorpay_payment.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CoinStoreScreen extends StatefulWidget {
  const CoinStoreScreen({
    required this.isGuest,
    required this.iapProducts,
    required this.minDeposit,
    super.key,
  });

  final bool isGuest;
  final List<InAppProduct> iapProducts;
  final int minDeposit;

  @override
  State<CoinStoreScreen> createState() => _CoinStoreScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments! as Map<String, dynamic>;

    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<UpdateScoreAndCoinsCubit>(
            create: (_) =>
                UpdateScoreAndCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: CoinStoreScreen(
          isGuest: args['isGuest'] as bool,
          iapProducts: args['iapProducts'] as List<InAppProduct>,
          minDeposit: args['minDeposit'] as int,
        ),
      ),
    );
  }
}

class _CoinStoreScreenState extends State<CoinStoreScreen>
    with SingleTickerProviderStateMixin {
  List<String> productIds = [];
  late RazorpayService _razorpayService;
  String? _selectedProductId;
  TextEditingController amountController = TextEditingController(); // Controller for the input field

  @override
  void initState() {
    super.initState();
    productIds = widget.iapProducts.map((e) => e.productId).toSet().toList();
    _razorpayService = RazorpayService();
    _razorpayService..onPaymentSuccess = (response) async {
      await Fluttertoast.showToast(
        msg: 'Payment success productId: $_selectedProductId',
        toastLength: Toast.LENGTH_SHORT,
      );
      await context
          .read<UpdateUserDetailCubit>()
          .setUserInApp(paymentId: response.paymentId!,
              productId: '$_selectedProductId',
            );
      }
    ..onPaymentFailure = (response) async {
      await context
          .read<UpdateUserDetailCubit>()
          .setUserInApp(
              paymentId: '${response.code}',
              productId: '$_selectedProductId',
            );
      };
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    amountController.dispose(); // Dispose the controller
    super.dispose();
  }

  Widget _buildStaticCard() {
    final colorScheme = Theme.of(context).colorScheme; // Accessing color scheme
    return Card(
      color: colorScheme.surface,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center( // Center the TextField
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter Coins', // Placeholder text
                  border: OutlineInputBorder(), // No border
                ), // Use onPrimary color for text
                style: TextStyle(
                  color: colorScheme.onTertiary,
                  fontWeight: FontWeights.semiBold,
                  fontSize: 16,
                  overflow: TextOverflow.ellipsis, // Make text bold
                ),
                textAlign: TextAlign.center, // Center text in TextField
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (amountController.text.isNotEmpty) {
                    final amount = int.parse(amountController.text);
                    if (amount >= widget.minDeposit) {
                      _selectedProductId = '${amount}_custom_coins';
                      final result  = await context.read<UpdateUserDetailCubit>().getRazorPayDetail();
                      _razorpayService.openCheckout(amount, result.razorPayApiKey);
                    } else {
                      await Fluttertoast.showToast(
                        msg: 'Please enter minimum ${widget.minDeposit} coins',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
                  } else {
                    await Fluttertoast.showToast(
                      msg: 'Please enter coins',
                      toastLength: Toast.LENGTH_SHORT,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero, // Make button rectangular
                  ),
                ),
                child: const Text(
                  'ADD COINS',
                  style: TextStyle(
                    color: Colors.white, // Set text color to white
                    fontWeight: FontWeights.bold, // Make text bold
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProducts(List<InAppProduct> products) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        GridView.builder(
          padding: EdgeInsets.symmetric(
            vertical: size.height * UiUtils.vtMarginPct,
            horizontal: size.width * UiUtils.hzMarginPct,
          ),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, idx) {
            final product = products[idx];
            final iap = widget.iapProducts.firstWhere(
                  (e) => e.productId == product.productId,
              orElse: () => InAppProduct(
                id: '',
                title: 'Unknown',
                coins: 0,
                productId: '',
                image: '',
                desc: '',
                isActive: false,
              ),
            );

            Future<void> purchaseProduct() async {
              if (widget.isGuest) {
                await showLoginDialog(
                  context,
                  onTapYes: () {
                    context
                      ..shouldPop() // close dialog
                      ..shouldPop() // menu screen
                      ..pushNamed(Routes.otpScreen);
                  },
                );
                return;
              }
              final amount = iap.coins;
              _selectedProductId = iap.productId;
              final result = await context.read<UpdateUserDetailCubit>().getRazorPayDetail();
              _razorpayService.openCheckout(amount, result.razorPayApiKey);
            }

            return GestureDetector(
              onTap: purchaseProduct,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 15),
                      child: iap.image.endsWith('.svg')
                          ? SvgPicture.network(
                              iap.image,
                              width: 40,
                              height: 26,
                            )
                          : Image.network(
                              iap.image,
                              width: 40,
                              height: 26,
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        iap.desc,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onTertiary.withOpacity(0.4),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      iap.title,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colorScheme.onTertiary,
                        fontWeight: FontWeights.semiBold,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 4,
                      ),
                      child: Text(
                        '₹${iap.coins}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeights.semiBold,
                          color: colorScheme.onTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),

        /// Restore Button
        if (Platform.isIOS && !widget.isGuest)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
              child: CustomRoundedButton(
                widthPercentage: 1,
                backgroundColor: Theme.of(context).primaryColor,
                buttonTitle: context.tr('restorePurchaseProducts'),
                radius: 8,
                showBorder: false,
                fontWeight: FontWeights.semiBold,
                height: 58,
                titleColor: colorScheme.surface,
                onTap:() {},
                elevation: 6.5,
                textSize: 18,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coin Store'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStaticCard(), // Add static card at the top
            SizedBox(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 500, // Provide max height
                ),
                child: _buildProducts(widget.iapProducts),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
