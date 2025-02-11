// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Reference the dependecy
import 'package:bottom_picker/bottom_picker.dart';

Future timePickerAction(
  BuildContext context,
  Future Function() submitCallback,
) async {
  // Invoke the BottomPicker
  BottomPicker.time(
    title: 'Select Time',
    description: 'Choose an available timeslot',
    titleStyle: FlutterFlowTheme.of(context).titleLarge,
    descriptionStyle: FlutterFlowTheme.of(context).labelMedium,
    buttonSingleColor: FlutterFlowTheme.of(context).primary,
    buttonTextStyle: FlutterFlowTheme.of(context).titleSmall,
    buttonText: 'Select',
    displayButtonIcon: false,
    use24hFormat: true,
    onSubmit: (value) {
      // Set, within AppState, the selected value from the picker.
      // Within the callback ideally perform an AppState update
      // to utilise the selected time within the application
      FFAppState().selectedTime = value;
      // Perform a callback which is defined as an option argument
      submitCallback();
    },
    onClose: () {
      // will not perform callback with any value. Do nothing.
    },
  ).show(context);
}