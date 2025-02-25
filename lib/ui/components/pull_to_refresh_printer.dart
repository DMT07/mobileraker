/*
 * Copyright (c) 2023. Patrick Schmidt.
 * All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobileraker/data/data_source/json_rpc_client.dart';
import 'package:mobileraker/data/model/hive/machine.dart';
import 'package:mobileraker/logger.dart';
import 'package:mobileraker/service/moonraker/jrpc_client_provider.dart';
import 'package:mobileraker/service/moonraker/klippy_service.dart';
import 'package:mobileraker/service/moonraker/printer_service.dart';
import 'package:mobileraker/service/selected_machine_service.dart';
import 'package:mobileraker/ui/screens/dashboard/components/control_xyz/control_xyz_card_controller.dart';
import 'package:mobileraker/util/extensions/ref_extension.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pull_to_refresh_printer.g.dart';

@riverpod
class PullToRefreshPrinterConsumer extends _$PullToRefreshPrinterConsumer {
  @override
  void build() {
    return;
  }

  onRefresh(RefreshController refreshController) async {
    final Machine? selMachine;
    try {
      ref.invalidate(controlXYZCardControllerProvider);

      selMachine = await ref.read(selectedMachineProvider.future);

      if (selMachine == null) {
        refreshController.refreshFailed();
        return;
      }
    } catch (_) {
      refreshController.refreshFailed();
      return;
    }

    // late ProviderSubscription sub;
    ClientType clientType = ref.read(jrpcClientTypeProvider(selMachine.uuid));

    logger.i('Refreshing $clientType was PULL to REFRESH');

    ProviderSubscription<PrinterService>? printerServiceKeepAlive;
    ProviderSubscription<KlippyService>? klippyServiceKeepAlive;
    try {
      printerServiceKeepAlive =
          ref.keepAliveExternally(printerServiceProvider(selMachine.uuid));
      klippyServiceKeepAlive =
          ref.keepAliveExternally(klipperServiceProvider(selMachine.uuid));

      await klippyServiceKeepAlive.read().refreshKlippy();
      var read = ref.read(klipperProvider(selMachine.uuid));
      if (!read.hasError &&
          read.hasValue &&
          read.value!.klippyCanReceiveCommands) {
        logger.i(
            'Klippy reported ready and connected, will try to refresh printer');
        await printerServiceKeepAlive.read().refreshPrinter();
      }

      refreshController.refreshCompleted();
    } catch (e) {
      logger.w("Error while trying to refresh printer", e);
      refreshController.refreshFailed();
    } finally {
      printerServiceKeepAlive?.close();
      klippyServiceKeepAlive?.close();
    }
  }
}

class PullToRefreshPrinter extends ConsumerStatefulWidget {
  const PullToRefreshPrinter({Key? key, this.child}) : super(key: key);

  final Widget? child;

  @override
  ConsumerState createState() => _PullToRefreshPrinterState();
}

class _PullToRefreshPrinterState extends ConsumerState<PullToRefreshPrinter> {
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    var onBackground = Theme.of(context).colorScheme.onBackground;
    return SmartRefresher(
      header: ClassicHeader(
        textStyle: TextStyle(color: onBackground),
        failedIcon: Icon(Icons.error, color: onBackground),
        completeIcon: Icon(Icons.done, color: onBackground),
        idleIcon: Icon(Icons.arrow_downward, color: onBackground),
        releaseIcon: Icon(Icons.refresh, color: onBackground),
      ),
      controller: refreshController,
      onRefresh: () => ref
          .watch(pullToRefreshPrinterConsumerProvider.notifier)
          .onRefresh(refreshController),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }
}
