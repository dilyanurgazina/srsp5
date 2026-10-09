import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  Map<String, String> _data = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Читаем данные, сохранённые на странице регистрации
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _data = {
        'Name': prefs.getString('name') ?? '',
        'Phone': prefs.getString('phone') ?? '',
        'Email': prefs.getString('email') ?? '',
        'Life Story': prefs.getString('story') ?? '',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Info'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final e in _data.entries)
            Card(
              child: ListTile(
                title: Text(e.key),
                subtitle: Text(e.value.isEmpty ? '—' : e.value),
              ),
            ),
        ],
      ),
    );
  }
}
