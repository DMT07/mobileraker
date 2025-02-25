/*
 * Copyright (c) 2023. Patrick Schmidt.
 * All rights reserved.
 */

import 'package:easy_localization/easy_localization.dart';
import 'package:mobileraker/data/dto/machine/manual_probe.dart';
import 'package:mobileraker/service/moonraker/printer_service.dart';
import 'package:mobileraker/service/ui/dialog_service.dart';
import 'package:mobileraker/service/ui/snackbar_service.dart';
import 'package:mobileraker/util/extensions/async_ext.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'manual_offset_controller.g.dart';

@riverpod
class ManualOffsetDialogController extends _$ManualOffsetDialogController {
  late DialogCompleter completer;

  bool _completed = false;

  @override
  Future<ManualProbe> build(DialogCompleter dialogCompleter) async {
    completer = dialogCompleter;
    // make sure we close the dialog once its resolved externally
    // also prevents opening the dialog by mistake!
    ref.listenSelf((previous, next) {
      if (next.valueOrFullNull?.isActive == false) {
        _complete(DialogResponse.aborted());
      }
    });

    return ref.watch(
        printerSelectedProvider.selectAsync((data) => data.manualProbe!));
  }

  onOffsetPlusPressed(double step) {
    ref
        .read(printerServiceSelectedProvider)
        .gCode('TESTZ Z=${step.abs().toStringAsFixed(3)}');
  }

  onOffsetMinusPressed(double step) {
    ref
        .read(printerServiceSelectedProvider)
        .gCode('TESTZ Z=-${step.abs().toStringAsFixed(3)}');
  }

  Future<bool> onPopTriggered() async {
    onAbortPressed();
    return false;
  }

  onAbortPressed() {
    _complete(DialogResponse.aborted());
    ref.read(printerServiceSelectedProvider).gCode('ABORT');
  }

  onAcceptPressed() {
    _complete(DialogResponse.confirmed());
    ref.read(printerServiceSelectedProvider).gCode('ACCEPT');
    ref.read(snackBarServiceProvider).show(SnackBarConfig(
        duration: const Duration(seconds: 30),
        title: tr('dialogs.manual_offset.snackbar_title'),
        message: tr('dialogs.manual_offset.snackbar_message'),
        mainButtonTitle: 'Save_Config',
        closeOnMainButtonTapped: true,
        onMainButtonTapped:
        ref.read(printerServiceSelectedProvider).saveConfig));
  }

  onHelpPressed() {
    String klipperPaperTest =
        'https://www.klipper3d.org/Bed_Level.html#the-paper-test';
    launchUrlString(klipperPaperTest, mode: LaunchMode.externalApplication);
  }

  _complete(DialogResponse response) {
    if (_completed == true) return;
    _completed = true;
    completer(response);
  }
}
