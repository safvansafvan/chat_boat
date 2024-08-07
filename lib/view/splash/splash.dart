import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatboat/view_model/core/colors.dart';
import 'package:chatboat/view_model/core/custom_function.dart';
import 'package:chatboat/view_model/controller/globel_ctrl.dart';
import 'package:chatboat/view_model/controller/login_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    naviagateToHome();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final ctrl = Get.find<GlobleController>();
    ctrl.size = Size(context.width, context.height);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: screenSize.height / 3),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/gif/loading.gif',
                      height: 200, width: 200),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        ScaleAnimatedText(
                          'Genie Boat',
                          textStyle: CustomFunctions.style(
                              fontWeight: FontWeight.w600,
                              size: 26,
                              color: AppColors.whiteColor),
                        ),
                      ],
                      isRepeatingAnimation: true,
                      repeatForever: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> naviagateToHome() async {
    final lc = Get.find<LoginController>();
    await Future.delayed(const Duration(seconds: 2)).then(
      (value) => lc.handleScreens(context),
    );
  }
}
