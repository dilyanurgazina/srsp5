import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_info_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Ключ формы: нужен, чтобы вызвать validate() у всех полей сразу
  final _formKey = GlobalKey<FormState>();

  // Controller для каждого поля: позволяет читать/очищать текст
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _storyController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();

  // FocusNode для каждого поля: управление фокусом (переход по Enter)
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _storyFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _hidePass = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    for (final c in [
      _nameController, _phoneController, _emailController,
      _storyController, _passController, _confirmController
    ]) {
      c.dispose();
    }
    for (final f in [
      _nameFocus, _phoneFocus, _emailFocus,
      _storyFocus, _passFocus, _confirmFocus
    ]) {
      f.dispose();
    }
    super.dispose();
  }

  // ---------- Валидаторы ----------
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Введите имя';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Введите номер телефона';
    if (!RegExp(r'^[0-9]+$').hasMatch(v)) return 'Только цифры';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Введите email';
    final ok = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(v.trim());
    if (!ok) return 'Неверный формат email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Введите пароль';
    if (v.length < 6) return 'Минимум 6 символов';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Подтвердите пароль';
    if (v != _passController.text) return 'Пароли не совпадают';
    return null;
  }

  // ---------- Отправка ----------
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text.trim());
    await prefs.setString('phone', _phoneController.text.trim());
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('story', _storyController.text.trim());
    await prefs.setString('password', _passController.text);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserInfoPage()),
    );
  }

  Widget _clearButton(TextEditingController c) => IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () => c.clear(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Form'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Full Name
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_phoneFocus),
                validator: _validateName,
                decoration: InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: const Icon(Icons.person),
                  suffixIcon: _clearButton(_nameController),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_emailFocus),
                validator: _validatePhone,
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  helperText: 'Phone format: (XXX)XXX-XXXX',
                  prefixIcon: const Icon(Icons.call),
                  suffixIcon: _clearButton(_phoneController),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_storyFocus),
                validator: _validateEmail,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.mail),
                ),
              ),
              const SizedBox(height: 16),

              // Life Story
              TextFormField(
                controller: _storyController,
                focusNode: _storyFocus,
                maxLines: 3,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Life Story',
                  helperText: 'Keep it short, this is just a demo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passController,
                focusNode: _passFocus,
                obscureText: _hidePass,
                maxLength: 8,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(_confirmFocus),
                validator: _validatePassword,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.security),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _hidePass ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _hidePass = !_hidePass),
                  ),
                ),
              ),

              // Confirm Password
              TextFormField(
                controller: _confirmController,
                focusNode: _confirmFocus,
                obscureText: _hideConfirm,
                maxLength: 8,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: _validateConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirm Password *',
                  prefixIcon: const Icon(Icons.edit),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _hideConfirm ? Icons.visibility : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _hideConfirm = !_hideConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400),
                  onPressed: _submit,
                  child: const Text('Submit Form',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
