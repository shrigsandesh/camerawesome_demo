import 'package:flutter/material.dart';

class ProofballDropdown extends StatefulWidget {
  final List<Color> colors;
  final void Function(Color?) onChanged;

  const ProofballDropdown({
    super.key,
    required this.colors,
    required this.onChanged,
  });

  @override
  State<ProofballDropdown> createState() => _ProofballDropdownState();
}

class _ProofballDropdownState extends State<ProofballDropdown> {
  Color? selectedColor;

  @override
  void initState() {
    super.initState();
    // Set the first color as the initial selection
    if (widget.colors.isNotEmpty) {
      selectedColor = widget.colors[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Color>(
      value: selectedColor,
      icon: const Icon(Icons.arrow_drop_down),
      underline: const SizedBox(),
      onChanged: (Color? value) {
        setState(() {
          selectedColor = value;
        });
        widget.onChanged(value);
      },
      items: widget.colors.map<DropdownMenuItem<Color>>((Color color) {
        return DropdownMenuItem<Color>(
          value: color,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        );
      }).toList(),
    );
  }
}
