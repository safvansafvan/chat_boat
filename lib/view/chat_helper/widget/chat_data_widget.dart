import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatboat/model/firestore_model.dart';
import 'package:chatboat/view/widgets/animated_text_kit.dart';
import 'package:chatboat/view_model/controller/boat_controller.dart';
import 'package:chatboat/view_model/controller/globel_ctrl.dart';
import 'package:chatboat/view_model/core/colors.dart';
import 'package:chatboat/view_model/core/custom_function.dart';
import 'package:chatboat/view_model/core/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class BoatChatDataWidget extends StatelessWidget {
  const BoatChatDataWidget(
      {super.key,
      required this.dataSet,
      required this.isLastIndex,
      required this.ctrl});

  final FirestoreModel dataSet;
  final bool isLastIndex;
  final BoatChatCtrl ctrl;

  @override
  Widget build(BuildContext context) {
    log(dataSet.image ?? 'images');
    return GetBuilder<GlobleController>(builder: (gc) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppSizes.radius10,
          border: Border.all(color: AppColors.borderGrey),
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            tileMode: TileMode.clamp,
            colors: gc.themeMode
                ? [AppColors.greyColor, AppColors.blackShade]
                : [
                    Colors.blue.withOpacity(0.6),
                    Colors.white.withAlpha(300),
                    Colors.white
                  ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Date : ',
                          style: CustomFunctions.style(
                              fontWeight: FontWeight.w600, size: 14),
                          children: [
                            TextSpan(
                              text: dataSet.date ?? "",
                              style: CustomFunctions.style(
                                  fontWeight: FontWeight.w500, size: 13),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      RichText(
                        text: TextSpan(
                          text: 'Time : ',
                          style: CustomFunctions.style(
                              fontWeight: FontWeight.w600, size: 14),
                          children: [
                            TextSpan(
                              text: dataSet.time ?? "",
                              style: CustomFunctions.style(
                                  fontWeight: FontWeight.w500, size: 13),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: dataSet.ans ?? ''));
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.copy,
                            color: AppColors.whiteColor,
                            size: 15,
                          ),
                          AppSizes.width10,
                          Text(
                            'Copy Text',
                            style: CustomFunctions.style(
                                fontWeight: FontWeight.w400,
                                size: 12,
                                color: AppColors.whiteColor),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: AppSizes.radius10,
                      border: Border.all(
                        color: AppColors.greyColor.withAlpha(300),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SelectableText(
                        dataSet.qus ?? '',
                        textAlign: TextAlign.start,
                        style: CustomFunctions.style(
                            fontWeight: FontWeight.w400,
                            size: 14,
                            color: AppColors.blackColor),
                        maxLines: null,
                      ),
                    ),
                  ),
                ),
                dataSet.image != '' && dataSet.image != null
                    ? Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: dataSet.image ?? '',
                          placeholder: (context, url) =>
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
            isLastIndex && ctrl.isLoadingNew
                ? AnimatedTextKitWidget(textV: dataSet.ans ?? "")
                : SelectableText(
                    dataSet.ans ?? "",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 15),
                  ),
          ],
        ),
      );
    });
  }
}
