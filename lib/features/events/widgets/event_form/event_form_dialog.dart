import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediahub/core/constants/color.dart';
import 'package:mediahub/features/contents/models/content_item.dart';
import 'package:mediahub/features/contents/widgets/content_form/content_form_dialog.dart';
import 'package:mediahub/features/events/models/event.dart';
import 'package:mediahub/features/events/widgets/event_form/event_contents_section.dart';
import 'package:mediahub/features/users/models/user.dart';

String _eventStatusLabel(EventStatus status) => switch (status) {
  EventStatus.live => 'Live',
  EventStatus.ended => 'Concluso',
  EventStatus.upcoming => 'In programma',
};

/// Data returned by the create/edit event form.
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

/// Form dialog shared by event creation and editing flows.
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
  late final TextEditingController _titleController;
  late final TextEditingController _attendeesController;
  late DateTime _date;
  late EventStatus _status;
  int? _userId;
  List<ContentItem> _contents = const <ContentItem>[];

  @override
  void initState() {
    super.initState();
    final Event? event = widget.initial;
    _titleController = TextEditingController(text: event?.title ?? '');
    _attendeesController = TextEditingController(
      text: '${event?.attendees ?? 0}',
    );
    _date = event?.date ?? DateTime.now().add(const Duration(days: 1));
    _status = event?.status ?? EventStatus.upcoming;
    _userId = event?.userId;
    _contents = <ContentItem>[...?event?.contents];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _attendeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.initial != null;
    final bool compact = MediaQuery.sizeOf(context).width < 640;
    final DateFormat formatter = DateFormat('dd MMM yyyy · HH:mm');

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 24,
        vertical: compact ? 12 : 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 760,
          maxHeight: compact ? MediaQuery.sizeOf(context).height - 60 : 800,
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 16 : 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _FormIntro(isEdit: isEdit),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titolo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? value) =>
                        value == null || value.trim().isEmpty
                        ? 'Obbligatorio'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  _DateField(
                    date: _date,
                    formatter: formatter,
                    onPick: _pickDate,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _attendeesController,
                    decoration: const InputDecoration(
                      labelText: 'Partecipanti previsti',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (String? value) {
                      final int? count = int.tryParse(value ?? '');
                      return count == null || count < 0
                          ? 'Numero non valido'
                          : null;
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
                          (EventStatus status) => DropdownMenuItem<EventStatus>(
                            value: status,
                            child: Text(_eventStatusLabel(status)),
                          ),
                        )
                        .toList(),
                    onChanged: (EventStatus? value) =>
                        setState(() => _status = value ?? _status),
                  ),
                  const SizedBox(height: 18),
                  EventContentsSection(
                    contents: _contents,
                    onAdd: _addContent,
                    onEdit: _editContent,
                    onDelete: _removeContent,
                  ),
                  if (widget.enableUserLink) ...<Widget>[
                    const SizedBox(height: 14),
                    _UserLinkField(
                      userId: _userId,
                      users: widget.users,
                      onChanged: (int? value) =>
                          setState(() => _userId = value),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _FormActions(
                    isEdit: isEdit,
                    compact: compact,
                    onSubmit: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (!mounted) return;
    setState(
      () => _date = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _date.hour,
        time?.minute ?? _date.minute,
      ),
    );
  }

  Future<void> _addContent() => _editContentAt();

  Future<void> _editContent(int index) =>
      _editContentAt(initial: _contents[index], index: index);

  Future<void> _editContentAt({ContentItem? initial, int? index}) async {
    final ContentFormResult? result = await showDialog<ContentFormResult>(
      context: context,
      builder: (_) => ContentFormDialog(initial: initial),
    );
    if (result == null || !mounted) return;
    final ContentItem content = ContentItem(
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
      index == null ? next.add(content) : next[index] = content;
      _contents = next;
    });
  }

  void _removeContent(int index) {
    setState(() => _contents = <ContentItem>[..._contents]..removeAt(index));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      EventFormResult(
        title: _titleController.text.trim(),
        date: _date,
        attendees: int.tryParse(_attendeesController.text) ?? 0,
        status: _status,
        userId: _userId,
        contents: _contents,
      ),
    );
  }
}

class _FormIntro extends StatelessWidget {
  final bool isEdit;
  const _FormIntro({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          isEdit ? 'Modifica evento' : 'Nuovo evento',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          isEdit
              ? 'Aggiorna i dettagli dell\'evento.'
              : 'Compila i campi per creare un nuovo evento.',
          style: const TextStyle(color: textMutedColor),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime date;
  final DateFormat formatter;
  final VoidCallback onPick;
  const _DateField({
    required this.date,
    required this.formatter,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPick,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data e ora',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today_rounded),
        ),
        child: Text(formatter.format(date)),
      ),
    );
  }
}

class _UserLinkField extends StatelessWidget {
  final int? userId;
  final List<User> users;
  final ValueChanged<int?> onChanged;
  const _UserLinkField({
    required this.userId,
    required this.users,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int?>(
      initialValue: userId,
      decoration: const InputDecoration(
        labelText: 'Utente collegato (opzionale)',
        border: OutlineInputBorder(),
      ),
      items: <DropdownMenuItem<int?>>[
        const DropdownMenuItem<int?>(
          value: null,
          child: Text('Nessuno (evento globale)'),
        ),
        ...users.map(
          (User user) => DropdownMenuItem<int?>(
            value: user.id,
            child: Text('${user.name} ${user.lastName} - ${user.email}'),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _FormActions extends StatelessWidget {
  final bool isEdit;
  final bool compact;
  final VoidCallback onSubmit;
  const _FormActions({
    required this.isEdit,
    required this.compact,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final Widget submit = FilledButton(
      onPressed: onSubmit,
      child: Text(isEdit ? 'Salva' : 'Crea'),
    );
    final Widget cancel = TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Annulla'),
    );
    return compact
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[submit, const SizedBox(height: 8), cancel],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[cancel, const SizedBox(width: 8), submit],
          );
  }
}
