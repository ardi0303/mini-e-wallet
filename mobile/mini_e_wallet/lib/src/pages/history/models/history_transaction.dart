class HistoryTransaction {
  const HistoryTransaction({
    required this.uuid,
    required this.referenceId,
    required this.type,
    required this.amount,
    required this.transferredAt,
    required this.counterpartyName,
  });

  final String uuid;
  final String referenceId;
  final String type;
  final int amount;
  final DateTime? transferredAt;
  final String counterpartyName;

  bool get isIncoming => type == 'incoming';

  factory HistoryTransaction.fromJson(Map<String, dynamic> json) {
    final counterparty =
        json['counterparty'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return HistoryTransaction(
      uuid: json['uuid'] as String? ?? '',
      referenceId: json['reference_id'] as String? ?? '-',
      type: json['type'] as String? ?? 'outgoing',
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      transferredAt: DateTime.tryParse(json['transferred_at'] as String? ?? ''),
      counterpartyName: counterparty['name'] as String? ?? '-',
    );
  }
}

class HistoryPagination {
  const HistoryPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
    required this.sort,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int? from;
  final int? to;
  final String sort;

  factory HistoryPagination.fromJson(Map<String, dynamic> json) {
    return HistoryPagination(
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? 10,
      total: (json['total'] as num?)?.toInt() ?? 0,
      from: (json['from'] as num?)?.toInt(),
      to: (json['to'] as num?)?.toInt(),
      sort: json['sort'] as String? ?? 'desc',
    );
  }
}

class HistoryPageData {
  const HistoryPageData({required this.transactions, required this.pagination});

  final List<HistoryTransaction> transactions;
  final HistoryPagination pagination;

  factory HistoryPageData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? <dynamic>[];
    final meta = json['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return HistoryPageData(
      transactions: data
          .whereType<Map<String, dynamic>>()
          .map(HistoryTransaction.fromJson)
          .toList(),
      pagination: HistoryPagination.fromJson(meta),
    );
  }
}
