import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginUi extends ChangeNotifier {
  bool isRegister = false;
  bool loading = false;

  void toggleMode(bool v) { isRegister = v; notifyListeners(); }
  void setLoading(bool v) { loading = v; notifyListeners(); }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginUi(),
      child: Consumer<LoginUi>(
        builder: (ctx, ui, _) {
          final title = ui.isRegister ? 'Inscription' : 'Connexion';
          return Scaffold(
            appBar: AppBar(title: Text('Todo — $title')),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ToggleButtons(
                      isSelected: [ui.isRegister, !ui.isRegister],
                      onPressed: (i) => ui.toggleMode(i == 0),
                      children: const [
                        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Inscription')),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Connexion')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v)=> (v==null||v.isEmpty) ? 'Requis' : null,
                    ),
                    TextFormField(
                      controller: _pass,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                      validator: (v)=> (v==null||v.isEmpty) ? 'Requis' : null,
                    ),
                    const SizedBox(height: 16),
                    ui.loading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (!_form.currentState!.validate()) return;
                              ui.setLoading(true);
                              final ok = await context.read<AuthProvider>()
                                  .login(_email.text.trim(), _pass.text, register: ui.isRegister);
                              ui.setLoading(false);

                              if (!mounted) return;
                              if (ok) {
                                Navigator.of(context).pushReplacementNamed('/home');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Échec ${ui.isRegister ? "inscription" : "connexion"}')),
                                );
                              }
                            },
                            child: Text(ui.isRegister ? 'Créer mon compte' : 'Se connecter'),
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
