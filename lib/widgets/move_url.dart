import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../fonts.dart';

class MoveUrl extends StatefulWidget {
  const MoveUrl({super.key});

  @override
  State<MoveUrl> createState() => _MoveUrlState();
}

class _MoveUrlState extends State<MoveUrl> {
  final Uri _url = Uri.parse('https://www.buymeacoffee.com/bovod');
  final Uri _urlKo = Uri.parse('https://toss.me/bovod1');

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: ListTile(
          leading: const Icon(
            Icons.thumb_up_outlined,
            size: 30,
            color: Colors.black,
          ),
          onTap: () async {
            if (AppLocalizations.of(context)!.localeName == 'ko') {
              if (await canLaunchUrl(_urlKo)) await launchUrl(_urlKo);
            } else {
              if (await canLaunchUrl(_url)) await launchUrl(_url);
            }
          },
          title: Text(
            'Donation',
            style: en28
          ),
        ),
      ),
    );
  }
}
