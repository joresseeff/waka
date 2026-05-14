import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../services/mission_service.dart';

class CreateMissionScreen extends StatefulWidget {
  final String? initialService;
  const CreateMissionScreen({super.key, this.initialService});

  @override
  State<CreateMissionScreen> createState() => _CreateMissionScreenState();
}

class _CreateMissionScreenState extends State<CreateMissionScreen> {
  final _fromCtrl      = TextEditingController();
  final _fromLandCtrl  = TextEditingController();
  final _toCtrl        = TextEditingController();
  final _toLandCtrl    = TextEditingController();
  final _descCtrl      = TextEditingController();
  final _priceCtrl     = TextEditingController();

  String _service = 'transport';
  String _payment = 'airtel_money';
  bool _loading   = false;

  final List<Map<String, String>> _services = [
    {'value': 'transport', 'label': '🚗 Transport'},
    {'value': 'mototaxi',  'label': '🏍️ Mototaxi'},
    {'value': 'livraison', 'label': '📦 Livraison'},
    {'value': 'courses',   'label': '🛒 Courses'},
    {'value': 'tricycle',  'label': '🛺 Tricycle'},
    {'value': 'depot',     'label': '🏠 Dépôt'},
  ];

  final List<Map<String, String>> _payments = [
    {'value': 'airtel_money', 'label': '📱 Airtel Money'},
    {'value': 'moov_money',   'label': '📱 Moov Money'},
    {'value': 'cash',         'label': '💵 Cash'},
    {'value': 'card',         'label': '💳 Carte'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialService != null) {
      _service = widget.initialService!;
    }
  }

  Future<void> _create() async {
    if (_fromCtrl.text.isEmpty || _toCtrl.text.isEmpty || _priceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await MissionService.createMission(
        service: _service,
        fromAddr: _fromCtrl.text.trim(),
        fromLandmark: _fromLandCtrl.text.isNotEmpty ? _fromLandCtrl.text.trim() : null,
        toAddr: _toCtrl.text.trim(),
        toLandmark: _toLandCtrl.text.isNotEmpty ? _toLandCtrl.text.trim() : null,
        description: _descCtrl.text.isNotEmpty ? _descCtrl.text.trim() : null,
        priceProposed: double.parse(_priceCtrl.text),
        payment: _payment,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Mission créée avec succès !'),
          backgroundColor: WakaTheme.success,
        ),
      );
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: WakaTheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle mission')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type de service
            const Text('Type de service',
              style: TextStyle(fontWeight: FontWeight.bold, color: WakaTheme.textDark),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _services.map((s) {
                  final selected = _service == s['value'];
                  return GestureDetector(
                    onTap: () => setState(() => _service = s['value']!),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? WakaTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected ? WakaTheme.primary : WakaTheme.divider,
                        ),
                      ),
                      child: Text(s['label']!,
                        style: TextStyle(
                          color: selected ? Colors.white : WakaTheme.textGrey,
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Départ
            const Text('📍 Départ *',
              style: TextStyle(fontWeight: FontWeight.bold, color: WakaTheme.textDark),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fromCtrl,
              decoration: const InputDecoration(hintText: 'Adresse ou quartier'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fromLandCtrl,
              decoration: const InputDecoration(
                hintText: 'Point de repère (ex: Près du marché Mont-Bouët)',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Arrivée
            const Text('🏁 Arrivée *',
              style: TextStyle(fontWeight: FontWeight.bold, color: WakaTheme.textDark),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _toCtrl,
              decoration: const InputDecoration(hintText: 'Adresse ou quartier'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _toLandCtrl,
              decoration: const InputDecoration(
                hintText: 'Point de repère (ex: Face à la pharmacie)',
                prefixIcon: Icon(Icons.place_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            const Text('📝 Description (optionnel)',
              style: TextStyle(fontWeight: FontWeight.bold, color: WakaTheme.textDark),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(hintText: 'Précisions supplémentaires...'),
            ),
            const SizedBox(height: 16),

            // Prix proposé
            const Text('💰 Prix proposé (FCFA) *',
              style: TextStyle(fontWeight: FontWeight.bold, color: WakaTheme.textDark),
            ),
            const SizedBox(height: 4),
            const Text('Le conducteur peut faire une contre-offre',
              style: TextStyle(color: WakaTheme.textGrey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Ex: 2000',
                suffixText: 'FCFA',
              ),
            ),
            const SizedBox(height: 16),

            // Paiement
            const Text('💳 Mode de paiement',
              style: TextStyle(fontWeight: FontWeight.bold, color: WakaTheme.textDark),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _payment,
              decoration: const InputDecoration(),
              items: _payments.map((p) => DropdownMenuItem(
                value: p['value'],
                child: Text(p['label']!),
              )).toList(),
              onChanged: (v) => setState(() => _payment = v!),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _loading ? null : _create,
              child: _loading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Publier la mission'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
