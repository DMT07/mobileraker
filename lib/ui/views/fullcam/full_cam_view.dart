import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobileraker/domain/webcam_setting.dart';
import 'package:mobileraker/ui/components/interactive_viewer_center.dart';
import 'package:mobileraker/ui/components/mjpeg.dart';
import 'package:mobileraker/ui/views/fullcam/full_cam_viewmodel.dart';
import 'package:stacked/stacked.dart';

class FullCamView extends ViewModelBuilderWidget<FullCamViewModel> {
  final WebcamSetting webcamSetting;

  FullCamView(this.webcamSetting);

  @override
  FullCamViewModel viewModelBuilder(BuildContext context) =>
      FullCamViewModel(this.webcamSetting);

  @override
  Widget builder(BuildContext context, FullCamViewModel model, Widget? child) {
    return Scaffold(
      body: Container(
        child: Stack(alignment: Alignment.center, children: [
          CenterInteractiveViewer(
              constrained: true,
              minScale: 1,
              maxScale: 10,
              child: Mjpeg(
                key: ValueKey(model.selectedCam.url),
                feedUri: model.selectedCam.url,
                showFps: true,
                transform: model.transformMatrix,
                stackChildren: [
                  if (model.dataReady)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                            margin: EdgeInsets.only(top: 5, left: 2),
                            child: Text(
                              '${model.nozzleString} \n'
                              '${model.bedString}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary),
                            )),
                      ),
                    ),
                  if (model.showProgress)
                    Positioned.fill(
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: LinearProgressIndicator(
                            value: model.printProgress,
                          )),
                    )
                ],
              )),
          if (model.webcams.length > 1)
            Align(
              alignment: Alignment.bottomCenter,
              child: DropdownButton(
                  value: model.selectedCam,
                  onChanged: model.onWebcamSettingSelected,
                  items: model.webcams.map((e) {
                    return DropdownMenuItem(
                      child: Text(e.name),
                      value: e,
                    );
                  }).toList()),
            ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: Icon(Icons.close_fullscreen_outlined),
              tooltip: 'general.close'.tr(),
              onPressed: model.onCloseTapped,
            ),
          ),
        ]),
      ),
    );
  }
}
