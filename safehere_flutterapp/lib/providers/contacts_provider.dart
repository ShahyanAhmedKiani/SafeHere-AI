import 'package:flutter/foundation.dart';

import '../models/trusted_contact.dart';
import '../services/contact_service.dart';

class ContactsProvider extends ChangeNotifier {
  final _service = ContactService();

  List<TrustedContact> contacts = [];
  bool loading = false;

  List<TrustedContact> get emergencyContacts =>
      contacts.where((c) => c.isEmergencyContact).toList();

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      contacts = await _service.list();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> add({
    required String name,
    required String relationship,
    String? phone,
    String? email,
  }) async {
    final created = await _service.create(name: name, relationship: relationship, phone: phone, email: email);
    contacts = [...contacts, created];
    notifyListeners();
  }

  Future<void> remove(String id) async {
    await _service.delete(id);
    contacts = contacts.where((c) => c.id != id).toList();
    notifyListeners();
  }

  Future<void> invite(String id) => _service.invite(id);
}
