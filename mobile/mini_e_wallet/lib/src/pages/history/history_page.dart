import 'package:flutter/material.dart';
import 'package:mini_e_wallet/src/pages/history/models/history_transaction.dart';
import 'package:mini_e_wallet/src/pages/history/services/history_api_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _historyApiService = const HistoryApiService();
  late Future<HistoryPageData> _historyFuture;
  int _currentPage = 1;
  String _sort = 'desc';

  static const _monthNames = {
    1: 'Jan',
    2: 'Feb',
    3: 'Mar',
    4: 'Apr',
    5: 'Mei',
    6: 'Jun',
    7: 'Jul',
    8: 'Agu',
    9: 'Sep',
    10: 'Okt',
    11: 'Nov',
    12: 'Des',
  };

  @override
  void initState() {
    super.initState();
    _historyFuture = _loadHistory();
  }

  Future<HistoryPageData> _loadHistory() {
    return _historyApiService.fetchTransactions(
      page: _currentPage,
      sort: _sort,
      perPage: 10,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _historyFuture = _loadHistory();
    });
    await _historyFuture;
  }

  void _changeSort() {
    setState(() {
      _sort = _sort == 'desc' ? 'asc' : 'desc';
      _currentPage = 1;
      _historyFuture = _loadHistory();
    });
  }

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
      _historyFuture = _loadHistory();
    });
  }

  String _formatCurrency(int value) {
    final digits = value.toString();
    final segments = <String>[];

    for (var end = digits.length; end > 0; end -= 3) {
      final start = (end - 3).clamp(0, digits.length);
      segments.insert(0, digits.substring(start, end));
    }

    return 'Rp ${segments.join('.')}';
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _monthNames[dateTime.month] ?? '-';
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day $month $year • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<HistoryPageData>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _HistoryErrorCard(
            message: snapshot.error.toString(),
            onRetry: _refresh,
          );
        }

        final history = snapshot.data!;
        final pagination = history.pagination;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Riwayat',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _changeSort,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    side: const BorderSide(
                      color: Color(0xFF343733),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.swap_vert_rounded, size: 18),
                  label: Text(
                    'Urutkan: ${_sort == 'desc' ? 'Terbaru' : 'Terlama'}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (history.transactions.isEmpty)
              const _HistoryEmptyCard()
            else
              ...history.transactions.map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _HistoryTransactionCard(
                    transaction: transaction,
                    formatCurrency: _formatCurrency,
                    formatDate: _formatDate,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                pagination.total > 0
                    ? 'Menampilkan ${pagination.from}-${pagination.to} dari ${pagination.total} transaksi'
                    : 'Belum ada transaksi',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _HistoryPaginationRow(
              currentPage: pagination.currentPage,
              lastPage: pagination.lastPage,
              onPageSelected: _goToPage,
            ),
          ],
        );
      },
    );
  }
}

class _HistoryTransactionCard extends StatelessWidget {
  const _HistoryTransactionCard({
    required this.transaction,
    required this.formatCurrency,
    required this.formatDate,
  });

  final HistoryTransaction transaction;
  final String Function(int) formatCurrency;
  final String Function(DateTime?) formatDate;

  @override
  Widget build(BuildContext context) {
    final isIncoming = transaction.isIncoming;
    final amountColor = isIncoming
        ? const Color(0xFF46D89B)
        : const Color(0xFFF0A19C);
    final badgeColor = isIncoming
        ? const Color(0xFF13553A)
        : const Color(0xFF8F101C);
    final iconBackground = isIncoming
        ? const Color(0xFF183A2C)
        : const Color(0xFF3A1C1D);
    final iconData = isIncoming
        ? Icons.south_west_rounded
        : Icons.north_east_rounded;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF171917),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2E322F)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: amountColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIncoming
                          ? 'Transfer dari ${transaction.counterpartyName}'
                          : 'Transfer ke ${transaction.counterpartyName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatDate(transaction.transferredAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncoming ? '+' : '-'} ${formatCurrency(transaction.amount)}',
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isIncoming ? 'MASUK' : 'KELUAR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1.2, color: const Color(0xFF2D332F)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ref: #${transaction.referenceId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: Color(0xFF46D89B),
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Berhasil',
                    style: TextStyle(
                      color: Color(0xFF46D89B),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryPaginationRow extends StatelessWidget {
  const _HistoryPaginationRow({
    required this.currentPage,
    required this.lastPage,
    required this.onPageSelected,
  });

  final int currentPage;
  final int lastPage;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    final pages = List<int>.generate(lastPage, (index) => index + 1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _PageArrowButton(
          icon: Icons.chevron_left_rounded,
          enabled: currentPage > 1,
          onTap: () => onPageSelected(currentPage - 1),
        ),
        const SizedBox(width: 12),
        ...pages
            .take(5)
            .map(
              (page) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _PageNumberButton(
                  page: page,
                  isSelected: page == currentPage,
                  onTap: () => onPageSelected(page),
                ),
              ),
            ),
        const SizedBox(width: 12),
        _PageArrowButton(
          icon: Icons.chevron_right_rounded,
          enabled: currentPage < lastPage,
          onTap: () => onPageSelected(currentPage + 1),
        ),
      ],
    );
  }
}

class _PageArrowButton extends StatelessWidget {
  const _PageArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF303532)),
          color: Colors.transparent,
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : const Color(0xFF626865),
        ),
      ),
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  const _PageNumberButton({
    required this.page,
    required this.isSelected,
    required this.onTap,
  });

  final int page;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected ? const Color(0xFF56D7A4) : Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Text(
          '$page',
          style: TextStyle(
            color: isSelected ? const Color(0xFF0D3526) : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _HistoryEmptyCard extends StatelessWidget {
  const _HistoryEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF171917),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2E322F)),
      ),
      child: const Text(
        'Belum ada transaksi untuk ditampilkan.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HistoryErrorCard extends StatelessWidget {
  const _HistoryErrorCard({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
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
