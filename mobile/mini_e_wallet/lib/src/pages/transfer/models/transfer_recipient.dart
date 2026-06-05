class TransferRecipient {
  const TransferRecipient({
    required this.id,
    required this.uuid,
    required this.name,
    required this.email,
  });

  final int id;
  final String uuid;
  final String name;
  final String email;

  factory TransferRecipient.fromJson(Map<String, dynamic> json) {
    return TransferRecipient(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '-',
      email: json['email'] as String? ?? '-',
    );
  }
}
