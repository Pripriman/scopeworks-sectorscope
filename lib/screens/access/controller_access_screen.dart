import 'package:flutter/material.dart';

import '../../config/scope_env.dart';
import '../../runtime/backend_bus.dart';
import '../../runtime/signal_relay.dart';
import '../../runtime/trace_beacon.dart';
import '../../theme/scope_palette.dart';
import '../../theme/scope_type.dart';
import '../../widgets/scope_panel.dart';
import '../../widgets/sweep_button.dart';

class ControllerAccessScreen extends StatefulWidget {
  final VoidCallback onDone;
  const ControllerAccessScreen({super.key, required this.onDone});

  @override
  State<ControllerAccessScreen> createState() => _ControllerAccessScreenState();
}

class _ControllerAccessScreenState extends State<ControllerAccessScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _enrollMode = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (!ScopeEnv.hasBackend) {
      _toast('Controller profiles are offline right now.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      if (_enrollMode) {
        final res = await BackendBus.enrollController(_email.text.trim(), _pass.text);
        TraceBeacon.registration();
        final uid = res.user?.id;
        if (uid != null) await SignalRelay.tagController(uid);
        _toast('Profile created. Confirm via the link in your inbox.');
      } else {
        final res = await BackendBus.openWatch(_email.text.trim(), _pass.text);
        TraceBeacon.login();
        final uid = res.user?.id;
        if (uid != null) await SignalRelay.tagController(uid);
      }
      if (!mounted) return;
      widget.onDone();
    } catch (e) {
      _toast(_humanError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _humanError(Object e) {
    final s = e.toString();
    if (s.contains('Invalid login')) return 'Wrong email or password.';
    if (s.contains('already registered')) {
      return 'This email is already on watch.';
    }
    return 'Link failed. Try again.';
  }

  Future<void> _recover() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      _toast('Enter your email first, then request recovery.');
      return;
    }
    try {
      await BackendBus.recoverCredentials(email);
      _toast('Recovery link transmitted.');
    } catch (_) {
      _toast('Could not transmit recovery link.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: ScopePalette.scopeGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ScopeLink(
                    label: 'Skip',
                    onPressed: _busy ? null : widget.onDone,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.settings_input_antenna_rounded,
                    size: 40, color: ScopePalette.phosphor),
                const SizedBox(height: 14),
                Text(_enrollMode ? 'NEW CONTROLLER' : 'CONTROLLER ON WATCH',
                    style: ScopeType.title()),
                const SizedBox(height: 8),
                Text(
                  'A profile syncs your duty archive and career rating across devices and powers sector alerts. It is optional — the scope runs fully offline.',
                  style: ScopeType.body(),
                ),
                const SizedBox(height: 24),
                ScopePanel(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          style: ScopeType.bodyStrong(color: ScopePalette.readout),
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                          ),
                          validator: (v) {
                            final t = (v ?? '').trim();
                            if (t.isEmpty || !t.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pass,
                          obscureText: true,
                          autofillHints: const [AutofillHints.password],
                          style: ScopeType.bodyStrong(color: ScopePalette.readout),
                          decoration: const InputDecoration(
                            hintText: 'Passphrase',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                          validator: (v) {
                            if ((v ?? '').length < 6) {
                              return 'At least 6 characters';
                            }
                            return null;
                          },
                        ),
                        if (!_enrollMode)
                          Align(
                            alignment: Alignment.centerRight,
                            child: ScopeLink(
                              label: 'Recover access',
                              onPressed: _busy ? null : _recover,
                            ),
                          ),
                        const SizedBox(height: 8),
                        SweepButton(
                          label: _enrollMode ? 'Create profile' : 'Sign on',
                          busy: _busy,
                          onPressed: _busy ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => setState(() => _enrollMode = !_enrollMode),
                  child: Text(
                    _enrollMode
                        ? 'I already have a profile'
                        : 'New here? Create a controller profile',
                    style: ScopeType.label(color: ScopePalette.cyan),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
