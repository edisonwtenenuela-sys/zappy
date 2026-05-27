import 'package:flutter/material.dart';
import 'package:zappy/core/i18n/app_i18n.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    widget.onLogin();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppI18n.of(context).t;

    return Scaffold(
      appBar: AppBar(title: Text(t.loginTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.welcome, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: t.email),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return t.invalidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: t.password),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return t.invalidPassword;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(t.login),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _submit,
                child: Text(t.registerMock),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
