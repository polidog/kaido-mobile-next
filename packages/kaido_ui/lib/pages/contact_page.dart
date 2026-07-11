import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kaido_data/kaido_data.dart';
import 'package:kaido_ui/widgets/contact_form.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contact form screen (`/contact`).
class ContactPage extends ConsumerStatefulWidget {
  /// Creates a [ContactPage].
  const ContactPage({this.initialSubject, super.key});

  /// Initial value for the form's subject field.
  final String? initialSubject;

  @override
  ConsumerState<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends ConsumerState<ContactPage> {
  LatLng? _selectedLocation;

  Future<void> _handleSelectLocation() async {
    final result = await context.push<LatLng>(
      '/contact/map',
      extra: _selectedLocation,
    );
    if (result != null && mounted) {
      setState(() => _selectedLocation = result);
    }
  }

  Future<void> _handleSubmit(ContactFormData data) async {
    final email = ref.read(contactEmailProvider);
    final body = data.location == null
        ? data.body
        : '${data.body}\n\n位置情報: '
              '緯度 ${data.location!.latitude}, 経度 ${data.location!.longitude}';
    final mailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': data.subject,
        'body': '差出人: ${data.name} (${data.email})\n\n$body',
      },
    );

    bool launched;
    try {
      launched = await launchUrl(mailUri);
    } on Exception {
      launched = false;
    }
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('メールアプリを起動できませんでした')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('お問い合わせ')),
      body: ContactForm(
        initialSubject: widget.initialSubject,
        selectedLocation: _selectedLocation,
        onSelectLocation: _handleSelectLocation,
        onSubmit: _handleSubmit,
      ),
    );
  }
}
