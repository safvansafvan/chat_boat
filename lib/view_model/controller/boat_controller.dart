import 'dart:developer';
import 'package:chatboat/model/firestore_model.dart';
import 'package:chatboat/view/widgets/msg_toast.dart';
import 'package:chatboat/view_model/firebase_service/firestore_chat_res.dart';
import 'package:chatboat/view_model/storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class BoatChatCtrl extends GetxController {
  TextEditingController questionCtrl = TextEditingController();
  FocusNode questionFocous = FocusNode();
  bool isLoadingAns = false;
  List<FirestoreModel> allHistory = [];
  static const String key = 'AIzaSyDr9OuXdV4zMasHUHS3OxWxOh8iocF8_Vk';
  int bodyCurrentInd = 0;
  String currentDate = '';
  String currentTime = '';
  bool isLoadingNew = false;
  bool isClearHistory = false;
  var uuid = const Uuid();
  Uint8List? selectedImage;

  void bodyCurrentIndState(int ind) {
    bodyCurrentInd = ind;
    update();
  }

  Future<void> boatChatHandling(context) async {
    if (allHistory.length >= 50) {
      return boatSnackBar(
          text: 'Error', message: 'Please Clean Your History', ctx: context);
    } else {
      String valueText = questionCtrl.text;
      questionCtrl.clear();
      isLoadingAns = true;
      isLoadingNew = false;
      bodyCurrentInd = 1;
      Uint8List? value = selectedImage;
      selectedImage = null;

      String? downloadedImageUrl;
      update();
      String id = uuid.v1();
      formateDate(DateTime.now());

      try {
        if (value != null) {
          downloadedImageUrl =
              await FireStoreRes().uploadImageToStorage(value, uuid.v1());
          log(downloadedImageUrl);
        }
        final model =
            GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: key);
        final content = [
          value != null
              ? Content.multi([
                  TextPart(valueText),
                  DataPart('image/jpeg', value),
                ])
              : Content.text(valueText)
        ];
        final response = await model.generateContent(content);
        log(response.text ?? '');
        log('$currentDate  $currentTime  $id');
        await FireStoreRes().addHistoryToFirestore(
          model: FirestoreModel(
              id: id,
              ans: response.text?.split('*').join(),
              qus: valueText,
              date: currentDate,
              time: currentTime,
              image: downloadedImageUrl,
              timestamp: Timestamp.now()),
        );

        StorageUtil.insertData('doc_key', id);
        await getHistoryFirestore();
      } catch (e) {
        log(e.toString());
      } finally {
        isLoadingAns = false;
        isLoadingNew = true;
        update();
      }
    }
  }

  void loadingNewState() {
    isLoadingNew = false;
    update();
  }

  Future<void> getHistoryFirestore() async {
    try {
      allHistory = await FireStoreRes().getHistoryFromFireStore();
      update();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> clearHistory(context) async {
    isClearHistory = true;
    update();
    try {
      await FireStoreRes().deleteCollection().then((_) async {
        await getHistoryFirestore();
      });
      if (allHistory.isEmpty) {
        bodyCurrentInd = 0;
        update();
        boatSnackBar(
            text: 'Success',
            message: 'All Historys Deleted',
            ctx: context,
            isSuccess: true);
      }
    } catch (e) {
      boatSnackBar(
          text: 'Error',
          message: 'Genie Clear History Failed',
          ctx: context,
          isSuccess: false);
    } finally {
      isClearHistory = false;
      update();
    }
  }

  void formateDate(DateTime dateTime) {
    currentTime = DateFormat('hh:mm').format(dateTime);
    currentDate = DateFormat.MMMMEEEEd().format(dateTime);
  }

  Future<void> imageFromGalleryOrCamera({bool isCamera = false}) async {
    final ImagePicker picker = ImagePicker();
    if (isCamera) {
      final XFile? cameraFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 100);
      if (cameraFile != null) {
        selectedImage = await cameraFile.readAsBytes();
        Get.back();
        update();
      }
    } else {
      final XFile? gfile = await picker.pickImage(source: ImageSource.gallery);
      if (gfile != null) {
        selectedImage = await gfile.readAsBytes();

        Get.back();
        update();
      }
    }
    log('IMAGE PICKED');
  }

  void clearSelectedImage() {
    selectedImage = null;
    update();
  }
}
