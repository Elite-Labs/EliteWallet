
import 'package:elite_wallet/generated/i18n.dart';
import 'package:elite_wallet/typography.dart';
import 'package:elite_wallet/utils/show_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class CopyLinkItem extends StatelessWidget {
  const CopyLinkItem({super.key, required this.url, required this.title});
  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    final copyImage = Image.asset('assets/images/copy_address.png',
        color: Theme.of(context)
            .accentTextTheme!
            .displayMedium!
            .backgroundColor!);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: textMedium(
            color: Theme.of(context)
                .accentTextTheme!
                .displayMedium!
                .backgroundColor!,
          ),
        ),
        SizedBox(width: 50),
        Row(
          children: [
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: url));
                showBar<void>(context, S.of(context).copied_to_clipboard);
              },
              child: copyImage,
            ),
            SizedBox(width: 20),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              iconSize: 25,
              onPressed: () => Share.share(url),
              icon: Icon(
                Icons.share,
                color: Theme.of(context)
                    .accentTextTheme!
                    .displayMedium!
                    .backgroundColor!,
              ),
            )
          ],
        )
      ],
    );
  }
}
