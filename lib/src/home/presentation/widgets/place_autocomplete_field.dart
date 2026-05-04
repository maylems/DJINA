// src/home/presentation/widgets/place_autocomplete_field.dart
//
// Reçoit une fonction de recherche [searchFn] depuis HomeProvider
// → les résultats sont automatiquement biaisés sur la position GPS.

import 'dart:async';
import 'package:djina_debug/core/theme/app_theme.dart';
import 'package:djina_debug/src/home/domain/models/place_model.dart';
import 'package:flutter/material.dart';

class PlaceAutocompleteField extends StatefulWidget {
  final String   hintText;
  final IconData prefixIcon;
  final Color    prefixIconColor;
  final PlaceResult? initialValue;
  final void Function(PlaceResult) onPlaceSelected;
  final bool showSuffix;
  final Future<List<PlaceResult>> Function(String query) searchFn;

  const PlaceAutocompleteField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.prefixIconColor,
    required this.onPlaceSelected,
    required this.searchFn,
    this.initialValue,
    this.showSuffix = false,
  });

  @override
  State<PlaceAutocompleteField> createState() =>
      _PlaceAutocompleteFieldState();
}

class _PlaceAutocompleteFieldState
    extends State<PlaceAutocompleteField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode             _focusNode  = FocusNode();
  final LayerLink             _layerLink  = LayerLink();

  Timer?            _debounce;
  List<PlaceResult> _suggestions  = [];
  bool              _isSearching  = false;
  OverlayEntry?     _overlayEntry;
  PlaceResult?      _selectedPlace;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _selectedPlace   = widget.initialValue;
      _controller.text = widget.initialValue!.shortName;
    }

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 150), () {
          _removeOverlay();
          if (_selectedPlace != null &&
              _controller.text != _selectedPlace!.shortName) {
            _controller.text = _selectedPlace!.shortName;
          }
        });
      } else {
        if (_suggestions.isNotEmpty) _showOverlay();
      }
    });
  }

  @override
  void didUpdateWidget(PlaceAutocompleteField old) {
    super.didUpdateWidget(old);
    // Met à jour si initialValue change (ex: géoloc terminée)
    if (widget.initialValue != null &&
        widget.initialValue != _selectedPlace) {
      _selectedPlace   = widget.initialValue;
      _controller.text = widget.initialValue!.shortName;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();

    if (_selectedPlace != null && value != _selectedPlace!.shortName) {
      _selectedPlace = null;
    }

    if (value.trim().length < 2) {
      setState(() => _suggestions = []);
      _removeOverlay();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      setState(() => _isSearching = true);

      final results = await widget.searchFn(value);

      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _isSearching  = false;
      });

      if (results.isNotEmpty && _focusNode.hasFocus) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _selectPlace(PlaceResult place) {
    setState(() {
      _selectedPlace = place;
      _suggestions   = [];
    });
    _controller.text = place.shortName;
    _focusNode.unfocus();
    _removeOverlay();
    widget.onPlaceSelected(place);
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay   = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 240),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey[100]),
                itemBuilder: (_, i) {
                  final place = _suggestions[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _selectPlace(place),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                                Icons.location_on_outlined,
                                size: 17,
                                color: Colors.grey),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  place.shortName,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (place.displayName != place.shortName)
                                  Text(
                                    place.displayName,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _selectedPlace != null
                ? Colors.green.withOpacity(0.5)
                : Colors.grey[300]!,
            width: _selectedPlace != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      _selectedPlace != null
                          ? Icons.check_circle_outline
                          : widget.prefixIcon,
                      color: _selectedPlace != null
                          ? Colors.green
                          : widget.prefixIconColor,
                      size: 22,
                    ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                      color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 0, vertical: 13),
                ),
              ),
            ),
            if (widget.showSuffix)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.add, size: 20, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}