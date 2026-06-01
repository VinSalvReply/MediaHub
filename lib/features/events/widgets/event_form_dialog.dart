import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediahub/features/users/models/event.dart';
import 'package:mediahub/features/users/models/user.dart';

class EventFormResult {
  final String title;
  final DateTime date;
  final int attendees;
  final EventStatus status;
  final int? userId;

  const EventFormResult({
    required this.title,
    required this.date,
    required this.attendees,
    required this.status,
    required this.userId,
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
    this.users = const [],
    this.enableUserLink = false,
  });

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _attendeesCtrl;
  late DateTime _date;
  late EventStatus _status;
  int? _userId;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _attendeesCtrl = TextEditingController(
      text: (e?.attendees ?? 0).toString(),
    );
    _date = e?.date ?? DateTime.now().add(const Duration(days: 1));
    _status = e?.status ?? EventStatus.upcoming;
    _userId = e?.userId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _attendeesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    final time = await showTimePicker(
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    final formatter = DateFormat('dd MMM yyyy · HH:mm');

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
                  isEdit ? 'Modifica evento' : 'Nuovo evento',
                  style: const TextStyle(
                    fontSize: 20,
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
                  validator: (v) =>
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
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
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
                        (s) => DropdownMenuItem(value: s, child: Text(s.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _status = v ?? _status),
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
                        child: Text('Nessuno (evento globale)'),
                      ),
                      ...widget.users.map(
                        (u) => DropdownMenuItem<int?>(
                          value: u.id,
                          child: Text('${u.name} ${u.lastName} — ${u.email}'),
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _userId = value),
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
