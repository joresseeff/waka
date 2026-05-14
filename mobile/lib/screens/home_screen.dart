import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../models/user.dart';
import '../models/mission.dart';
import '../services/auth_service.dart';
import '../services/mission_service.dart';
import '../widgets/mission_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  List<Mission> _missions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = await AuthService.getCurrentUser();
      final missions = await MissionService.getMyMissions();
      if (!mounted) return;
      setState(() {
        _user = user;
        _missions = missions;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WakaTheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bonjour, ${_user?.firstName ?? ''} 👋',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text('Libreville, Gabon 🇬🇦',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (!mounted) return;
              if (mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Services rapides
                  if (_user?.isClient == true) ...[
                    const Text('Que voulez-vous faire ?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: WakaTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _servicesGrid(),
                    const SizedBox(height: 24),
                  ],
                  // Mes missions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mes missions récentes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: WakaTheme.textDark,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/missions'),
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_missions.isEmpty)
                    _emptyState()
                  else
                    ...(_missions.take(3).map((m) => MissionCard(mission: m))),
                ],
              ),
            ),
          ),
      floatingActionButton: _user?.isClient == true
        ? FloatingActionButton.extended(
            onPressed: () => context.go('/create-mission'),
            backgroundColor: WakaTheme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Nouvelle mission',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        : null,
    );
  }

  Widget _servicesGrid() {
    final services = [
      {'icon': '🚗', 'label': 'Transport',  'value': 'transport'},
      {'icon': '🏍️', 'label': 'Mototaxi',   'value': 'mototaxi'},
      {'icon': '📦', 'label': 'Livraison',  'value': 'livraison'},
      {'icon': '🛒', 'label': 'Courses',    'value': 'courses'},
      {'icon': '🛺', 'label': 'Tricycle',   'value': 'tricycle'},
      {'icon': '🏠', 'label': 'Dépôt',      'value': 'depot'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: services.length,
      itemBuilder: (context, i) {
        final s = services[i];
        return GestureDetector(
          onTap: () => context.go('/create-mission', extra: s['value']),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s['icon']!, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 6),
                Text(s['label']!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: WakaTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Column(
        children: [
          Text('🚗', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Aucune mission pour l\'instant',
            style: TextStyle(color: WakaTheme.textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
