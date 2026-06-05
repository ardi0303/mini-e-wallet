import 'package:flutter/material.dart';
import 'package:mini_e_wallet/src/pages/auth/login_page.dart';
import 'package:mini_e_wallet/src/pages/auth/services/auth_api_service.dart';
import 'package:mini_e_wallet/src/pages/home/models/dashboard_summary.dart';
import 'package:mini_e_wallet/src/pages/home/services/dashboard_api_service.dart';
import 'package:mini_e_wallet/src/widgets/app_bottom_nav.dart';
import 'package:mini_e_wallet/src/widgets/app_top_nav.dart';
import 'package:mini_e_wallet/src/pages/transfer/transfer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dashboardApiService = const DashboardApiService();
  final _authApiService = const AuthApiService();
  late Future<DashboardSummary> _summaryFuture;
  int _currentIndex = 0;
  bool _isLoggingOut = false;

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

  Future<void> _handleLogout() async {
    if (_isLoggingOut) {
      return;
    }

    setState(() {
      _isLoggingOut = true;
    });

    await _authApiService.logout();

    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _showProfileMenu(
    TapDownDetails details,
    DashboardSummary summary,
  ) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      color: const Color(0xFF232523),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: const BorderSide(color: Color(0xFF343733)),
      ),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          details.globalPosition.dx,
          details.globalPosition.dy + 12,
          0,
          0,
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: SizedBox(
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  summary.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  summary.userEmail,
                  style: const TextStyle(
                    color: Color(0xFFB3B8B4),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'logout',
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Color(0xFF53D8A2),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                _isLoggingOut ? 'Logging out...' : 'Log Out',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (result == 'logout' && mounted) {
      await _handleLogout();
    }
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
                  AppTopNav(
                    summary: summary,
                    onTapDown: (details) => _showProfileMenu(details, summary),
                  ),
                  const SizedBox(height: 34),
                  ..._buildTabContent(context, summary),
                  const SizedBox(height: 80),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
      ),
    );
  }

  List<Widget> _buildTabContent(
    BuildContext context,
    DashboardSummary summary,
  ) {
    switch (_currentIndex) {
      case 1:
        return [
          TransferPage(
            availableBalance: summary.walletBalance,
            onTransferSuccess: _refresh,
          ),
        ];
      case 2:
        return const [
          _SectionTitle(title: 'Riwayat Transaksi'),
          SizedBox(height: 28),
          _FeaturePlaceholderCard(
            title: 'History',
            description:
                'Halaman history akan menampilkan transaksi dengan sorting dan pagination.',
            icon: Icons.history,
          ),
        ];
      default:
        return [
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
        ];
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final int balance;

  String _formatCurrency(int value) {
    final digits = value.toString();
    final segments = <String>[];

    for (var end = digits.length; end > 0; end -= 3) {
      final start = (end - 3).clamp(0, digits.length);
      segments.insert(0, digits.substring(start, end));
    }

    return 'Rp ${segments.join('.')}';
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
    return const _FeaturePromoCard(
      title: 'Transfer Dana',
      description: 'Kirim dan terima dana dengan cepat dan aman ke siapa saja.',
      icon: Icons.send_outlined,
    );
  }
}

class _FeaturePlaceholderCard extends StatelessWidget {
  const _FeaturePlaceholderCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return _FeaturePromoCard(
      title: title,
      description: description,
      icon: icon,
    );
  }
}

class _FeaturePromoCard extends StatelessWidget {
  const _FeaturePromoCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

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
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF46D89B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
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
            child: Icon(icon, color: const Color(0xFF63E5B1), size: 34),
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
