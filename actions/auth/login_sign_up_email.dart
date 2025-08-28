// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<String?> loginSignUpEmail(
  BuildContext context,
  String email,
  String password,
  String? confirmPassword,
  String? emailRedirectTo,
) async {
  // Instantiate the Supabase client
  final supabase = Supabase.instance.client;

  // Validate password match
  if (password != confirmPassword) {
    return "Las contraseñas no coinciden.";
  }

  try {
    // Attempt sign up with new user
    final AuthResponse res = await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: emailRedirectTo,
    );

    final User? user = res.user;

    if (user == null) {
      return "Error en el registro. Por favor intenta de nuevo.";
    }

    // Check if user already exists (empty metadata indicates existing user)
    if (user.userMetadata?.isEmpty ?? false) {
      return "Este usuario ya ha sido registrado.";
    }

    // Update app state for successful registration
    FFAppState().update(() {
      FFAppState().registerEmail = email;
      FFAppState().routeUserTo = '/emailConfirmed';
    });

    // Navigate to email confirmation page if context provided
    if (context != null && context.mounted) {
      context.pushNamed('email-confirmed');
    }

    return null; // Success - no error message
  } catch (e) {
    // Handle specific Supabase errors
    String errorMessage = e.toString();

    if (errorMessage.contains('already_exists') ||
        errorMessage.contains('User already registered')) {
      return "Este email ya está registrado. Intenta iniciar sesión.";
    } else if (errorMessage.contains('invalid_email')) {
      return "Por favor ingresa un email válido.";
    } else if (errorMessage.contains('weak_password')) {
      return "La contraseña es muy débil. Usa al menos 6 caracteres.";
    } else if (errorMessage.contains('signup_disabled')) {
      return "El registro está temporalmente deshabilitado.";
    } else if (errorMessage.contains('email_not_confirmed')) {
      return "Por favor confirma tu email antes de continuar.";
    }

    // Generic error fallback
    return "Error en el registro: Por favor intenta de nuevo.";
  }
}
