import 'package:flutter/material.dart';
import 'package:mini_e_wallet/src/pages/transfer/models/transfer_recipient.dart';
import 'package:mini_e_wallet/src/pages/transfer/services/transfer_api_service.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({
    super.key,
    required this.availableBalance,
    required this.onTransferSuccess,
  });

  final int availableBalance;
  final Future<void> Function() onTransferSuccess;

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _transferApiService = const TransferApiService();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Future<List<TransferRecipient>> _recipientsFuture;
  int? _selectedRecipientId;
  bool _isSubmitting = false;
  String? _generalError;

  @override
  void initState() {
    super.initState();
    _recipientsFuture = _transferApiService.fetchRecipients();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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

  int get _parsedAmount {
    final raw = _amountController.text.replaceAll('.', '').trim();
    return int.tryParse(raw) ?? 0;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _generalError = null;
    });

    if (_selectedRecipientId == null) {
      setState(() {
        _generalError = 'Pilih penerima terlebih dahulu.';
      });
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _transferApiService.submitTransfer(
        recipientUserId: _selectedRecipientId!,
        amount: _parsedAmount,
      );

      if (!mounted) {
        return;
      }

      _amountController.clear();
      setState(() {
        _selectedRecipientId = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      await widget.onTransferSuccess();
    } on TransferException catch (error) {
      setState(() {
        _generalError = error.message;
      });
    } catch (_) {
      setState(() {
        _generalError = 'Tidak dapat memproses transfer saat ini.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Dana',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Kirim saldo ke kontak Anda dengan mudah dan cepat.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 16,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 34),
          Text(
            'Pilih Penerima',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<TransferRecipient>>(
            future: _recipientsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingField();
              }

              if (snapshot.hasError) {
                return _InlineErrorCard(
                  message: snapshot.error.toString(),
                  onRetry: () {
                    setState(() {
                      _recipientsFuture = _transferApiService.fetchRecipients();
                    });
                  },
                );
              }

              final recipients = snapshot.data ?? [];

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF242220),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF343733),
                    width: 1.6,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedRecipientId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF232523),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF7D827F),
                    ),
                    hint: const Text(
                      'Pilih kontak...',
                      style: TextStyle(
                        color: Color(0xFFBDBFBE),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    items: recipients
                        .map(
                          (recipient) => DropdownMenuItem<int>(
                            value: recipient.id,
                            child: Text(
                              '${recipient.name} (${recipient.email})',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            setState(() {
                              _selectedRecipientId = value;
                              _generalError = null;
                            });
                          },
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 34),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF2A2E2B)),
              color: const Color(0xFF151816),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nominal Transfer',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  enabled: !_isSubmitting,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Rp 0',
                    hintStyle: TextStyle(
                      color: Color(0xFF8C918D),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  validator: (value) {
                    final amount =
                        int.tryParse((value ?? '').replaceAll('.', '')) ?? 0;
                    if (amount <= 0) {
                      return 'Nominal transfer harus lebih besar dari nol.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                Container(height: 1.5, color: const Color(0xFF2F3531)),
                const SizedBox(height: 22),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Saldo Tersedia',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _formatCurrency(widget.availableBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_generalError != null) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF3B1F22),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF704046)),
              ),
              child: Text(
                _generalError!,
                style: const TextStyle(
                  color: Color(0xFFF4C7CC),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 100),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF21C98A),
                foregroundColor: const Color(0xFF0B3D2A),
                disabledBackgroundColor: const Color(
                  0xFF21C98A,
                ).withValues(alpha: 0.55),
                padding: const EdgeInsets.symmetric(vertical: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 26,
                      width: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF0B3D2A),
                        ),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Kirim sekarang',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.chevron_right_rounded, size: 24),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingField extends StatelessWidget {
  const _LoadingField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFF242220),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF343733), width: 1.6),
      ),
      alignment: Alignment.center,
      child: const SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2021),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4E3A3C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onRetry, child: const Text('Muat ulang')),
        ],
      ),
    );
  }
}
