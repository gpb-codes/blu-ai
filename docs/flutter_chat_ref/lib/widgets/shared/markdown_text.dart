import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Renderizador markdown-lite para las respuestas del asistente: negritas,
/// cursivas, código en línea, encabezados, listas, enlaces y bloques de
/// código con botón copiar (formato similar al de ChatGPT).
class MarkdownText extends StatelessWidget {
  final String text;

  /// Estilo base del párrafo (tamaño/altura de la conversación).
  final TextStyle? style;

  const MarkdownText({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    final blocks = _splitFences(text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final block in blocks) ...[
          if (block.isCode)
            _CodeBlock(language: block.language, code: block.content)
          else
            ..._buildProse(block.content, context),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  /// Divide el texto en bloques de código (```lang ... ```) y prosa.
  static List<({bool isCode, String language, String content})>
      _splitFences(String text) {
    final result = <({bool isCode, String language, String content})>[];
    final re = RegExp(r'```(\w*)[ \t]*\n?([\s\S]*?)(?:```|$)');
    var index = 0;
    for (final m in re.allMatches(text)) {
      if (m.start > index) {
        result.add((isCode: false, language: '', content: text.substring(index, m.start)));
      }
      result.add((
        isCode: true,
        language: m.group(1) ?? '',
        content: (m.group(2) ?? '').replaceAll(RegExp(r'\n+$'), ''),
      ));
      index = m.end;
    }
    if (index < text.length) {
      result.add((isCode: false, language: '', content: text.substring(index)));
    }
    return result;
  }

  /// Párrafos, encabezados y listas a partir de un fragmento de prosa.
  List<Widget> _buildProse(String content, BuildContext context) {
    final c = ThemeScope.of(context);
    final base = style ?? TextStyle(fontSize: 16, height: 1.6, color: c.onSurface);
    final lines = content.split('\n');
    final widgets = <Widget>[];
    var i = 0;

    void flush(List<String> para) {
      if (para.isEmpty) return;
      widgets.add(Text.rich(
        TextSpan(children: _inline(para.join('\n'), c, base)),
        key: ValueKey('p${widgets.length}'),
      ));
    }

    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        i++;
        continue;
      }
      // Encabezados #, ##, ###
      final header = RegExp(r'^(#{1,3})\s+(.+)$').firstMatch(trimmed);
      if (header != null) {
        final level = header.group(1)!.length;
        widgets.add(Text.rich(
          TextSpan(children: _inline(header.group(2)!, c, base.copyWith(
            fontFamily: 'Geist',
            fontSize: level == 1 ? 19 : (level == 2 ? 17 : 16),
            fontWeight: FontWeight.w600,
            height: 1.4,
          ))),
          key: ValueKey('h${widgets.length}'),
        ));
        widgets.add(const SizedBox(height: 4));
        i++;
        continue;
      }
      // Listas con viñeta (- ) o numeradas (1. )
      final bullet = RegExp(r'^[-*]\s+(.+)$').firstMatch(trimmed);
      final numbered = RegExp(r'^\d+\.\s+(.+)$').firstMatch(trimmed);
      if (bullet != null || numbered != null) {
        final ordered = numbered != null;
        final start = ordered
            ? int.tryParse(RegExp(r'^\d+').firstMatch(trimmed)!.group(0)!) ?? 1
            : 1;
        final items = <String>[];
        while (i < lines.length) {
          final t = lines[i].trim();
          final b = RegExp(r'^[-*]\s+(.+)$').firstMatch(t);
          final n = RegExp(r'^\d+\.\s+(.+)$').firstMatch(t);
          if (t.isEmpty || (b == null && n == null)) break;
          items.add((b ?? n)!.group(1)!);
          i++;
        }
        widgets.add(Column(
          key: ValueKey('l${widgets.length}'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var k = 0; k < items.length; k++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        ordered ? '${start + k}.' : '•',
                        style: base.copyWith(
                            color: c.onSurfaceVariant,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                          TextSpan(children: _inline(items[k], c, base))),
                    ),
                  ],
                ),
              ),
          ],
        ));
        continue;
      }
      // Párrafo: acumular hasta línea vacía.
      final para = <String>[trimmed];
      i++;
      while (i < lines.length && lines[i].trim().isNotEmpty) {
        para.add(lines[i].trim());
        i++;
      }
      flush(para);
    }
    flush([]);
    return widgets;
  }

  /// Convierte formato en línea (negrita, cursiva, código, enlaces) en spans.
  List<TextSpan> _inline(String src, AppPalette c, TextStyle base) {
    final spans = <TextSpan>[];
    final re =
        RegExp(r'(\*\*.+?\*\*|\*.+?\*|`[^`]*`|\[[^\]]+\]\([^)\s]+\))');
    var index = 0;
    for (final m in re.allMatches(src)) {
      if (m.start > index) {
        spans.add(TextSpan(text: src.substring(index, m.start)));
      }
      final token = m.group(0)!;
      if (token.startsWith('**')) {
        spans.add(TextSpan(
          text: token.substring(2, token.length - 2),
          style: base.copyWith(fontWeight: FontWeight.w600),
        ));
      } else if (token.startsWith('*')) {
        spans.add(TextSpan(
          text: token.substring(1, token.length - 1),
          style: base.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (token.startsWith('`')) {
        spans.add(TextSpan(
          text: token.substring(1, token.length - 1),
          style: base.copyWith(
            fontFamily: 'JetBrainsMono',
            fontSize: (base.fontSize ?? 16) - 1,
            color: c.onSurface,
            backgroundColor: c.surfaceContainerHigh,
          ),
        ));
      } else {
        final link = RegExp(r'\[([^\]]+)\]\(([^)]+)\)').firstMatch(token);
        spans.add(TextSpan(
          text: link?.group(1) ?? token,
          style: base.copyWith(color: c.primary),
        ));
      }
      index = m.end;
    }
    if (index < src.length) {
      spans.add(TextSpan(text: src.substring(index)));
    }
    return spans;
  }
}

/// Bloque de código con encabezado (lenguaje + copiar) y fondo oscuro, al
/// estilo de ChatGPT (se mantiene oscuro también en el tema claro).
class _CodeBlock extends StatefulWidget {
  final String language;
  final String code;

  const _CodeBlock({required this.language, required this.code});

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = ThemeScope.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0F14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.language.isEmpty ? 'código' : widget.language,
                    style: kLabelMd.copyWith(
                      fontSize: 11,
                      letterSpacing: 0.4,
                      color: const Color(0xFF8E8FA3),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _copy,
                  tooltip: 'Copiar código',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    _copied ? Icons.check : Icons.content_copy_outlined,
                    size: 14,
                    color: _copied
                        ? const Color(0xFF5EB92D)
                        : const Color(0xFF8E8FA3),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: const Color(0xFF23262F)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                widget.code,
                style: kCodeSm.copyWith(color: const Color(0xFFEDEFF6)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}