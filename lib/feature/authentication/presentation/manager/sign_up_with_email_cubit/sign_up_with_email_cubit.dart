import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'sign_up_with_email_states.dart';

class SignUpWithEmailCubit extends Cubit<SignUpWithEmailState> {
  SignUpWithEmailCubit() : super(SignUpWithEmailInitial());
  Future<void> userRegister(
      {required String email,
      required String password,
      required String name}) async {
    try {
      emit(SignUpWithEmailLoading());
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      CollectionReference usernames =
          FirebaseFirestore.instance.collection('usernames');
      try {
        // Add user data to Firestore under the user ID
        await usernames.doc(FirebaseAuth.instance.currentUser!.uid).set({
          'name': name, // optional: store timestamp
        });

        //
      } catch (e) {
        //
      }

      await FirebaseAuth.instance.currentUser?.reload();
      emit(SignUpWithEmailSuccess());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(SignUpWithEmailFaliure(
            errorMsg: 'The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        emit(SignUpWithEmailFaliure(
            errorMsg: 'The account already exists for that email'));
      } else {
        emit(
          SignUpWithEmailFaliure(errorMsg: 'Email is not valid!.'),
        );
      }
    } catch (e) {
      emit(SignUpWithEmailFaliure(errorMsg: 'somthing went wrong'));
    }
  }
}
