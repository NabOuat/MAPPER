import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class MessageReaction extends StatelessWidget {
  final String reaction;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const MessageReaction({
    super.key,
    required this.reaction,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingS,
          vertical: AppDimensions.paddingXS / 2,
        ),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.accentCyan.withAlpha(51) 
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: isSelected 
                ? AppColors.accentCyan 
                : Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              reaction,
              style: const TextStyle(fontSize: 14),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected 
                      ? AppColors.accentCyan 
                      : AppColors.secondaryGrey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
