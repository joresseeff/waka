class Mission {
  final String id;
  final String service;
  final String status;
  final String fromAddr;
  final String? fromLandmark;
  final String toAddr;
  final String? toLandmark;
  final String? description;
  final double priceProposed;
  final double? priceCounter;
  final double? priceFinal;
  final double commission;
  final double total;
  final String payment;
  final String scheduled;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? driver;

  Mission({
    required this.id,
    required this.service,
    required this.status,
    required this.fromAddr,
    this.fromLandmark,
    required this.toAddr,
    this.toLandmark,
    this.description,
    required this.priceProposed,
    this.priceCounter,
    this.priceFinal,
    required this.commission,
    required this.total,
    required this.payment,
    required this.scheduled,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.client,
    this.driver,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isNegotiating => status == 'negotiating';

  String get statusLabel {
    switch (status) {
      case 'pending': return 'En attente';
      case 'negotiating': return 'Négociation';
      case 'accepted': return 'Acceptée';
      case 'in_progress': return 'En cours';
      case 'completed': return 'Terminée';
      case 'cancelled': return 'Annulée';
      default: return status;
    }
  }

  String get serviceLabel {
    switch (service) {
      case 'transport': return '🚗 Transport';
      case 'mototaxi': return '🏍️ Mototaxi';
      case 'livraison': return '📦 Livraison';
      case 'courses': return '🛒 Courses';
      case 'tricycle': return '🛺 Tricycle';
      case 'depot': return '🏠 Dépôt';
      default: return service;
    }
  }

  String get paymentLabel {
    switch (payment) {
      case 'airtel_money': return '📱 Airtel Money';
      case 'moov_money': return '📱 Moov Money';
      case 'cash': return '💵 Cash';
      case 'card': return '💳 Carte';
      case 'wave': return '📱 Wave';
      default: return payment;
    }
  }

  factory Mission.fromJson(Map<String, dynamic> json) => Mission(
    id: json['id'],
    service: json['service'],
    status: json['status'],
    fromAddr: json['from_addr'],
    fromLandmark: json['from_landmark'],
    toAddr: json['to_addr'],
    toLandmark: json['to_landmark'],
    description: json['description'],
    priceProposed: (json['price_proposed'] ?? 0.0).toDouble(),
    priceCounter: json['price_counter']?.toDouble(),
    priceFinal: json['price_final']?.toDouble(),
    commission: (json['commission'] ?? 0.0).toDouble(),
    total: (json['total'] ?? 0.0).toDouble(),
    payment: json['payment'] ?? 'cash',
    scheduled: json['scheduled'] ?? 'now',
    createdAt: DateTime.parse(json['created_at']),
    acceptedAt: json['accepted_at'] != null ? DateTime.parse(json['accepted_at']) : null,
    completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
    client: json['client'],
    driver: json['driver'],
  );
}
