/// Constantes globales de l'application Waka

class AppConstants {
  // API
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
  // 10.0.2.2 = localhost depuis l'émulateur Android
  // En production : 'https://waka-api.railway.app/api'

  // Services disponibles
  static const List<Map<String, dynamic>> services = [
    {'id': 'transport',  'label': 'Transport',  'icon': '🚗', 'desc': 'Taxi classique'},
    {'id': 'mototaxi',   'label': 'Mototaxi',   'icon': '🏍️', 'desc': 'Rapide & économique'},
    {'id': 'livraison',  'label': 'Livraison',  'icon': '📦', 'desc': 'Colis & marchandises'},
    {'id': 'courses',    'label': 'Courses',    'icon': '🛒', 'desc': 'Faire vos courses'},
    {'id': 'tricycle',   'label': 'Tricycle',   'icon': '🛺', 'desc': 'Charges lourdes'},
    {'id': 'depot',      'label': 'Dépôt',      'icon': '🏠', 'desc': 'Stockage temporaire'},
  ];

  // Modes de paiement (Gabon)
  static const List<Map<String, dynamic>> paymentMethods = [
    {'id': 'airtel_money', 'label': 'Airtel Money', 'icon': '📱'},
    {'id': 'moov_money',   'label': 'Moov Money',   'icon': '📱'},
    {'id': 'cash',         'label': 'Cash',         'icon': '💵'},
    {'id': 'card',         'label': 'Carte bancaire','icon': '💳'},
  ];

  // Villes du Gabon
  static const List<String> gabonCities = [
    'Libreville', 'Port-Gentil', 'Franceville', 'Oyem',
    'Moanda', 'Mouila', 'Lambaréné', 'Tchibanga',
    'Koulamoutou', 'Makokou',
  ];

  // Points de repère populaires à Libreville
  static const List<String> landmarks = [
    'Marché Mont-Bouët',
    'Marché PK 5',
    'Carrefour Batterie IV',
    'Centre-ville',
    'Aéroport Léon-Mba',
    'Port-Môle',
    'Hôpital Jeanne Ebori',
    'Université Omar Bongo',
    'Carrefour IAI',
    'Ancienne Sobraga',
  ];
}
