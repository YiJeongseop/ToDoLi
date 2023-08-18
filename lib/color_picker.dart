part of 'calendar.dart';

class _ColorPicker extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ColorPickerState();
  }
}

class _ColorPickerState extends State<_ColorPicker> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: _colorCollection.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: Icon(
                  index == _selectedColorIndex ? Icons.lens : Icons.trip_origin,
                  color: _colorCollection[index]),
              title: Text(_colorNames[index], style: (AppLocalizations.of(context)!.localeName == 'ko') ? ko26 : en22),
              onTap: () {
                setState(() {
                  _selectedColorIndex = index;
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
