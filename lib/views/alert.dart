import 'package:flutter/material.dart';

// https://zenn.dev/mamoru_takami/articles/b76b734f2d7783

class CustomAlertDialog extends StatelessWidget{
  const CustomAlertDialog({
    Key? key,
    required this.title,
    required this.contentWidget,
    this.cancelActionText,
    this.cancelAction,
    required this.defaultActionText,
    this.action,
  }) : super(key: key);

  final String title;
  final Widget contentWidget;
  final String? cancelActionText;
  final Function? cancelAction;
  final String defaultActionText;
  final Function? action;

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      title: Text(title),
      content: contentWidget,
      actions: [
        if (cancelActionText != null)
        TextButton(
          onPressed: () {
            if (cancelAction != null){
              cancelAction!();
            }
            Navigator.of(context).pop(false);
          },
          child: Text(cancelActionText!),
        ),
        TextButton(
          onPressed: () {
            if (action != null) {
              action!();
            }
            Navigator.of(context).pop(true);
          },
          child: Text(defaultActionText),
        )
      ],
    );
  }
}
