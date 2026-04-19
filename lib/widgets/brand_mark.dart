import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logo-style mark for auth and marketing surfaces.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.growthDark, AppColors.growth],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.growth.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.account_balance_rounded,
        color: Colors.white,
        size: size * 0.48,
      ),
    );
  }
}
