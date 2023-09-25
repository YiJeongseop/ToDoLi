import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';

import '../screens/calendar.dart';
import '../fonts.dart';


class ColorPicker extends StatefulWidget {
  const ColorPicker({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ColorPickerState();
  }
}

class _ColorPickerState extends State<ColorPicker> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: (!Get.isDarkMode) ? Colors.white : const Color(0xFF505458),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          side: BorderSide(color: Colors.black, width: 1.0)
      ),
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.2),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: colorCollection.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: Icon(
                  index == selectedColorIndex ? Icons.lens : Icons.trip_origin,
                  color: colorCollection[index]),
              title: Text(colorNames[index],
                  style: (AppLocalizations.of(context)!.localeName == 'ko')
                      ? ko26.copyWith(color: Theme.of(context).primaryColorDark,)
                      : en22.copyWith(color: Theme.of(context).primaryColorDark,)),
              onTap: () {
                setState(() {
                  selectedColorIndex = index;
                });

                Future.delayed(const Duration(milliseconds: 200), () {
                  Navigator.pop(context);
                });
              },
            );
          },
        ),
      ),
    );
  }
}
