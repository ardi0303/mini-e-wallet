import 'package:flutter/material.dart';
import 'package:mini_e_wallet/src/pages/home/models/dashboard_summary.dart';
import 'package:mini_e_wallet/src/pages/home/services/dashboard_api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dashboardApiService = const DashboardApiService();
  late Future<DashboardSummary> _summaryFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _dashboardApiService.fetchSummary();
  }

  Future<void> _refresh() async {
    setState(() {
      _summaryFuture = _dashboardApiService.fetchSummary();
    });

    await _summaryFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<DashboardSummary>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _DashboardErrorState(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }

            final summary = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refresh,
              color: const Color(0xFF56D7A4),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  _DashboardHeader(summary: summary),
                  const SizedBox(height: 34),
                  Text(
                    'Selamat datang, ${summary.userName}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _BalanceCard(balance: summary.walletBalance),
                  const SizedBox(height: 24),
                  const _TransferPromoCard(),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: const Color(0xFF242624),
          indicatorColor: const Color(0xFF146847),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected
                  ? const Color(0xFF9DE3C1)
                  : const Color(0xFFC2C7C3),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.compare_arrows_rounded),
              selectedIcon: Icon(Icons.compare_arrows_rounded),
              label: 'Transfer',
            ),
            NavigationDestination(
              icon: Icon(Icons.history),
              selectedIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final int balance;

  String _formatCurrency(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      final reversedIndex = digits.length - index;
      buffer.write(digits[index]);
      if (reversedIndex > 1 && reversedIndex % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 24, 24, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF242C28)),
        gradient: const LinearGradient(
          colors: [Color(0xFF171B18), Color(0xFF121513)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saldo aktif Anda',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFF4EE0A3),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _formatCurrency(balance),
            style: const TextStyle(
              color: Color(0xFF46D89B),
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferPromoCard extends StatelessWidget {
  const _TransferPromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2A2E2B)),
        color: const Color(0xFF151816),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transfer Dana',
                  style: TextStyle(
                    color: Color(0xFF46D89B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kirim dan terima dana dengan cepat dan aman ke siapa saja.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Container(
            height: 88,
            width: 88,
            decoration: BoxDecoration(
              color: const Color(0xFF0F6846),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.send_outlined,
              color: Color(0xFF63E5B1),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Color(0xFF9DA39E),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF56D7A4),
                foregroundColor: const Color(0xFF163326),
              ),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
