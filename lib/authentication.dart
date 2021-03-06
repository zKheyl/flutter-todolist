import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import "package:flutter_todolist/main.dart";


class AuthenticationPage extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 2250);

  Future<String> _authUser(LoginData data) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: data.name, password:data.password);
      return Future.delayed(loginTime);
    } on FirebaseAuthException catch (e) {
      return e.code;
    }
  }

  Future<String> _authRegister(LoginData data) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: data.name, password: data.password);
      return Future.delayed(loginTime);
    } on FirebaseAuthException catch (e) {
      if (e.code =='weak-password') {
        return('the password provided is too weak');
      } else if (e.code == 'emai-already-in-use') {
        return('the account already exists for that email');
      }
    }
  }

  Future<String> _recoverPassword(String name) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: name, password: 'noSuchAccount');
      FirebaseAuth.instance.currentUser.delete();
      return('Cet email n\'a pas de compte assigné');
    } on FirebaseAuthException catch (e) {
      if (e.code =='weak-password') {
        return('the password provided is too weak');
      } else if (e.code == 'emai-already-in-use') {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: name);
        return('un email avec votre mot de passe a été envoyé');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'fbt-todolist',
      onLogin: _authUser,
      onSignup: _authRegister,
      onSubmitAnimationCompleted: () {
        Navigator.of(context)..pushReplacement(MaterialPageRoute(
          builder: (context) => ListsPage(title: "mes listes", userid: FirebaseAuth.instance.currentUser.uid),
        ));
      },
      onRecoverPassword: _recoverPassword,
    );
  }

}