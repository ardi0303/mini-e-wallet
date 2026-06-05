import 'package:flutter/material.dart';
import 'package:mini_e_wallet/src/pages/home/models/dashboard_summary.dart';

class AppTopNav extends StatelessWidget {
  const AppTopNav({super.key, required this.summary, required this.onTapDown});

  final DashboardSummary summary;
  final ValueChanged<TapDownDetails> onTapDown;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapDown,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: const BoxDecoration(
              color: Color(0xFF10583C),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              summary.initials,
              style: const TextStyle(
                color: Color(0xFFCFE8DA),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'E Pay',
                style: TextStyle(
                  color: Color(0xFF46D89B),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Simple Wallet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
