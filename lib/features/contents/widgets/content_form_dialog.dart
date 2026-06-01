import 'package:flutter/material.dart';
import 'package:mediahub/features/users/models/content_item.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';

const _contentTypes = ['post', 'image', 'video'];
const _contentStatuses = ['draft', 'published', 'archived'];

class ContentFormResult {
  final String title;
  final String type;
  final String status;
  final int? userId;
  final int? eventId;

  const ContentFormResult({
    required this.title,
    required this.type,
    required this.status,
    required this.userId,
    required this.eventId,
  });
}

class ContentFormDialog extends StatefulWidget {
  final ContentItem? initial;
  final List<User> users;
  final List<Event> events;
  final bool enableUserLink;
  final bool enableEventLink;
  final int? initialUserId;
  final int? initialEventId;

  const ContentFormDialog({
    super.key,
    this.initial,
    this.users = const [],
    this.events = const [],
    this.enableUserLink = true,
    this.enableEventLink = true,
    this.initialUserId,
    this.initialEventId,
  });

  @override
  State<ContentFormDialog> createState() => _ContentFormDialogState();
}

class _ContentFormDialogState extends State<ContentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late String _type;
  late String _status;
  int? _userId;
  int? _eventId;

  @override
  void initState() {
    super.initState();
    final c = widget.initial;
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _type = c?.type ?? _contentTypes.first;
    _status = c?.status ?? _contentStatuses.first;
    _userId = c?.userId ?? widget.initialUserId;
    _eventId = c?.eventId ?? widget.initialEventId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ContentFormResult(
        title: _titleCtrl.text.trim(),
        type: _type,
        status: _status,
        userId: _userId,
        eventId: _eventId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                  'Gestisci asset, post e media del progetto.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titolo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Obbligatorio'
                      : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: _contentTypes
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _type = value ?? _type),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Stato',
                    border: OutlineInputBorder(),
                  ),
                  items: _contentStatuses
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _status = value ?? _status),
                ),
                if (widget.enableUserLink) ...[
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int?>(
                    initialValue: _userId,
                    decoration: const InputDecoration(
                      labelText: 'Utente collegato (opzionale)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Nessuno'),
                      ),
                      ...widget.users.map(
                        (user) => DropdownMenuItem<int?>(
                          value: user.id,
                          child: Text('${user.name} ${user.lastName}'),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _userId = value),
                  ),
                ],
                if (widget.enableEventLink) ...[
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int?>(
                    initialValue: _eventId,
                    decoration: const InputDecoration(
                      labelText: 'Evento collegato (opzionale)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Nessuno'),
                      ),
                      ...widget.events.map(
                        (event) => DropdownMenuItem<int?>(
                          value: event.id,
                          child: Text('#${event.id} ${event.title}'),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _eventId = value),
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
                      child: Text(isEdit ? 'Salva' : 'Crea'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
