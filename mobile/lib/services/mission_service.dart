import 'api_service.dart';
import '../models/mission.dart';

class MissionService {
  static Future<Mission> createMission({
    required String service,
    required String fromAddr,
    String? fromLandmark,
    required String toAddr,
    String? toLandmark,
    String? description,
    required double priceProposed,
    required String payment,
    String scheduled = 'now',
  }) async {
    final data = await ApiService.post('/missions', {
      'service': service,
      'from_addr': fromAddr,
      if (fromLandmark != null) 'from_landmark': fromLandmark,
      'to_addr': toAddr,
      if (toLandmark != null) 'to_landmark': toLandmark,
      if (description != null) 'description': description,
      'price_proposed': priceProposed,
      'payment': payment,
      'scheduled': scheduled,
    });
    return Mission.fromJson(data);
  }

  static Future<List<Mission>> getMyMissions() async {
    final data = await ApiService.get('/missions');
    return (data as List).map((m) => Mission.fromJson(m)).toList();
  }

  static Future<List<Mission>> getAvailableMissions() async {
    final data = await ApiService.get('/missions/available');
    return (data as List).map((m) => Mission.fromJson(m)).toList();
  }

  static Future<void> updateStatus(String missionId, String status) async {
    await ApiService.put('/missions/$missionId/status', {'status': status});
  }

  static Future<void> makeOffer(String missionId, double price, {String? message}) async {
    await ApiService.post('/negotiations', {
      'mission_id': missionId,
      'price': price,
      if (message != null) 'message': message,
    });
  }

  static Future<void> acceptPrice(String missionId) async {
    await ApiService.post('/negotiations/$missionId/accept', {});
  }

  static Future<void> updateOnlineStatus(bool isOnline) async {
    await ApiService.put('/users/online', {'is_online': isOnline});
  }
}
