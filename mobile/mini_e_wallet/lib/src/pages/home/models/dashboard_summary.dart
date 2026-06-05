class DashboardSummary {
  const DashboardSummary({
    required this.userName,
    required this.userEmail,
    required this.walletBalance,
  });

  final String userName;
  final String userEmail;
  final int walletBalance;

  String get initials {
    final parts = userName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return 'U';
    }

    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final user =
        json['data']?['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final wallet =
        user['wallet'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return DashboardSummary(
      userName: user['name'] as String? ?? '-',
      userEmail: user['email'] as String? ?? '-',
      walletBalance: (wallet['balance'] as num?)?.toInt() ?? 0,
    );
  }
}
