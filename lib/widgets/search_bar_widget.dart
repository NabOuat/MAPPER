import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;
  final IconData? icon;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
    this.hintText = 'Rechercher...',
    this.icon = Icons.search,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _showClearButton = _controller.text.isNotEmpty;
      });
      widget.onSearch(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardDarkBackground : AppColors.cardLightBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(widget.icon, color: AppColors.accentCyan),
          suffixIcon: _showClearButton
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _controller.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
        ),
        textAlignVertical: TextAlignVertical.center,
      ),
    );
  }
}
