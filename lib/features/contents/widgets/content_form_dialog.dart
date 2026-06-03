import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mediahub/features/users/models/content_item.dart';

const _contentTypes = ['post', 'image', 'video'];
const _contentStatuses = ['draft', 'published', 'archived'];

String _contentTypeLabel(String type) {
  switch (type) {
    case 'image':
      return 'Immagine';
    case 'video':
      return 'Video';
    case 'post':
    default:
      return 'Post';
  }
}

String _contentStatusLabel(String status) {
  switch (status) {
    case 'published':
      return 'Pubblicato';
    case 'archived':
      return 'Archiviato';
    case 'draft':
    default:
      return 'Bozza';
  }
}

class ContentFormResult {
  final String title;
  final String type;
  final String status;
  final int? userId;
  final int? eventId;
  final List<String> mediaUrls;
  final String? postBody;
  final String? callToActionLabel;
  final String? callToActionUrl;
  final List<String> tags;

  const ContentFormResult({
    required this.title,
    required this.type,
    required this.status,
    required this.userId,
    required this.eventId,
    required this.mediaUrls,
    required this.postBody,
    required this.callToActionLabel,
    required this.callToActionUrl,
    required this.tags,
  });
}

class _SelectedMedia {
  final String reference;
  final String label;
  final Uint8List? bytes;

  const _SelectedMedia({
    required this.reference,
    required this.label,
    this.bytes,
  });
}

class ContentFormDialog extends StatefulWidget {
  final ContentItem? initial;

  const ContentFormDialog({super.key, this.initial});

  @override
  State<ContentFormDialog> createState() => _ContentFormDialogState();
}

class _ContentFormDialogState extends State<ContentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _mediaUrlCtrl;
  late final TextEditingController _postBodyCtrl;
  late final TextEditingController _ctaLabelCtrl;
  late final TextEditingController _ctaUrlCtrl;
  late final TextEditingController _tagsCtrl;
  late String _type;
  late String _status;
  List<_SelectedMedia> _selectedMedia = const [];

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _mediaUrlCtrl = TextEditingController();
    _postBodyCtrl = TextEditingController(text: c?.postBody ?? '');
    _ctaLabelCtrl = TextEditingController(text: c?.callToActionLabel ?? '');
    _ctaUrlCtrl = TextEditingController(text: c?.callToActionUrl ?? '');
    _tagsCtrl = TextEditingController(text: c?.tags.join(', ') ?? '');
    _type = c?.type ?? _contentTypes.first;
    _status = c?.status ?? _contentStatuses.first;
    _selectedMedia = [
      for (final mediaUrl in c?.mediaUrls ?? const <String>[])
        _SelectedMedia(
          reference: mediaUrl,
          label: _labelFromReference(mediaUrl),
        ),
    ];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _mediaUrlCtrl.dispose();
    _postBodyCtrl.dispose();
    _ctaLabelCtrl.dispose();
    _ctaUrlCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  String _labelFromReference(String reference) {
    final uri = Uri.tryParse(reference);
    final path = uri?.path ?? reference;
    final segments = path.split('/').where((part) => part.isNotEmpty).toList();
    return segments.isEmpty ? reference : segments.last;
  }

  bool _looksLikeImage(String reference) {
    final lower = reference.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  bool _looksLikeVideo(String reference) {
    final lower = reference.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.m4v');
  }

  String? _optionalUrlValidator(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.startsWith('file://') || text.startsWith('local://')) return null;
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'Inserisci una URL valida';
    }
    return null;
  }

  Future<void> _pickLocalMedia() async {
    try {
      final pickerType = switch (_type) {
        'image' => FileType.image,
        'video' => FileType.video,
        _ => FileType.media,
      };

      final result = await FilePicker.platform.pickFiles(
        type: pickerType,
        allowMultiple: true,
        withData: kIsWeb,
      );
      if (!mounted || result == null || result.files.isEmpty) return;

      final mediaToAdd = result.files
          .where((file) {
            if (kIsWeb) {
              return file.bytes != null;
            }
            return (file.path?.isNotEmpty ?? false) || file.bytes != null;
          })
          .map((file) {
            final reference = kIsWeb
                ? 'local://${file.name}'
                : ((file.path?.isNotEmpty ?? false)
                      ? Uri.file(file.path!).toString()
                      : 'local://${file.name}');
            return _SelectedMedia(
              reference: reference,
              label: file.name,
              bytes: file.bytes,
            );
          })
          .toList();

      if (mediaToAdd.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossibile leggere i file selezionati.'),
          ),
        );
        return;
      }

      setState(() {
        _selectedMedia = [..._selectedMedia, ...mediaToAdd];
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel caricamento locale: $e')),
      );
    }
  }

  void _addMediaUrl() {
    final value = _mediaUrlCtrl.text.trim();
    final error = _optionalUrlValidator(value);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (value.isEmpty) return;
    setState(() {
      _selectedMedia = [
        ..._selectedMedia,
        _SelectedMedia(reference: value, label: _labelFromReference(value)),
      ];
      _mediaUrlCtrl.clear();
    });
  }

  void _removeMediaAt(int index) {
    setState(() {
      _selectedMedia = [..._selectedMedia]..removeAt(index);
    });
  }

  List<String> _parseTags() {
    return _tagsCtrl.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  void _onTypeChanged(String value) {
    setState(() {
      _type = value;
      if (_type != 'post') {
        _postBodyCtrl.clear();
        _ctaLabelCtrl.clear();
        _ctaUrlCtrl.clear();
        _tagsCtrl.clear();
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if ((_type == 'image' || _type == 'video') && _selectedMedia.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Aggiungi almeno un media')));
      return;
    }

    final postBody = _postBodyCtrl.text.trim();
    final ctaLabel = _ctaLabelCtrl.text.trim();
    final ctaUrl = _ctaUrlCtrl.text.trim();

    Navigator.of(context).pop(
      ContentFormResult(
        title: _titleCtrl.text.trim(),
        type: _type,
        status: _status,
        userId: null,
        eventId: null,
        mediaUrls: _selectedMedia.map((media) => media.reference).toList(),
        postBody: postBody.isEmpty ? null : postBody,
        callToActionLabel: ctaLabel.isEmpty ? null : ctaLabel,
        callToActionUrl: ctaUrl.isEmpty ? null : ctaUrl,
        tags: _parseTags(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 860),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Modifica contenuto' : 'Nuovo contenuto',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Aggiungi testi, gallery immagini o clip video dentro l\'evento.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Titolo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Obbligatorio'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _type,
                          decoration: const InputDecoration(
                            labelText: 'Tipo',
                            border: OutlineInputBorder(),
                          ),
                          items: _contentTypes
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(_contentTypeLabel(type)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) _onTypeChanged(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: const InputDecoration(
                            labelText: 'Stato',
                            border: OutlineInputBorder(),
                          ),
                          items: _contentStatuses
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(_contentStatusLabel(status)),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _status = value ?? _status),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _MediaSection(
                    type: _type,
                    mediaUrlController: _mediaUrlCtrl,
                    selectedMedia: _selectedMedia,
                    onPickLocalMedia: _pickLocalMedia,
                    onAddMediaUrl: _addMediaUrl,
                    onRemoveMedia: _removeMediaAt,
                    looksLikeImage: _looksLikeImage,
                    looksLikeVideo: _looksLikeVideo,
                  ),
                  if (_type == 'post') ...[
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _postBodyCtrl,
                      minLines: 4,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Testo post',
                        hintText: 'Scrivi il copy del contenuto.',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Inserisci il testo del post';
                        if (text.length < 30) {
                          return 'Aggiungi almeno 30 caratteri';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _tagsCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tag',
                        hintText: 'esempio: backstage, promo, sponsor',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ctaLabelCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Testo CTA',
                              hintText: 'Es. Scopri di più',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _ctaUrlCtrl,
                            decoration: const InputDecoration(
                              labelText: 'URL CTA',
                              hintText: 'https://esempio.it',
                              border: OutlineInputBorder(),
                            ),
                            validator: _optionalUrlValidator,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annulla'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _submit,
                        child: Text(isEdit ? 'Salva' : 'Aggiungi'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaSection extends StatelessWidget {
  final String type;
  final TextEditingController mediaUrlController;
  final List<_SelectedMedia> selectedMedia;
  final VoidCallback onPickLocalMedia;
  final VoidCallback onAddMediaUrl;
  final ValueChanged<int> onRemoveMedia;
  final bool Function(String reference) looksLikeImage;
  final bool Function(String reference) looksLikeVideo;

  const _MediaSection({
    required this.type,
    required this.mediaUrlController,
    required this.selectedMedia,
    required this.onPickLocalMedia,
    required this.onAddMediaUrl,
    required this.onRemoveMedia,
    required this.looksLikeImage,
    required this.looksLikeVideo,
  });

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      'image' => 'Media immagine',
      'video' => 'Media video',
      _ => 'Media allegati',
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF9FAFB),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
            'Carica piu file dal PC oppure aggiungi URL esterni. La preview mostra cosa verra associato al contenuto.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: mediaUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Aggiungi URL media',
                    hintText: 'https://cdn.esempio.it/file.jpg',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: onAddMediaUrl,
                icon: const Icon(Icons.link_rounded),
                label: const Text('Aggiungi'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onPickLocalMedia,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(
              type == 'video'
                  ? 'Carica uno o piu video dal PC'
                  : type == 'image'
                  ? 'Carica una o piu immagini dal PC'
                  : 'Carica media dal PC',
            ),
          ),
          const SizedBox(height: 12),
          if (selectedMedia.isEmpty)
            const Text(
              'Nessun media selezionato.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < selectedMedia.length; i++)
                  _MediaPreviewCard(
                    media: selectedMedia[i],
                    onRemove: () => onRemoveMedia(i),
                    looksLikeImage: looksLikeImage,
                    looksLikeVideo: looksLikeVideo,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _MediaPreviewCard extends StatelessWidget {
  final _SelectedMedia media;
  final VoidCallback onRemove;
  final bool Function(String reference) looksLikeImage;
  final bool Function(String reference) looksLikeVideo;

  const _MediaPreviewCard({
    required this.media,
    required this.onRemove,
    required this.looksLikeImage,
    required this.looksLikeVideo,
  });

  @override
  Widget build(BuildContext context) {
    final isImage = looksLikeImage(media.reference);
    final isVideo = looksLikeVideo(media.reference);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 82,
              width: double.infinity,
              color: const Color(0xFFF3F4F6),
              alignment: Alignment.center,
              child: media.bytes != null && isImage
                  ? Image.memory(media.bytes!, fit: BoxFit.cover)
                  : Icon(
                      isVideo
                          ? Icons.smart_display_rounded
                          : isImage
                          ? Icons.image_rounded
                          : Icons.attach_file_rounded,
                      size: 30,
                      color: const Color(0xFF6B7280),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            media.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Rimuovi media',
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
