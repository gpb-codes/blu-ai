import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

const _options = <(IconData, String, String)>[
  (Icons.upload_file_outlined, 'Archivo', 'Sube un documento desde tu equipo'),
  (Icons.image_outlined, 'Imagen', 'Adjunta una captura o foto'),
  (
    Icons.table_chart_outlined,
    'Dato',
    'Comparte una tabla o conjunto de datos'
  ),
];

/// Hoja inferior de adjuntos (SPEC): el picker real llegará con el backend;
/// por ahora confirma la selección con un aviso.
void showAttachmentSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ThemeScope.of(context).surfaceContainerLow,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Adjuntar',
                style: kHeadlineMd.copyWith(
                    color: ThemeScope.of(context).onSurface,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
                'Comparte contexto con soybluia: documentos, imágenes o datos.',
                style: kBodyMd.copyWith(color: BrandColors.gris)),
            const SizedBox(height: 12),
            for (final (icon, label, hint) in _options)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      backgroundColor:
                          ThemeScope.of(context).surfaceContainerHigh,
                      content: Text('"$label" adjuntado a la conversación',
                          style: kBodyMd.copyWith(
                              color: ThemeScope.of(context).onSurface)),
                    ));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: BrandColors.cobalt.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child:
                              Icon(icon, size: 20, color: BrandColors.cobalt),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(label,
                                style: kBodyMd.copyWith(
                                    color: ThemeScope.of(context).onSurface,
                                    fontWeight: FontWeight.w500)),
                            Text(hint,
                                style: kBodyMd.copyWith(
                                    fontSize: 12, color: BrandColors.gris)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
