import 'package:flutter/material.dart';
import '../../services/stores.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../shared/app_card.dart';

/// Sección "Claves de API" (Settings): lista real del usuario con
/// agregar, editar y eliminar clave por proveedor (SPEC §10). Formato
/// oculto tipo sk-proj-...abcd.
class ApiKeysSection extends StatelessWidget {
  const ApiKeysSection({super.key});

  static const _providers = ['OpenAI', 'Anthropic', 'Gemini', 'Groq'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ApiKeysStore.instance,
      builder: (context, _) {
        final keys = ApiKeysStore.instance.keys;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: SectionHeader(
                        icon: Icons.key_outlined,
                        title: 'Claves de API',
                        description:
                            'Gestiona las claves de tus proveedores externos para modelos personalizados.'),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showKeyDialog(context, null),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: BrandColors.cobalt,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            Text('Añadir clave',
                                style: kLabelMd.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (keys.isEmpty)
                Text('Sin claves. Agrega una para usar modelos personalizados.',
                    style: kBodyMd.copyWith(color: BrandColors.gris))
              else
                ...keys.map((k) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _KeyRow(
                        key: ValueKey(k.id),
                        entry: k,
                        onEdit: () => _showKeyDialog(context, k),
                        onDelete: () => ApiKeysStore.instance.remove(k.id),
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  void _showKeyDialog(BuildContext context, ApiKeyEntry? existing) {
    showDialog<void>(
      context: context,
      builder: (_) => _KeyDialog(providers: _providers, existing: existing),
    );
  }
}

class _KeyDialog extends StatefulWidget {
  final List<String> providers;
  final ApiKeyEntry? existing;

  const _KeyDialog({required this.providers, this.existing});

  @override
  State<_KeyDialog> createState() => _KeyDialogState();
}

class _KeyDialogState extends State<_KeyDialog> {
  late String? _provider = widget.existing?.provider;
  late final TextEditingController _prefix =
      TextEditingController(text: widget.existing?.prefix ?? '');
  late final TextEditingController _suffix =
      TextEditingController(text: widget.existing?.suffix ?? '');

  @override
  void dispose() {
    _prefix.dispose();
    _suffix.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    InputDecoration dec(String label, {String? hint}) => InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: kLabelMd.copyWith(color: c.onSurfaceVariant),
          hintStyle: TextStyle(color: c.onSurfaceVariant.withValues(alpha: 0.5)),
          filled: true,
          fillColor: c.surfaceContainer,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: c.outlineVariant),
          ),
        );
    return AlertDialog(
      backgroundColor: c.surfaceContainerLow,
      title: Text(widget.existing == null ? 'Añadir clave' : 'Editar clave',
          style: kHeadlineMd.copyWith(color: c.onSurface)),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _provider,
              dropdownColor: c.surfaceContainerLow,
              items: widget.providers
                  .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p,
                          style: kBodyMd.copyWith(color: c.onSurface))))
                  .toList(),
              onChanged: (v) => setState(() => _provider = v),
              style: kBodyMd.copyWith(color: c.onSurface),
              decoration: dec('Proveedor'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prefix,
              style: kBodyMd.copyWith(color: c.onSurface),
              decoration: dec('Prefijo', hint: 'sk-proj'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _suffix,
              style: kBodyMd.copyWith(color: c.onSurface),
              decoration: dec('Últimos 4 dígitos', hint: 'abcd'),
            ),
            const SizedBox(height: 8),
            Text('Cifrada en el servidor (AES-256-GCM). Nunca vemos la clave.',
                style: kLabelMd.copyWith(fontSize: 11, color: BrandColors.gris)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final suffix = _suffix.text.trim().isEmpty
                ? 'abcd'
                : _suffix.text.trim();
            if (widget.existing == null) {
              ApiKeysStore.instance.add(
                _provider ?? 'OpenAI',
                _prefix.text.trim().isEmpty ? 'sk-proj' : _prefix.text.trim(),
                suffix,
              );
            } else {
              ApiKeysStore.instance.remove(widget.existing!.id);
              ApiKeysStore.instance.add(
                _provider ?? widget.existing!.provider,
                _prefix.text.trim().isEmpty ? widget.existing!.prefix : _prefix.text.trim(),
                suffix,
              );
            }
            Navigator.of(context).pop();
          },
          child: Text(widget.existing == null ? 'Añadir' : 'Guardar'),
        ),
      ],
    );
  }
}

class _KeyRow extends StatelessWidget {
  final ApiKeyEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _KeyRow({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: c.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: c.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.smart_toy_outlined,
                size: 18, color: c.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.provider,
                    style: kBodyMd.copyWith(
                        color: c.onSurface, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(entry.masked,
                    style: kCodeSm.copyWith(
                        color: c.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 18, color: c.onSurfaceVariant),
            onPressed: onEdit,
            tooltip: 'Editar',
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 18, color: c.error),
            onPressed: onDelete,
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }
}