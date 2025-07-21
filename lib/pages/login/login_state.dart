import 'package:flutter/material.dart';

class LoginState {
  final bool isPasswordVisible;
  final bool isLoading;
  final bool rememberMe;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final String? error;

  LoginState({
    required this.isPasswordVisible,
    required this.isLoading,
    required this.rememberMe,
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    this.error,
  });

  LoginState copyWith({
    bool? isPasswordVisible,
    bool? isLoading,
    bool? rememberMe,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    GlobalKey<FormState>? formKey,
    String? error,
  }) {
    return LoginState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      rememberMe: rememberMe ?? this.rememberMe,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      formKey: formKey ?? this.formKey,
      error: error,
    );
  }
}