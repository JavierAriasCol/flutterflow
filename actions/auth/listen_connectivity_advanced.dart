// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:connectivity_plus/connectivity_plus.dart';
import '/auth/base_auth_user_provider.dart';

// Esta acción fue creada para ser usada de manera global, espera a que el árbol de widgets esté construído para proceder
Future listenConnectivityChanges() async {
  // Esperar a que el árbol de widgets esté completamente construido
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initConnectivityListener();
  });
}

void _initConnectivityListener() {
  Connectivity()
      .onConnectivityChanged
      .listen((List<ConnectivityResult> results) {
    // Manejo seguro en caso de lista vacía
    ConnectivityResult result =
        results.isNotEmpty ? results.first : ConnectivityResult.none;

    bool isConnected = result != ConnectivityResult.none;

    FFAppState().update(() {
      FFAppState().offline = !isConnected;
    });

    // If offline and user is logged in, navigate to offline screen
    if (!isConnected && loggedIn && appNavigatorKey.currentContext != null) {
      navigateToOffline(appNavigatorKey.currentContext!);
    }
  });
}



---

// Navega automáticamente a la sección de *navigateToOffline* cuando FFAppState.offline = true

// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/index.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future navigateToOffline(BuildContext context) async {
  // Navegar a pantalla offline usando GoRouter (método que funciona)
  // GoRouter.of(context).pushNamed('offline'); // Método con Go router
  context.goNamed(
    OfflineWidget.routeName, // 'offline'
    extra: {
      kTransitionInfoKey: const TransitionInfo(
        hasTransition: true,
        transitionType: PageTransitionType.fade,
        duration: Duration(milliseconds: 300),
      ),
    },
  );
}
