import 'package:flutter/material.dart';

class SettingsDialog extends StatelessWidget {
  SettingsDialog({
    Key key,
    @required String connection,
  }) : super(key: key) {
    controller.text = connection;
  }

  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Settings'),
      contentPadding: const EdgeInsets.all(10),
      children: <Widget>[
        TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Endpoint'),
        ),
        RaisedButton(
          child: Text("Connect"),
          onPressed: () {
            Navigator.pop(context, controller.text);
          },
        )
      ],
    );
  }
}