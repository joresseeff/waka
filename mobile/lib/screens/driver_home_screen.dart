import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../models/user.dart';
import '../models/mission.dart';
import '../services/auth_service.dart';
import '../services/mission_service.dart';
import '../widgets/mission_card.dart';
import '../widgets/driver_mission_card.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen>
    with SingleTickerProviderStateMixin {
  User? _user;
  List<Mission> _available = [];
  List<Mission> _myMissions = [];
  bool _loading = true;
  late TabController _tabController;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final user = await AuthService.getCurrentUser();
      final available = await MissionService.getAvailableMissions();
      final myMissions = await MissionService.getMyMissions();
      if (!mounted) return;
      setState(() {
        _user = user;
        _available = available;
        _myMissions = myMissions;
        _isOnline = user?.isOnline ?? false;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleOnline() async {
    try {
      await MissionService.updateOnlineStatus(!_isOnline);
      setState(() => _isOnline = !_isOnline);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: WakaTheme.error),
      );
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
            Text('${_user?.firstName ?? ''} — Conducteur 🚗',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(_isOnline ? '🟢 En ligne' : '🔴 Hors ligne',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          // Toggle en ligne / hors ligne
          Switch(
            value: _isOnline,
            onChanged: (_) => _toggleOnline(),
            activeColor: WakaTheme.success,
            inactiveThumbColor: Colors.white54,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              if (!mounted) return;
              context.go('/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Disponibles (${_available.length})'),
            Tab(text: 'Mes missions (${_myMissions.length})'),
          ],
        ),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _availableTab(),
              _myMissionsTab(),
            ],
          ),
    );
  }

  Widget _availableTab() {
    if (!_isOnline) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔴', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text('Vous êtes hors ligne',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: WakaTheme.textDark),
            ),
            const SizedBox(height: 8),
            const Text('Activez le bouton pour voir les missions',
              style: TextStyle(color: WakaTheme.textGrey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _toggleOnline,
              child: const Text('Me mettre en ligne'),
            ),
          ],
        ),
      );
    }

    if (_available.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: const [
            SizedBox(height: 100),
            Center(
              child: Column(
                children: [
                  Text('🔍', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text('Aucune mission disponible',
                    style: TextStyle(color: WakaTheme.textGrey),
                  ),
                  SizedBox(height: 8),
                  Text('Tirez vers le bas pour actualiser',
                    style: TextStyle(color: WakaTheme.textGrey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _available.length,
        itemBuilder: (context, i) => DriverMissionCard(
          mission: _available[i],
          onAccept: () => _acceptMission(_available[i]),
          onNegotiate: () => _showNegotiateDialog(_available[i]),
        ),
      ),
    );
  }

  Widget _myMissionsTab() {
    if (_myMissions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📋', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('Aucune mission acceptée',
              style: TextStyle(color: WakaTheme.textGrey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myMissions.length,
        itemBuilder: (context, i) => MissionCard(
          mission: _myMissions[i],
          onTap: () => _showStatusDialog(_myMissions[i]),
        ),
      ),
    );
  }

  Future<void> _acceptMission(Mission mission) async {
    try {
      await MissionService.updateStatus(mission.id, 'accepted');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Mission acceptée !'),
          backgroundColor: WakaTheme.success,
        ),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: WakaTheme.error),
      );
    }
  }

  void _showNegotiateDialog(Mission mission) {
    final ctrl = TextEditingController(
      text: mission.priceProposed.toStringAsFixed(0),
    );
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('💰 Faire une contre-offre'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Prix proposé : ${mission.priceProposed.toStringAsFixed(0)} FCFA',
              style: const TextStyle(color: WakaTheme.textGrey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Votre prix (FCFA)',
                suffixText: 'FCFA',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              decoration: const InputDecoration(
                labelText: 'Message (optionnel)',
                hintText: 'Ex: Distance trop courte...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await MissionService.makeOffer(
                  mission.id,
                  double.parse(ctrl.text),
                  message: msgCtrl.text.isNotEmpty ? msgCtrl.text : null,
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Contre-offre envoyée !'),
                    backgroundColor: WakaTheme.success,
                  ),
                );
                _load();
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: WakaTheme.error),
                );
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(Mission mission) {
    if (!mission.isAccepted && !mission.isInProgress) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(mission.serviceLabel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📍 ${mission.fromAddr}'),
            if (mission.fromLandmark != null)
              Text('   ${mission.fromLandmark}',
                style: const TextStyle(color: WakaTheme.textGrey, fontSize: 12),
              ),
            const SizedBox(height: 8),
            Text('🏁 ${mission.toAddr}'),
            if (mission.toLandmark != null)
              Text('   ${mission.toLandmark}',
                style: const TextStyle(color: WakaTheme.textGrey, fontSize: 12),
              ),
            const SizedBox(height: 12),
            Text('💰 ${(mission.priceFinal ?? mission.priceProposed).toStringAsFixed(0)} FCFA',
              style: const TextStyle(fontWeight: FontWeight.bold, color: WakaTheme.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
          if (mission.isAccepted)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await MissionService.updateStatus(mission.id, 'in_progress');
                _load();
              },
              child: const Text('▶ Démarrer'),
            ),
          if (mission.isInProgress)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: WakaTheme.success),
              onPressed: () async {
                Navigator.pop(ctx);
                await MissionService.updateStatus(mission.id, 'completed');
                _load();
              },
              child: const Text('✅ Terminer'),
            ),
        ],
      ),
    );
  }
}
