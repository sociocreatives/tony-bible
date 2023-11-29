// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ShowProgressDialog{
  late ProgressDialog pr;

  ShowProgressDialog(BuildContext context){
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.download,
      textDirection: TextDirection.rtl,
      isDismissible: true,
    );
    pr.style(
        message: 'Please Wait...',
        borderRadius: 10.0,
        backgroundColor: Theme.of(context).primaryColor,
        progressWidget: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600)
    );
  }

  Future<void> show() async{
    await pr.show();
  }

  Future<void> hide() async{
    await pr.hide();
  }

}