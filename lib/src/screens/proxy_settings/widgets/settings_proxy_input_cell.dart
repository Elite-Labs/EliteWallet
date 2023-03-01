import 'package:flutter/cupertino.dart';
import 'package:elite_wallet/src/widgets/standard_list.dart';
import 'package:elite_wallet/src/widgets/proxy_input_widget.dart';
import 'package:elite_wallet/src/screens/proxy_settings/proxy_input_type.dart';


class SettingsProxyInputCell extends StandardListRow {
  SettingsProxyInputCell(
      {required this.type, required this.value, this.onValueChange,
       required this.enabled})
      : super(title: "", isSelected: false);

  final ProxyInputType type;
  final String value;
  final void Function(BuildContext context, String value)? onValueChange;
  final bool enabled;

  @override
  Widget build(BuildContext context) => ProxyInputWidget(
      type: type,
      value: value,
      onTextChange: (value) => onValueChange?.call(context, value),
      enabled: enabled);
}
