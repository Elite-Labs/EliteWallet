import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/view_model/settings/link_list_item.dart';
import 'package:elite_wallet/view_model/settings/regular_list_item.dart';
import 'package:elite_wallet/view_model/settings/settings_list_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:elite_wallet/wallet_type_utils.dart';

part 'support_view_model.g.dart';

class SupportViewModel = SupportViewModelBase with _$SupportViewModel;

abstract class SupportViewModelBase with Store {
  SupportViewModelBase()
  : items = [
      LinkListItem(
          title: 'Email',
          linkTitle: 'info@elitewallet.sc',
          link: 'info@elitewallet.sc'),
      if (!isMoneroOnly)
        LinkListItem(
            title: 'Website',
            linkTitle: 'elitewallet.sc',
            link: 'https://elitewallet.sc'),
      if (!isMoneroOnly)      
        LinkListItem(
            title: 'GitHub',
            icon: 'assets/images/github.png',
            hasIconColor: true,
            linkTitle: 'github.com/Elite-Labs/EliteWallet',
            link: 'https://github.com/Elite-Labs/EliteWallet/releases'),
      LinkListItem(
          title: 'Telegram',
          icon: 'assets/images/Telegram.png',
          linkTitle: '@elite_wallet',
          link: '@elite_wallet'),
      LinkListItem(
          title: 'Twitter',
          icon: 'assets/images/Twitter.png',
          linkTitle: '@EliteWallet',
          link: 'https://twitter.com/EliteWallet'),
      LinkListItem(
          title: 'MajesticBank',
          icon: 'assets/images/majesticbank.png',
          linkTitle: 'majesticbank.sc',
          link: 'https://majesticbank.sc/')
    ];

  static const url = 'elitewallet.sc/guide/';

  List<SettingsListItem> items;
}