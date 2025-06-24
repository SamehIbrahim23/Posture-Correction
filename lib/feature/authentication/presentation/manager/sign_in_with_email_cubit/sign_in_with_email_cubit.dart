// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sign_in_with_email_states.dart';

class SignInWithEmailCubit extends Cubit<SignInWithEmailState> {
  SignInWithEmailCubit() : super(SignInWithEmailInitial());

  Future<void> userSignIn(
      {required String email, required String password}) async {
    emit(SignInWithEmailLoading());
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(
        SignInWithEmailSuccess(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        emit(SignInWithEmailFailure(errorMsg: 'Wrong password'));
      } else {
        emit(SignInWithEmailFailure(errorMsg: 'No user found for that email'));
      }
    } catch (e) {
      emit(
        SignInWithEmailFailure(
          errorMsg: e.toString(),
        ),
      );
    }
  }
}
