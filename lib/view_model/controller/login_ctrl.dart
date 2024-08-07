// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:chatboat/model/user_model.dart';
import 'package:chatboat/view/auth/auth.dart';
import 'package:chatboat/view/home/home.dart';
import 'package:chatboat/view/widgets/msg_toast.dart';
import 'package:chatboat/view_model/firebase_service/auth_service.dart';
import 'package:chatboat/view_model/firebase_service/firestore_user_res.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

class LoginController extends GetxController {
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController forgotEmailCtrl = TextEditingController();
  TextEditingController passworldCtrl = TextEditingController();
  TextEditingController userNameCtrl = TextEditingController();
  TextEditingController numberCtrl = TextEditingController();
  TextEditingController otpCtrl = TextEditingController();
  FocusNode? numberFocus;
  bool obscurePassword = true;
  bool isSignUp = false;
  User? user;

  void obscureState() {
    obscurePassword = !obscurePassword;
    update();
  }

  void signUpState() {
    isSignUp = !isSignUp;
    update();
  }

  void clearControllers() {
    emailCtrl.clear();
    passworldCtrl.clear();
    userNameCtrl.clear();
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> signInWithGoogle({required BuildContext context}) async {
    User? user;
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
        if (user != null) {
          await UserFirestoreRes().addUserToFirestore(
            model: UserModel(
                email: user.email,
                name: user.displayName,
                uid: user.uid,
                datetime: DateFormat.yMMMMEEEEd().format(DateTime.now()),
                url: user.photoURL,
                lastUpdated: '',
                number: user.phoneNumber),
          );
          Get.off(() => const HomeView(),
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 400),
              transition: Transition.zoom);
        } else {
          boatSnackBar(
              text: 'Error', message: 'Something Went Wrong', ctx: context);
        }
      } catch (e) {
        log(e.toString());
      }
    } else {
      log("account is doesn't exist");
    }
  }

  handleScreens(context) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return Get.offAll(() => const HomeView(),
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 400),
          transition: Transition.zoom);
    } else {
      return Get.offAll(() => const LoginView(),
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 400),
          transition: Transition.zoom);
    }
  }

// -------------------------------------------------logout----------------------------------------------------
  Future<void> logout(context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await auth.signOut();
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await Get.offAll(() => const LoginView(),
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 400),
          transition: Transition.zoom);
      boatSnackBar(
          message: 'Logout', text: 'Succeed', isSuccess: true, ctx: context);
    } catch (e) {
      log('Error during logout: $e');
    }
  }

  ///*************************** singup with email and password ***********************************************
  bool isSignUpLoading = false;
  Future<User?> signUpWithEmailAndPassword(BuildContext ctx) async {
    isSignUpLoading = true;
    update();
    try {
      UserCredential credential =
          await AuthServices.signUP(emailCtrl.text, passworldCtrl.text);
      await UserFirestoreRes().addUserToFirestore(
        model: UserModel(
            email: emailCtrl.text,
            name: userNameCtrl.text,
            uid: credential.user?.uid,
            datetime: DateFormat.yMMMMEEEEd().format(DateTime.now()),
            url: '',
            lastUpdated: '',
            number: ''),
      );
      clearControllers();
      boatSnackBar(
          message: 'New Account Created',
          text: 'Succeed',
          isSuccess: true,
          ctx: ctx);
      return credential.user;
    } catch (e) {
      log(e.toString());
    } finally {
      isSignUpLoading = false;
      update();
    }
    return null;
  }

//*********************************************signin with email and password *******************************************
  bool isSignInLoading = false;
  Future<User?> signInWithEmailAndPasswords(BuildContext ctx) async {
    isSignInLoading = true;
    update();
    try {
      UserCredential credential =
          await AuthServices.signIN(emailCtrl.text, passworldCtrl.text);
      passworldCtrl.clear();
      emailCtrl.clear();
      boatSnackBar(
          message: 'Login Successfull',
          text: 'Succeed',
          isSuccess: true,
          ctx: ctx);
      return credential.user;
    } catch (e) {
      log(e.toString());
    } finally {
      isSignInLoading = false;
      update();
    }
    return null;
  }

  //*********************************************forgot password ***************************************

  bool isForgotLoading = false;
  Future<void> forgotPassword(context) async {
    isForgotLoading = true;
    update();
    try {
      AuthServices.forgotPassword(emailCtrl.text).then((value) {
        Navigator.pop(context);
        forgotEmailCtrl.clear();
        boatSnackBar(
            message: 'Check Email Inbox',
            text: 'Succeed',
            isSuccess: true,
            ctx: context);
      });
    } catch (e) {
      log(e.toString());
    } finally {
      isForgotLoading = false;
      update();
    }
  }

//----------------------------------------Delete account-----------------------------------------------------
  Future<void> deleteAccount(context) async {
    try {
      log('CALLED DELETE ACCOUNT ');
      bool status = await AuthServices.deleteUserAccount();
      if (status) {
        await UserFirestoreRes().deleteUserCollection();
        Get.offAll(() => const LoginView(),
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 400),
            transition: Transition.zoom);
      } else {
        boatSnackBar(
            text: 'Error',
            message:
                'Just Now You Create Account .\nLog in again before retrying this request.',
            ctx: context);
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
