import 'package:flutter/material.dart';
import 'package:funli_app/src/app_router/router_enum.dart';
import 'package:funli_app/src/res/app_colors.dart';
import 'package:funli_app/src/res/app_icons.dart';
import 'package:funli_app/src/res/app_textstyles.dart';
import 'package:funli_app/src/res/spacing_constants.dart';
import 'package:go_router/go_router.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  static const List<String> _images = [
    AppIcons.onboarding1,
    AppIcons.onboarding2,
    AppIcons.onboarding3,
    AppIcons.onboarding4,
    AppIcons.onboarding5,
  ];

  late final AnimationController _row1Controller;
  late final AnimationController _row2Controller;
  late final AnimationController _row3Controller;

  @override
  void initState() {
    super.initState();
    _row1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..repeat();
    _row2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 32),
    )..repeat();
    _row3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 26),
    )..repeat();
  }

  @override
  void dispose() {
    _row1Controller.dispose();
    _row2Controller.dispose();
    _row3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      body: SafeArea(
        child: Column(
          spacing: 24,
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: .center,
                spacing: 14,
                children: [
                  _ScrollingImageRow(
                    controller: _row1Controller,
                    images: _images,
                    reverse: false,
                    itemSize: 92,
                    gap: 14,
                    isStadiumRow: false,
                  ),
                  _ScrollingImageRow(
                    controller: _row2Controller,
                    images: _images,
                    reverse: true,
                    itemSize: 100,
                    gap: 14,
                    isStadiumRow: true,
                  ),
                  _ScrollingImageRow(
                    controller: _row3Controller,
                    images: _images.reversed.toList(),
                    reverse: false,
                    itemSize: 92,
                    gap: 14,
                    isStadiumRow: false,
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const .symmetric(
                  horizontal: SpacingConstants.screenHorizontalPadding,
                ),
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    Text(
                      'Your Daily Vibe',
                      textAlign: .center,
                      style: AppTextStyles.headingTextStyle.copyWith(
                        color: AppColors.colorBlack,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your emotional journey starts here.\nDiscover reels that match your energy.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.regularTextStyle.copyWith(
                        color: AppColors.greyTextColor,
                        height: 1.45,
                      ),
                    ),
                    const Spacer(flex: 3),
                    _GetStartedButton(
                      onTap: () =>
                          context.push(RouterEnum.signupView.routeName),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Already a member?',
                      style: AppTextStyles.smallTextStyle.copyWith(
                        color: AppColors.greyTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () {
                        debugPrint("On tap");
                        context.push(RouterEnum.loginView.routeName);
                      },
                      child: Text(
                        'Login',
                        style: AppTextStyles.smallBoldTextStyle.copyWith(
                          color: AppColors.colorBlack,
                          decoration: .underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: SpacingConstants.buttonHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.colorBlack,
          borderRadius: BorderRadius.circular(SpacingConstants.buttonHeight),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.12),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          'Get Started',
          style: AppTextStyles.buttonTextStyle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ScrollingImageRow extends StatelessWidget {
  const _ScrollingImageRow({
    required this.controller,
    required this.images,
    required this.reverse,
    required this.itemSize,
    required this.gap,
    required this.isStadiumRow,
  });

  final AnimationController controller;
  final List<String> images;
  final bool reverse;
  final double itemSize;
  final double gap;
  final bool isStadiumRow;

  double get _stadiumWidth => itemSize * 1.55;

  double _itemWidth(int index) {
    if (!isStadiumRow) return itemSize;
    return index.isEven ? itemSize : _stadiumWidth;
  }

  double get _oneSetWidth {
    double total = 0;
    for (int i = 0; i < images.length; i++) {
      total += _itemWidth(i) + gap;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final oneSetWidth = _oneSetWidth;

    return SizedBox(
      height: itemSize,
      width: .infinity,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final progress = controller.value;
            final dx = reverse
                ? -oneSetWidth * progress
                : -oneSetWidth * (1 - progress);
            return Transform.translate(
              offset: Offset(dx, 0),
              child: child,
            );
          },
          child: Row(
            children: [
              ..._buildItems(),
              ..._buildItems(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems() {
    return List.generate(images.length, (index) {
      final isStadium = isStadiumRow && index.isOdd;
      final width = isStadium ? _stadiumWidth : itemSize;
      return Padding(
        padding: EdgeInsets.only(right: gap),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isStadium ? itemSize / 2 : itemSize / 2,),
          child: SizedBox(
            width: width,
            height: itemSize,
            child: Image.asset(
              images[index],
              fit: .cover,
            ),
          ),
        ),
      );
    });
  }
}
