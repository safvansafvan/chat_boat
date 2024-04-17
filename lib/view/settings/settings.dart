import 'package:chatboat/view/widgets/boat_drop_down.dart';
import 'package:chatboat/view_model/constant.dart';

import 'package:flutter/material.dart';

settingsDialog(BuildContext context) async {
  return await showDialog(
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    context: context,
    builder: (context) {
      return Dialog(
        elevation: 5,
        insetPadding: EdgeInsets.zero,
        surfaceTintColor: const Color(0xffF9F9F9),
        shadowColor: const Color(0xffF9F9F9),
        backgroundColor: const Color(0xffF9F9F9),
        shape: RoundedRectangleBorder(borderRadius: radius10),
        child: SizedBox(
          width: 600,
          height: 500,
          child: Column(
            children: [
              minHeight,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Settings',
                      style: boatTextStyle(
                          fontWeight: FontWeight.w700,
                          size: 18,
                          color: blackColor),
                    ),
                    const Icon(Icons.close, size: 30)
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                title: Text('Theme'),
                trailing: SizedBox(
                  width: 150,
                  child: CredrDropDown(
                    hintText: 'Theme',
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                  shape: OutlineInputBorder(
                      borderRadius: radius10, borderSide: BorderSide.none),
                  minLeadingWidth: 0,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                  horizontalTitleGap: 10,
                  leading: const CircleAvatar(radius: 20),
                  title: Text(
                    'Muhammed Safvan',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: boatTextStyle(
                        fontWeight: FontWeight.w500,
                        size: 12,
                        color: blackColor),
                  ),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.logout),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
