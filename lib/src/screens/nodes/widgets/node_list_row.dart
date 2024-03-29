import 'package:elite_wallet/routes.dart';
import 'package:elite_wallet/src/screens/nodes/widgets/node_indicator.dart';
import 'package:elite_wallet/src/widgets/standard_list.dart';
import 'package:elite_wallet/themes/extensions/receive_page_theme.dart';
import 'package:ew_core/node.dart';
import 'package:flutter/material.dart';
import 'package:elite_wallet/themes/extensions/filter_theme.dart';

class NodeListRow extends StandardListRow {
  NodeListRow(
      {required String title,
      required this.node,
      required void Function(BuildContext context) onTap,
      required bool isSelected,
      required this.isPow})
      : super(title: title, onTap: onTap, isSelected: isSelected);

  final Node node;
  final bool isPow;

  @override
  Widget buildTrailing(BuildContext context) {
    return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(isPow ? Routes.newPowNode : Routes.newNode,
            arguments: {'editingNode': node, 'isSelected': isSelected}),
        child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                                  .extension<ReceivePageTheme>()!
                                  .iconsBackgroundColor),
            child: Icon(Icons.edit,
                size: 14,
                color: Theme.of(context)
                                  .extension<ReceivePageTheme>()!
                                  .iconsColor)));
  }
}

class NodeHeaderListRow extends StandardListRow {
  NodeHeaderListRow({required String title, required void Function(BuildContext context) onTap})
      : super(title: title, onTap: onTap, isSelected: false);

  @override
  Widget buildTrailing(BuildContext context) {
    return SizedBox(
      width: 20,
      child: Icon(Icons.add,
          color: Theme.of(context).extension<FilterTheme>()!.titlesColor,size: 24.0),
    );
  }
}
