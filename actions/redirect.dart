// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/auth/supabase_auth/auth_util.dart';
import '/index.dart';
import 'package:go_router/go_router.dart';
import '/flutter_flow/nav/nav.dart';

/// Listener global para redirección de usuarios basado en estado de autenticación
/// y requisitos de rutas protegidas
Future redirectUserTo() async {
  // Esperar a que el árbol de widgets esté completamente construido
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initRedirectListener();
  });
}

void _initRedirectListener() {
  // Listener que se ejecuta cuando hay cambios de ruta
  if (appNavigatorKey.currentContext != null) {
    final router = GoRouter.of(appNavigatorKey.currentContext!);

    // Escuchar cambios en la ubicación del router
    router.routerDelegate.addListener(() {
      _checkAndRedirectIfNeeded();
    });

    // Ejecutar verificación inicial
    _checkAndRedirectIfNeeded();
  }
}

void _checkAndRedirectIfNeeded() async {
  final context = appNavigatorKey.currentContext;
  if (context == null || !context.mounted) return;

  try {
    // Obtener la ruta actual
    final router = GoRouter.of(context);
    final currentLocation = router.getCurrentLocation();

    // Refrescar estado de usuario para asegurar datos actuales
    await authManager.refreshUser();

    // Verificar si la ruta actual requiere autenticación
    final requiresAuth = _doesCurrentRouteRequireAuth(currentLocation);

    print(
      '🔍 RedirectListener - Current: $currentLocation, RequiresAuth: $requiresAuth, LoggedIn: $loggedIn',
    );

    // Si la ruta requiere auth y no está loggeado, redirigir a sign-in
    if (requiresAuth && !loggedIn) {
      print(
        '🚫 Usuario no autenticado en ruta protegida, redirigiendo a sign-in',
      );
      if (context.mounted) {
        context.go('/sign-in');
      }
      return;
    }

    // Si está loggeado, verificar si necesita ser redirigido basado en FFAppState
    if (loggedIn && context.mounted) {
      await _handleAuthenticatedUserRedirect(context);
    }
  } catch (e) {
    print('❌ Error en RedirectListener: $e');
  }
}

/// Determina si la ruta actual requiere autenticación
bool _doesCurrentRouteRequireAuth(String currentLocation) {
  final context = appNavigatorKey.currentContext;
  if (context == null) return false;

  try {
    final router = GoRouter.of(context);

    // Crear un AppStateNotifier temporal simulando usuario no loggeado
    final tempAppState = AppStateNotifier._();
    tempAppState.user = null; // Simular no loggeado

    // Crear un estado temporal de la ruta
    final tempState = GoRouterState(
      router.configuration,
      uri: Uri.parse(currentLocation),
      matchedLocation: currentLocation,
      name: null,
      path: currentLocation,
      fullPath: currentLocation,
      pathParameters: {},
      queryParameters: {},
      extra: null,
      error: null,
      topRoute: null,
    );

    // Buscar la ruta que coincide con la ubicación actual
    final routes = _getAllRoutes(router.configuration.routes);

    for (final route in routes) {
      if (_routeMatches(route, currentLocation)) {
        // Verificar si esta ruta tiene función redirect
        if (route.redirect != null) {
          // Llamar a la función redirect simulando usuario no loggeado
          final redirectResult = route.redirect!(context, tempState);

          // Si devuelve una redirección (no null), significa que requiere auth
          if (redirectResult != null && redirectResult.isNotEmpty) {
            return true;
          }
        }
      }
    }

    return false;
  } catch (e) {
    print('❌ Error detectando ruta protegida: $e');
    // En caso de error, ser conservador - no asumir que requiere auth
    return false;
  }
}

/// Obtiene todas las rutas recursivamente del configuration
List<GoRoute> _getAllRoutes(List<RouteBase> routes) {
  final List<GoRoute> allRoutes = [];

  for (final route in routes) {
    if (route is GoRoute) {
      allRoutes.add(route);
      // Agregar rutas anidadas recursivamente
      allRoutes.addAll(_getAllRoutes(route.routes));
    }
  }

  return allRoutes;
}

/// Verifica si una ruta coincide con la ubicación actual
bool _routeMatches(GoRoute route, String currentLocation) {
  try {
    // Verificar coincidencia exacta del path
    if (route.path == currentLocation) return true;

    // Verificar si el currentLocation comienza con el path de la ruta
    if (currentLocation.startsWith(route.path) && route.path.length > 1) {
      return true;
    }

    // Para rutas con parámetros como '/user/:id'
    final pathPattern = route.path.replaceAll(RegExp(r':\w+'), r'[^/]+');
    final regex = RegExp('^$pathPattern\$');

    return regex.hasMatch(currentLocation);
  } catch (e) {
    return false;
  }
}

/// Maneja la redirección para usuarios autenticados basado en FFAppState
Future<void> _handleAuthenticatedUserRedirect(BuildContext context) async {
  if (!context.mounted) return;

  final routeUserTo = FFAppState().routeUserTo;

  // Si no hay redirección pendiente, no hacer nada
  if (routeUserTo == null || routeUserTo.isEmpty) {
    return;
  }

  print('📍 Usuario autenticado con redirección pendiente: $routeUserTo');

  // Ejecutar redirección basada en el estado
  switch (routeUserTo) {
    case 'email-confirm':
      if (!currentUserEmailVerified && context.mounted) {
        context.goNamed(
          EmailConfirmWidget.routeName,
          extra: <String, dynamic>{
            kTransitionInfoKey: TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 300),
            ),
          },
        );
        // Limpiar la redirección pendiente
        FFAppState().routeUserTo = '';
      }
      break;

    case 'welcome':
      if (context.mounted) {
        context.goNamed(
          WelcomeWidget.routeName,
          extra: <String, dynamic>{
            kTransitionInfoKey: TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 300),
            ),
          },
        );
        FFAppState().routeUserTo = '';
      }
      break;

    case 'preonboarding-personalize':
      if (context.mounted) {
        context.goNamed(
          PreonboardingPersonalizeWidget.routeName,
          extra: <String, dynamic>{
            kTransitionInfoKey: TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 300),
            ),
          },
        );
        FFAppState().routeUserTo = '';
      }
      break;

    case 'preonboarding-names':
      if (context.mounted) {
        context.goNamed(
          PreonboardingNamesWidget.routeName,
          extra: <String, dynamic>{
            kTransitionInfoKey: TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 300),
            ),
          },
        );
        FFAppState().routeUserTo = '';
      }
      break;

    default:
      print('⚠️ Ruta de redirección no reconocida: $routeUserTo');
      break;
  }
}
