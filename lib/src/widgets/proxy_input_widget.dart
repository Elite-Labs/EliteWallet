import 'package:flutter/material.dart';
import 'package:elite_wallet/src/widgets/base_text_form_field.dart';
import 'package:elite_wallet/src/screens/proxy_settings/proxy_input_type.dart';

class ProxyInputWidget extends StatefulWidget {
  ProxyInputWidget({@required this.type,
                   @required this.value,
                   @required this.onTextChange,
                   @required this.enabled});

  final ProxyInputType type;
  final String value;
  final Function(String) onTextChange;
  final bool enabled;

  @override
  State<StatefulWidget> createState() => ProxyInputState();
}

class ProxyInputState extends State<ProxyInputWidget> {
  final controller = TextEditingController();

  String get text => controller.text;

  @override
  void initState() {
    super.initState();
    controller.addListener(() => widget.onTextChange?.call(text));
    controller.text = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    TextInputType keyboardType;
    if (widget.type.isNumberWithDots()) {
      keyboardType = TextInputType.numberWithOptions(
        signed: false,
        decimal: widget.type == ProxyInputType.ipAddress);
    } else if (widget.type == ProxyInputType.password) {
      keyboardType = TextInputType.visiblePassword;
    } else {
      keyboardType = TextInputType.text;
    }

    return Row(
      children: <Widget>[
        Expanded(
          child:  Padding(
            padding: EdgeInsets.only(top: 20, left: 25, right: 25),
            child: Container(
              child: BaseTextFormField(
                controller: controller,
                keyboardType: keyboardType,
                hintText: widget.type.toString(),
                enabled: widget.enabled
              )
            )
          )
        )
      ],
    );
  }
}
