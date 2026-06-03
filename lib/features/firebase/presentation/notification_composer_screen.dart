import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:dgv/core/providers/game_state_providers.dart';
import 'package:dgv/core/providers/player_providers.dart';
import 'package:dgv/core/theme/dgt_colors.dart';
import 'package:dgv/features/firebase/models/notification_payload.dart';
import 'package:dgv/features/firebase/providers/firebase_providers.dart';

/// Compose and send a real-time notification to the web frontend.
///
/// Writes one doc to the Firestore [notifications] collection. The frontend
/// displays it in a ticker for 30–60 s, then marks it as read.
class NotificationComposerScreen extends ConsumerStatefulWidget {
  const NotificationComposerScreen({super.key});

  static Future<void> show(BuildContext context) => Navigator.push<void>(
    context,
    MaterialPageRoute<void>(builder: (_) => const NotificationComposerScreen()),
  );

  @override
  ConsumerState<NotificationComposerScreen> createState() =>
      _NotificationComposerScreenState();
}

class _NotificationComposerScreenState
    extends ConsumerState<NotificationComposerScreen> {
  final _controller = TextEditingController();
  bool _isSending = false;
  String? _selectedPlayerId;

  static const _templates = [
    ('🚔', 'Nueva multa expedida', 'fine'),
    ('🔥', '¡Racha en curso! Hay alguien imparable esta noche...', 'streak'),
    ('🍺', '¡Alerta MOAB! Mother Of All Beers detectada', 'moab'),
    ('✅', '¡Zona verde conseguida! Gran conducción', 'zone'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(String type) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    final payload = NotificationPayload(
      id: const Uuid().v4(),
      text: text,
      timestamp: DateTime.now(),
      type: type,
      targetPlayerId: _selectedPlayerId,
    );

    await ref.read(firebaseSyncServiceProvider).sendNotification(payload);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Only players in the current game session
    final allPlayers = ref.watch(playerListNotifierProvider).value ?? [];
    final gameState = ref.watch(gameStateNotifierProvider).value;
    final activePlayers = gameState != null && gameState.playerIds.isNotEmpty
        ? allPlayers.where((p) => gameState.playerIds.contains(p.id)).toList()
        : allPlayers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📡 Enviar Notificación'),
        backgroundColor: DGTColors.primary,
        foregroundColor: DGTColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Player selector
            if (activePlayers.isNotEmpty) ...[
              const Text(
                'PARA UN JUGADOR (opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: DGTColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final player in activePlayers)
                    FilterChip(
                      label: Text(player.name),
                      selected: _selectedPlayerId == player.id,
                      onSelected: (selected) => setState(() {
                        _selectedPlayerId = selected ? player.id : null;
                        if (selected && _controller.text.isEmpty) {
                          _controller.text = '${player.name} ';
                        }
                      }),
                      selectedColor: DGTColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: DGTColors.primary,
                    ),
                ],
              ),
              const Divider(height: 32),
            ],

            // Templates
            const Text(
              'PLANTILLAS RÁPIDAS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: DGTColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            for (final (emoji, label, type) in _templates)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(64),
                    backgroundColor: DGTColors.surface,
                    foregroundColor: DGTColors.primary,
                    side: const BorderSide(color: DGTColors.primary),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: _isSending
                      ? null
                      : () {
                          final prefix = _selectedPlayerId != null
                              ? '${activePlayers.firstWhere((p) => p.id == _selectedPlayerId).name}: '
                              : '';
                          _controller.text = '$prefix$emoji $label';
                          _send(type);
                        },
                  child: Text(
                    '$emoji $label',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

            const Divider(height: 32),
            const Text(
              'MENSAJE PERSONALIZADO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: DGTColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Escribe tu mensaje aquí...',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: DGTColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(72),
                backgroundColor: DGTColors.primary,
                foregroundColor: DGTColors.textOnPrimary,
              ),
              onPressed: _isSending ? null : () => _send('manual'),
              child: _isSending
                  ? const SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(
                        color: DGTColors.textOnPrimary,
                        strokeWidth: 3,
                      ),
                    )
                  : const Text(
                      'ENVIAR',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
