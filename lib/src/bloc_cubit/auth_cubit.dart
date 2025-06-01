import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funli_app/src/bloc_cubit/auth_states.dart';
import 'package:funli_app/src/res/firebase_constants.dart';
import 'package:funli_app/src/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthCubit extends Cubit<AuthStates>{
  AuthCubit(): super(InitialAuthState());
  final auth = FirebaseAuth.instance;
  final authService = AuthService.instance;


  Future<void> onGoogleSignInTap() async {
    emit(SigningInGoogle());
    try {
      // if it is web
      if (kIsWeb) {
        GoogleAuthProvider authProvider = GoogleAuthProvider(

        );
        try {
         UserCredential userCredential = await auth.signInWithPopup(authProvider);

          emit(SignedInGoogle(user: userCredential.user!));
        } catch (e) {
          String errorMessage = e.toString();
          if(e is PlatformException){
            errorMessage = e.message ?? e.toString();
          }else if (e is FirebaseAuthException) {
            errorMessage = e.message ?? e.toString();
            debugPrint("error while google sign in: ${e.message}");
          }

          emit(SigningInFailed(errorMessage: errorMessage));
        }
      } else {

        const List<String> scopes = <String>[
          'email',
        ];
        GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes,);
        final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
        if (googleSignInAccount != null) {
          final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );

          try {
            UserCredential? userCredential = await auth.signInWithCredential(credential);
            if (userCredential.additionalUserInfo!.isNewUser) {
              Map<String, dynamic> userMap = {
                'userID' : userCredential.user!.uid,
                'userName' : userCredential.user!.displayName
              };
              await FirebaseFirestore.instance.collection(FirebaseConstants.userCollection).doc(userCredential.user!.uid).set(userMap);
              emit(SignedUpGoogle(user: userCredential));
            } else {

              emit(SignedInGoogle(user: userCredential.user!));
            }
          } on FirebaseAuthException catch (e) {
            debugPrint("Google sign in error: ${e.toString()}");
            debugPrint("error while google sign in: ${e.message}");
            String errorMessage = e.toString();
            if (e.code == 'account-exists-with-different-credential') {
              errorMessage = 'Account exists with different credentials';
              // ...
            } else if (e.code == 'invalid-credential') {
              errorMessage = 'Invalid Credentials!';
              // ...
            }

            emit(SigningInFailed(errorMessage: errorMessage));
          } catch (e) {
            String errorMessage = e.toString();
            if(e is PlatformException){
              errorMessage = e.message ?? e.toString();
            }
            emit(SigningInFailed(errorMessage: errorMessage));
          }

        }else{
          emit(SigningInFailed(errorMessage: 'Signing up error'));
        }
      }
    } catch (e) {
      emit(SigningInFailed(errorMessage: e.toString()));
    }
  }

  Future<void> onSignupWithEmail({required String email, required String password, required String name})async{
    try{
      emit(SigningUp());
      UserCredential? user = await authService.signupUsingEmail(userName: name, email: email, password: password);
      if(user != null){
        emit(SignedUp());
      }else {
        emit(SigningUpFailed(errorMessage: "Failed to create account, Please check your internet connection and try again!"));
      }
    }catch(e){
      String errorMessage = e.toString();

      if(e is PlatformException){
        errorMessage = e.message!;
      }
      emit(SigningUpFailed(errorMessage: errorMessage));
    }
  }

  Future<void> signInWithEmail({required String email, required String password,})async{
    try{
      emit(SigningIn());
      User? user = await authService.signInWithEmail(email: email, password: password);
      if(user != null){
        emit(SignedIn());
      }else {
        emit(SigningInFailed(errorMessage: "Failed to create account, Please check your internet connection and try again!"));
      }
    } on FirebaseAuthException catch(error){
      emit(SigningInFailed(errorMessage: _getErrorMessage(error.code)));
    } catch(e){
      String errorMessage = e.toString();
      if(e is PlatformException){
        errorMessage = e.message!;
      }
      emit(SigningInFailed(errorMessage: errorMessage));
    }
  }

  Future<void> onCompleteUserSignup({required DateTime dob, required List<String> interests, required String gender})async{
    emit(CompletingUserSignupInfo());
    try{
      Map<String, dynamic> userMap = {
        'dob' : dob.toIso8601String(),
        'interests': interests,
        'gender' : gender
      };

      await authService.updateUserInfo(updatedMap: userMap);
      emit(CompletedUserSignupInfo());
    }catch(e){
      String errorMessage = e.toString();
      if(e is PlatformException){
        errorMessage = e.message!;
      }

      emit(CompletedUserSignupInfoFailed(errorMessage: errorMessage));
    }
  }


  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'operation-not-allowed':
        return 'This sign-in method is not allowed.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger one.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-credential':
        return 'Invalid credentials. Please try signing in again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-verification-code':
        return 'The verification code is incorrect.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please try again.';
      case 'credential-already-in-use':
        return 'This credential is already associated with another account.';
      case 'requires-recent-login':
        return 'Please log in again to complete this action.';
      case 'missing-verification-code':
        return 'Please enter the verification code.';
      case 'missing-verification-id':
        return 'Missing verification ID. Please try again.';
      case 'user-mismatch':
        return 'The credentials do not match this user.';
      case 'invalid-phone-number':
        return 'The phone number entered is invalid.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'app-not-authorized':
        return 'This app is not authorized to use Firebase Authentication.';
      case 'captcha-check-failed':
        return 'CAPTCHA verification failed. Please try again.';
      case 'missing-email':
        return 'Email address is required.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}