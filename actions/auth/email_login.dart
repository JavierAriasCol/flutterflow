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

Future<String?> emailLogin(
  BuildContext context,
  String email,
  String password,
) async {
  // Instantiate the Supabase client
  final supabase = Supabase.instance.client;

  // Validate input parameters
  if (email.isEmpty || password.isEmpty) {
    return "Por favor completa todos los campos.";
  }

  try {
    // Attempt sign in with existing user
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final User? user = res.user;

    if (user == null) {
      return "Error en el inicio de sesión. Credenciales incorrectas.";
    }

    // Scenario 1: Normal successful login
    if (user.emailConfirmedAt != null) {
      // Update app state - no rebuild needed for navigation
      FFAppState().userloginValidated = true;
      FFAppState().routeUserTo = '/home';

      // Navigate to main app
      if (context.mounted) {
        context.goNamed('home');
      }

      return null; // Success
    }
    // Scenario 2: Email not verified - redirect to confirmation
    else {
      // Store email for confirmation page
      FFAppState().registerEmail = email;
      FFAppState().routeUserTo = '/email-confirm';

      // Navigate to email confirmation page
      if (context.mounted) {
        context.pushNamed('email-confirm');
      }

      return null; // Success but needs verification
    }
  } catch (e) {
    // Handle specific Supabase login errors
    String errorMessage = e.toString().toLowerCase();

    if (errorMessage.contains('invalid_credentials') ||
        errorMessage.contains('invalid login credentials')) {
      return "Email o contraseña incorrectos.";
    } else if (errorMessage.contains('invalid_email')) {
      return "Por favor ingresa un email válido.";
    } else if (errorMessage.contains('email_not_confirmed')) {
      // Store email and redirect to confirmation
      FFAppState().registerEmail = email;
      if (context.mounted) {
        context.pushNamed('email-confirm');
      }
      return "Por favor confirma tu email antes de continuar.";
    } else if (errorMessage.contains('too_many_requests')) {
      return "Demasiados intentos. Por favor espera unos minutos.";
    } else if (errorMessage.contains('user_not_found')) {
      return "No existe una cuenta con este email. Regístrate primero.";
    } else if (errorMessage.contains('signup_disabled')) {
      return "El acceso está temporalmente deshabilitado.";
    } else if (errorMessage.contains('captcha_required')) {
      return "Verificación de seguridad requerida. Intenta más tarde.";
    } else if (errorMessage.contains('network')) {
      return "Error de conexión. Verifica tu internet.";
    } else if (errorMessage.contains('account_disabled')) {
      return "Tu cuenta ha sido deshabilitada. Contacta soporte.";
    } else if (errorMessage.contains('password_reset_required')) {
      return "Necesitas restablecer tu contraseña. Revisa tu email.";
    }

    // Generic error fallback
    return "Error en el inicio de sesión. Por favor intenta de nuevo.";
  }
}
