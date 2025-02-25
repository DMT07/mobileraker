/*
 * Copyright (c) 2023. Patrick Schmidt.
 * All rights reserved.
 */

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobileraker/data/data_source/json_rpc_client.dart';
import 'package:mobileraker/data/dto/server/klipper.dart';
import 'package:mobileraker/data/model/hive/machine.dart';
import 'package:mobileraker/service/moonraker/jrpc_client_provider.dart';
import 'package:mobileraker/service/moonraker/klippy_service.dart';
import 'package:mobileraker/ui/theme/theme_pack.dart';
import 'package:mobileraker/util/extensions/async_ext.dart';

class MachineStateIndicator extends ConsumerWidget {
  const MachineStateIndicator(this.machine, {Key? key}) : super(key: key);
  final Machine? machine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    KlipperInstance? klippyData;
    ClientType clientType = ClientType.local;
    ClientState? clientState;
    if (machine != null) {
      var machineUUID = machine!.uuid;
      klippyData = ref.watch(klipperProvider(machineUUID)).valueOrFullNull;
      clientType = ref.watch(jrpcClientTypeProvider(machineUUID));
      clientState =
          ref.watch(jrpcClientStateProvider(machineUUID)).valueOrFullNull;
    }
    clientState ??= ClientState.disconnected;

    KlipperState serverState =
        klippyData?.klippyState ?? KlipperState.disconnected;

    switch (clientState) {
      case ClientState.connected:
        return Tooltip(
          padding: const EdgeInsets.all(8.0),
          message: 'pages.dashboard.server_status'.tr(args: [
            serverState.name.tr(),
            klippyData?.klippyConnected ?? false
                ? tr('general.connected').toLowerCase()
                : tr('klipper_state.disconnected').toLowerCase()
          ], gender: 'available'),
          child: (clientType == ClientType.local)
              ? Icon(Icons.radio_button_on,
                  size: 10, color: _klippyStateToColor(context, serverState))
              : const Image(
                  height: 20,
                  width: 20,
                  image: AssetImage('assets/images/octo_everywhere.png'),
                ),
        );
      default:
        return Icon(Icons.radio_button_on,
            size: 10, color: _stateToColor(context, clientState));
    }
  }

  Color _klippyStateToColor(BuildContext context, KlipperState state) {
    CustomColors? customColors = Theme.of(context).extension<CustomColors>();

    switch (state) {
      case KlipperState.ready:
        return customColors?.success ?? Colors.green;
      case KlipperState.error:
        return customColors?.danger ?? Colors.red;
      case KlipperState.startup:
        return customColors?.info ?? Colors.blueAccent;
      case KlipperState.shutdown:
      case KlipperState.disconnected:
      default:
        return customColors?.warning ?? Colors.orange;
    }
  }

  Color _stateToColor(BuildContext context, ClientState state) {
    CustomColors? customColors = Theme.of(context).extension<CustomColors>();

    switch (state) {
      case ClientState.connected:
        return customColors?.success ?? Colors.green;
      case ClientState.error:
        return customColors?.danger ?? Colors.red;
      case ClientState.connecting:
        return customColors?.info ?? Colors.blueAccent;
      case ClientState.disconnected:
      default:
        return customColors?.warning ?? Colors.orange;
    }
  }
}
