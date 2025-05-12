import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthStates {}

class InitialAuthState extends AuthStates{}

class SigningUp extends AuthStates{}

class SignedUp extends AuthStates{}

class SigningIn extends AuthStates{}

class SignedIn extends AuthStates{}

class SigningUpFailed extends AuthStates{
  final String errorMessage;
  SigningUpFailed({required this.errorMessage});
}

class SigningInFailed extends AuthStates{
  final String errorMessage;
  SigningInFailed({required this.errorMessage});
}

class SigningInGoogle extends AuthStates{}

class SignedUpGoogle extends AuthStates{
  final UserCredential user;
  SignedUpGoogle({required this.user});
}

class SignedInGoogle extends AuthStates{}
