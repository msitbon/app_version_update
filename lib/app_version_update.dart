library app_version_update;

import 'dart:convert';
import 'dart:io';
import 'package:app_version_update/data/enums/app_version_widgets.dart';
import 'package:app_version_update/data/models/app_version_result.dart';
import 'package:app_version_update/widgets/alert_dialog_update.dart';
import 'package:app_version_update/widgets/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/values/consts/consts.dart';

class AppVersionUpdate {
  static Future<AppVersionResult> checkForUpdates({
    String? appleId,
    String? playStoreId,
    String? country = 'us',
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (Platform.isAndroid) {
      playStoreId = playStoreId ?? packageInfo.packageName;
      final parameters = {id: playStoreId, "hl": country};
      var uri =
          Uri.https(playStoreAuthority, playStoreUndecodedPath, parameters);
      final response =
          await http.get(uri, headers: headers).catchError((e) => throw e);
      AppVersionResult appVersionResult = AppVersionResult(
          storeUrl: uri.toString(),
          storeVersion: RegExp(r',\[\[\["([0-9,\.]*)"]],')
              .firstMatch(response.body)!
              .group(1),
          platform: TargetPlatform.android);
      if (response.statusCode != 200) {
        throw " Aplication not found in Play Store, verify your app id. ";
      }
      return appVersionResult;
    } else {
      appleId = appleId ?? packageInfo.packageName;
      final parameters = {id: appleId};
      var uri = Uri.https(appleStoreAuthority, '/$country/lookup', parameters);
      final response = await http.get(uri, headers: headers);
      if (response.statusCode != 200) {
        return throw " Aplication not found in Apple Store, verify your app id. ";
      }
      final _json = json.decode(response.body);
      final List results = _json['results'];
      final appVersionResult = AppVersionResult(
          storeUrl: _json['results'].first['trackViewUrl'],
          storeVersion: _json['results'].first['version'],
          platform: TargetPlatform.iOS);
      if (results.isEmpty) {
        throw " Aplication not found in Apple Store, verify your app id. ";
      }
      return appVersionResult;
    }
  }

  static showAlertUpdate({
    @required AppVersionResult? appVersionResult,
    @required BuildContext? context,
    String? title = 'New version available',
    String? content = 'Would you like to update your application?',
    String? cancelButtonText = 'Update later',
    String? updateButtonText = 'Update',
    modalType = ShowModalType.alert_dialog,
    Color? backgroundColor = Colors.white,
    TextStyle? textStyleCancelButton = const TextStyle(color: Colors.red),
    TextStyle? textStyleUpdateButtonconst =
        const TextStyle(color: Colors.green),
    TextStyle? titleTextStyle,
    TextStyle? contentTextStyle,
    ButtonStyle? cancelButtonStyle,
    ButtonStyle? updateButtonStyle,
  }) async {
    if (modalType == ShowModalType.alert_dialog) {
      showDialog(
          context: context!,
          builder: (context) => UpdateVersionDialog(
                appVersionResult: appVersionResult,
                title: title,
                titleTextStyle: titleTextStyle,
                content: content,
                contentTextStyle: contentTextStyle,
                backgroundColor: backgroundColor,
                cancelButtonText: cancelButtonText,
                cancelButtonStyle: cancelButtonStyle,
                updateButtonText: updateButtonText,
                updateButtonStyle: updateButtonStyle,
              ));
    } else if (modalType == ShowModalType.page) {
      throw "available soon";
      // Navigator.push(context!,
      //     MaterialPageRoute(builder: (context) => const UpdateVersionPage()));
    } else if (modalType == ShowModalType.bottom_sheet) {
      throw "available soon";
    }
  }

  static showBottomSheetUpdate() async {}
  static showPageUpdate() async {}
}
