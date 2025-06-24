part of 'sign_in_with_email_cubit.dart';

abstract class SignInWithEmailState {}

class SignInWithEmailInitial extends SignInWithEmailState {}

class SignInWithEmailLoading extends SignInWithEmailState {}

class SignInWithEmailSuccess extends SignInWithEmailState {}

class SignInWithEmailFailure extends SignInWithEmailState {
  final String errorMsg;
  SignInWithEmailFailure({required this.errorMsg});
}
