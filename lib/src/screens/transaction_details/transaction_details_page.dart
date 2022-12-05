import 'package:elite_wallet/src/screens/transaction_details/textfield_list_item.dart';
import 'package:elite_wallet/src/screens/transaction_details/widgets/textfield_list_row.dart';
import 'package:elite_wallet/src/widgets/standard_list.dart';
import 'package:elite_wallet/utils/show_bar.dart';
import 'package:elite_wallet/view_model/transaction_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/src/widgets/standart_list_row.dart';
import 'package:elite_wallet/src/screens/transaction_details/blockexplorer_list_item.dart';
import 'package:elite_wallet/src/screens/transaction_details/standart_list_item.dart';
import 'package:elite_wallet/src/screens/base_page.dart';
import 'package:elite_wallet/utils/date_formatter.dart';

import 'package:hive/hive.dart';

class TransactionDetailsPage extends BasePage {
  TransactionDetailsPage({this.transactionDetailsViewModel});

  @override
  String get title => S.current.transaction_details_title;

  final TransactionDetailsViewModel transactionDetailsViewModel;

  @override
  Widget body(BuildContext context) {
    return SectionStandardList(
        sectionCount: 1,
        itemCounter: (int _) => transactionDetailsViewModel.items.length,
        itemBuilder: (_, __, index) {
          final item = transactionDetailsViewModel.items[index];

          if (item is StandartListItem) {
            return GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.value));
                showBar<void>(context,
                    S.of(context).transaction_details_copied(item.title));
              },
              child:
                  StandartListRow(title: '${item.title}:', value: item.value),
            );
          }

          if (item is BlockExplorerListItem) {
            return GestureDetector(
              onTap: item.onTap,
              child:
                  StandartListRow(title: '${item.title}:', value: item.value),
            );
          }

          if (item is TextFieldListItem) {
            return TextFieldListRow(
              title: item.title,
              value: item.value,
              onSubmitted: item.onSubmitted,
            );
          }

          return null;
        });
  }
}
