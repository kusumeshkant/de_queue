import 'package:flutter/material.dart';

class CustomSearchTextField<T> extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final List<T>? items;
  final String Function(T)? itemLabel;
  final ValueChanged<T>? onItemSelected;
  final ValueChanged<String>? onChanged;
  final bool showDropdown;
  final bool enabled;
  final Widget? prefixIcon;

  const CustomSearchTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.items,
    this.itemLabel,
    this.onItemSelected,
    this.onChanged,
    this.showDropdown = false,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  State<CustomSearchTextField<T>> createState() =>
      _CustomSearchTextFieldState<T>();
}

class _CustomSearchTextFieldState<T>
    extends State<CustomSearchTextField<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<T> _filteredItems = [];

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _fieldSize.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, _fieldSize.height + 6),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: _filteredItems.map((item) {
                return ListTile(
                  title: Text(widget.itemLabel!(item)),
                  onTap: () {
                    widget.controller.text =
                        widget.itemLabel!(item);
                    widget.onItemSelected?.call(item);
                    _removeOverlay();
                    FocusScope.of(context).unfocus();
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  Size get _fieldSize {
    final renderBox =
        context.findRenderObject() as RenderBox;
    return renderBox.size;
  }

  void _onTextChanged(String value) {
    widget.onChanged?.call(value);

    if (!widget.showDropdown || widget.items == null) return;

    _filteredItems = widget.items!
        .where((item) => widget
            .itemLabel!(item)
            .toLowerCase()
            .contains(value.toLowerCase()))
        .toList();

    if (_filteredItems.isEmpty) {
      _removeOverlay();
    } else {
      _removeOverlay();
      _showOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: widget.controller,
        enabled: widget.enabled,
        onChanged: _onTextChanged,

        /// WHITE INPUT TEXT
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),

        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: widget.prefixIcon,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
