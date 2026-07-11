import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Data collected from a submitted [ContactForm].
class ContactFormData {
  /// Creates [ContactFormData].
  const ContactFormData({
    required this.name,
    required this.email,
    required this.subject,
    required this.body,
    this.location,
  });

  /// Sender's name.
  final String name;

  /// Sender's email address.
  final String email;

  /// Message subject.
  final String subject;

  /// Message body.
  final String body;

  /// Optionally attached location.
  final LatLng? location;
}

/// Contact form widget used by the contact screen.
class ContactForm extends StatefulWidget {
  /// Creates a [ContactForm].
  const ContactForm({
    required this.onSubmit,
    required this.onSelectLocation,
    this.initialSubject,
    this.selectedLocation,
    super.key,
  });

  /// Initial value for the subject field.
  final String? initialSubject;

  /// The currently selected location, if any.
  final LatLng? selectedLocation;

  /// Called when the user taps "地図で位置を選択".
  final VoidCallback onSelectLocation;

  /// Called with the validated form data when the user submits.
  final ValueChanged<ContactFormData> onSubmit;

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _subjectController;
  late final TextEditingController _bodyController;

  static final RegExp _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _subjectController = TextEditingController(text: widget.initialSubject);
    _bodyController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(
      ContactFormData(
        name: _nameController.text,
        email: _emailController.text,
        subject: _subjectController.text,
        body: _bodyController.text,
        location: widget.selectedLocation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '名前'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? '名前を入力してください' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'メールアドレス'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'メールアドレスを入力してください';
              }
              if (!_emailRegExp.hasMatch(value.trim())) {
                return '正しいメールアドレスを入力してください';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: '件名'),
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? '件名を入力してください' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bodyController,
            decoration: const InputDecoration(labelText: '本文'),
            maxLines: 6,
            validator: (value) =>
                (value == null || value.trim().isEmpty) ? '本文を入力してください' : null,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('位置情報'),
            subtitle: Text(
              widget.selectedLocation == null
                  ? '未選択'
                  : '緯度: ${widget.selectedLocation!.latitude}, '
                        '経度: ${widget.selectedLocation!.longitude}',
            ),
            trailing: OutlinedButton(
              onPressed: widget.onSelectLocation,
              child: const Text('地図で位置を選択'),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _handleSubmit,
            child: const Text('送信'),
          ),
        ],
      ),
    );
  }
}
