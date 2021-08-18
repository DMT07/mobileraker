import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:mobileraker/app/AppSetup.locator.dart';
import 'package:mobileraker/enums/BottomSheetType.dart';
import 'package:mobileraker/service/KlippyService.dart';
import 'package:mobileraker/service/MachineService.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

void setupBottomSheetUi() {
  final bottomSheetService = locator<BottomSheetService>();

  final builders = {
    BottomSheetType.ManagementMenu: (context, sheetRequest, completer) =>
        _NonPrintingBottomSheet(request: sheetRequest, completer: completer)
  };

  bottomSheetService.setCustomSheetBuilders(builders);
}

class _NonPrintingBottomSheet
    extends ViewModelBuilderWidget<NonPrintingBottomSheetViewModel> {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  const _NonPrintingBottomSheet({
    Key? key,
    required this.request,
    required this.completer,
  }) : super(key: key);

  @override
  Widget builder(BuildContext context, NonPrintingBottomSheetViewModel model,
      Widget? child) {
    var themeData = Theme.of(context);
    var isDark = themeData.brightness == Brightness.dark;
    var buttonStyle = ElevatedButton.styleFrom(
        primary: isDark ? themeData.accentColor : themeData.primaryColor,
        onSurface: Colors.pink,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ));

    return Container(
      padding: EdgeInsets.fromLTRB(25, 15, 25, 10),
      decoration: BoxDecoration(
        color: isDark ? themeData.primaryColor : Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: model.onShutdownHostPressed,
                      child: Text("Shutdown"),
                      style: buttonStyle,
                    ),
                  )),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  FlutterIcons.raspberry_pi_faw5d,
                  color: isDark? Colors.white: Colors.black,
                ),
              ),
              Flexible(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: model.onRestartHostPressed,
                      child: Text("Restart"),
                      style: buttonStyle,
                    ),
                  ))
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: model.onRestartKlipperPressed,
                child: Text("Klipper restart"),
                style: buttonStyle,
              )),
          Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: model.onRestartMoonrakerPressed,
                child: Text("Moonraker restart"),
                style: buttonStyle,
              )),
          Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: model.onRestartMCUPressed,
                child: Text("Firmware restart"),
                style: buttonStyle,
              )),
          ElevatedButton.icon(
            label: Text("Close"),
            icon: Icon(Icons.keyboard_arrow_down),
            onPressed: model.onClosePressed,
            style: buttonStyle,
          )
        ],
      ),
    );
  }

  @override
  NonPrintingBottomSheetViewModel viewModelBuilder(BuildContext context) =>
      NonPrintingBottomSheetViewModel(request, completer);
}

class NonPrintingBottomSheetViewModel extends BaseViewModel {
  final SheetRequest request;
  final Function(SheetResponse) completer;

  final _snackBarService = locator<SnackbarService>();
  final _machineService = locator<MachineService>();

  NonPrintingBottomSheetViewModel(this.request, this.completer);

  KlippyService? get _klippyService {
    return _machineService.selectedPrinter.valueOrNull?.klippyService;
  }

  onClosePressed() {
    completer(SheetResponse());
  }

  onRestartMoonrakerPressed() {
    _klippyService?.restartMoonraker();
    completer(SheetResponse());
  }

  onRestartKlipperPressed() {
    _klippyService?.restartKlipper();
    completer(SheetResponse());
  }

  onRestartMCUPressed() {
    _klippyService?.restartMCUs();
    completer(SheetResponse());
  }

  onRestartHostPressed() {
    _klippyService?.rebootHost();
    completer(SheetResponse());
  }

  onShutdownHostPressed() {
    _klippyService?.shutdownHost();
    completer(SheetResponse());
  }
}