part of 'sign_up_with_email_cubit.dart';

abstract class SignUpWithEmailState {}

class SignUpWithEmailInitial extends SignUpWithEmailState {}

class SignUpWithEmailLoading extends SignUpWithEmailState {}

class SignUpWithEmailSuccess extends SignUpWithEmailState {}

class SignUpWithEmailFaliure extends SignUpWithEmailState {
  final String errorMsg;
  SignUpWithEmailFaliure({required this.errorMsg});
}
