import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediahub/features/contents/widgets/content_form_dialog.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';

String _eventStatusLabel(EventStatus status) {
  switch (status) {
    case EventStatus.live:
      return 'Live';
    case EventStatus.ended:
      return 'Concluso';
    case EventStatus.upcoming:
      return 'In programma';
  }
}

String _eventContentTypeLabel(String type) {
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

class EventFormResult {
  final String title;
  final DateTime date;
  final int attendees;
  final EventStatus status;
  final int? userId;
  final List<ContentItem> contents;

  const EventFormResult({
    required this.title,
    required this.date,
    required this.attendees,
    required this.status,
    required this.userId,
    required this.contents,
  });
}

/// Dialog per creare o modificare un evento.
class EventFormDialog extends StatefulWidget {
  final Event? initial;
  final List<User> users;
  final bool enableUserLink;

  const EventFormDialog({
    super.key,
    this.initial,
    this.users = const <User>[],
    this.enableUserLink = false,
  });

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _attendeesCtrl;
  late DateTime _date;
  late EventStatus _status;
  int? _userId;
  List<ContentItem> _contents = const <ContentItem>[];

  @override
  void initState() {
    super.initState();
    final Event? e = widget.initial;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _attendeesCtrl = TextEditingController(
      text: (e?.attendees ?? 0).toString(),
    );
    _date = e?.date ?? DateTime.now().add(const Duration(days: 1));
    _status = e?.status ?? EventStatus.upcoming;
    _userId = e?.userId;
    _contents = <ContentItem>[...?e?.contents];
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _attendeesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    setState(() {
      _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time?.hour ?? _date.hour,
        time?.minute ?? _date.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      EventFormResult(
        title: _titleCtrl.text.trim(),
        date: _date,
        attendees: int.tryParse(_attendeesCtrl.text) ?? 0,
        status: _status,
        userId: _userId,
        contents: _contents,
      ),
    );
  }

  Future<void> _openContentDialog({ContentItem? initial, int? index}) async {
    final ContentFormResult? result = await showDialog<ContentFormResult>(
      context: context,
      builder: (_) => ContentFormDialog(initial: initial),
    );
    if (result == null || !mounted) return;

    final ContentItem item = ContentItem(
      id: initial?.id ?? DateTime.now().microsecondsSinceEpoch,
      title: result.title,
      type: result.type,
      status: result.status,
      createdAt: initial?.createdAt ?? DateTime.now(),
      mediaUrls: result.mediaUrls,
      postBody: result.postBody,
      callToActionLabel: result.callToActionLabel,
      callToActionUrl: result.callToActionUrl,
      tags: result.tags,
    );

    setState(() {
      final List<ContentItem> next = <ContentItem>[..._contents];
      if (index != null) {
        next[index] = item;
      } else {
        next.add(item);
      }
      _contents = next;
    });
  }

  void _removeContent(int index) {
    setState(() {
      _contents = <ContentItem>[..._contents]..removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.initial != null;
    final DateFormat formatter = DateFormat('dd MMM yyyy · HH:mm');
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isCompact = screenWidth < 640;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 24,
        vertical: isCompact ? 12 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: isCompact ? MediaQuery.sizeOf(context).height - 60 : 800,
        ),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 16 : 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isEdit ? 'Modifica evento' : 'Nuovo evento',
                    style: TextStyle(
                      fontSize: isCompact ? 18 : 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEdit
                        ? 'Aggiorna i dettagli dell\'evento.'
                        : 'Compila i campi per creare un nuovo evento.',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Titolo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? v) =>
                        (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data e ora',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                      child: Text(formatter.format(_date)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _attendeesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Partecipanti previsti',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (String? v) {
                      final int? n = int.tryParse(v ?? '');
                      if (n == null || n < 0) return 'Numero non valido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<EventStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Stato',
                      border: OutlineInputBorder(),
                    ),
                    items: EventStatus.values
                        .map(
                          (EventStatus s) => DropdownMenuItem<EventStatus>(
                            value: s,
                            child: Text(_eventStatusLabel(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (EventStatus? v) => setState(() => _status = v ?? _status),
                  ),
                  const SizedBox(height: 18),
                  _EventContentsSection(
                    contents: _contents,
                    onAdd: () => _openContentDialog(),
                    onEdit: (int index) => _openContentDialog(
                      initial: _contents[index],
                      index: index,
                    ),
                    onDelete: _removeContent,
                  ),
                  if (widget.enableUserLink) ...<Widget>[
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int?>(
                      initialValue: _userId,
                      decoration: const InputDecoration(
                        labelText: 'Utente collegato (opzionale)',
                        border: OutlineInputBorder(),
                      ),
                      items: <DropdownMenuItem<int?>>[
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Nessuno (evento globale)'),
                        ),
                        ...widget.users.map(
                          (User u) => DropdownMenuItem<int?>(
                            value: u.id,
                            child: Text('${u.name} ${u.lastName} — ${u.email}'),
                          ),
                        ),
                      ],
                      onChanged: (int? value) => setState(() => _userId = value),
                    ),
                  ],
                  const SizedBox(height: 24),
                  isCompact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            FilledButton(
                              onPressed: _submit,
                              child: Text(isEdit ? 'Salva' : 'Crea'),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Annulla'),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Annulla'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: _submit,
                              child: Text(isEdit ? 'Salva' : 'Crea'),
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

class _EventContentsSection extends StatelessWidget {
  final List<ContentItem> contents;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  const _EventContentsSection({
    required this.contents,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 640;

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (compact)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Contenuti dell\'evento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Aggiungi contenuto'),
                ),
              ],
            )
          else
            Row(
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Contenuti dell\'evento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Aggiungi contenuto'),
                ),
              ],
            ),
          const SizedBox(height: 6),
          const Text(
            'Ogni evento puo avere piu contenuti di natura diversa, con uno o piu media.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (contents.isEmpty)
            const Text(
              'Nessun contenuto inserito per questo evento.',
              style: TextStyle(color: Colors.grey),
            )
          else
            Column(
              children: <Widget>[
                for (int i = 0; i < contents.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EventContentRow(
                      content: contents[i],
                      onEdit: () => onEdit(i),
                      onDelete: () => onDelete(i),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _EventContentRow extends StatelessWidget {
  final ContentItem content;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventContentRow({
    required this.content,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final int mediaCount = content.mediaUrls.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool compact = constraints.maxWidth < 460;

          final Container leading = Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              content.type == 'video'
                  ? Icons.smart_display_rounded
                  : content.type == 'image'
                  ? Icons.image_rounded
                  : Icons.article_rounded,
              color: const Color(0xFF4F46E5),
            ),
          );

          final Column details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                content.title,
                maxLines: compact ? 2 : 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${_eventContentTypeLabel(content.type)} · ${mediaCount == 1 ? '1 media' : '$mediaCount media'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          );

          final Row actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                tooltip: 'Modifica contenuto',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
              ),
              IconButton(
                tooltip: 'Rimuovi contenuto',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: const Color(0xFFEF4444),
              ),
            ],
          );

          if (!compact) {
            return Row(
              children: <Widget>[
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: details,
                  ),
                ),
                actions,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  leading,
                  const SizedBox(width: 12),
                  Expanded(child: details),
                ],
              ),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        },
      ),
    );
  }
}
