import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/food_rush_logo.dart';
import '../welcome_screen.dart';

enum AuthFlow { choice, signup, login, otp }
enum ContactMethod { email, phone }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _auth = AuthService();
  AuthFlow _flow = AuthFlow.choice;
  ContactMethod _signupMethod = ContactMethod.email;
  ContactMethod _loginMethod = ContactMethod.email;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _optionalEmailCtrl = TextEditingController();
  final _optionalPhoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _loginContactCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  String _error = '';
  String _pendingContact = '';
  late UserModel? _pendingUser;  // Used during authentication flow
  bool _isLogin = false;
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _optionalEmailCtrl.dispose();
    _optionalPhoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _loginContactCtrl.dispose();
    _loginPassCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _goTo(AuthFlow flow) {
    setState(() {
      _flow = flow;
      _error = '';
    });
    _fadeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F3D22), Color(0xFF144E2C), Color(0xFFF16F24)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      const FoodRushLogo(size: 42),
                      const SizedBox(height: 28),
                      _glassCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _buildStep(),
      ),
    );
  }

  Widget _buildStep() {
    switch (_flow) {
      case AuthFlow.choice:
        return _choiceStep();
      case AuthFlow.signup:
        return _signupStep();
      case AuthFlow.login:
        return _loginStep();
      case AuthFlow.otp:
        return _otpStep();
    }
  }

  Widget _choiceStep() {
    return Column(
      key: const ValueKey('choice'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Khana ready hai,\ntum bas login karo',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Apna account banao ya wapas aao — Food Rush style.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        _primaryBtn('Create account', () => _goTo(AuthFlow.signup)),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _goTo(AuthFlow.login),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: const BorderSide(color: Color(0xFF144E2C), width: 1.5),
          ),
          child: const Text(
            'Login account',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }

  Widget _signupStep() {
    return Column(
      key: const ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader('Create account', 'Email ya phone se sign up karo'),
        const SizedBox(height: 16),
        _methodToggle(
          method: _signupMethod,
          onChanged: (m) => setState(() => _signupMethod = m),
        ),
        const SizedBox(height: 16),
        _field(_nameCtrl, 'Full name', Icons.person_outline_rounded),
        const SizedBox(height: 12),
        if (_signupMethod == ContactMethod.email) ...[
          _field(_emailCtrl, 'Email address', Icons.email_outlined,
              keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _field(_optionalPhoneCtrl, 'Phone (optional)', Icons.phone_outlined,
              keyboard: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 10),
        ] else ...[
          _field(_phoneCtrl, 'Phone number', Icons.phone_outlined,
              keyboard: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 10),
          const SizedBox(height: 12),
          _field(_optionalEmailCtrl, 'Email (optional)', Icons.email_outlined,
              keyboard: TextInputType.emailAddress),
        ],
        const SizedBox(height: 12),
        _field(_passCtrl, 'Password', Icons.lock_outline_rounded,
            obscure: _obscurePass,
            suffix: _eyeBtn(_obscurePass, () => setState(() => _obscurePass = !_obscurePass))),
        const SizedBox(height: 12),
        _field(_confirmCtrl, 'Confirm password', Icons.lock_outline_rounded,
            obscure: _obscureConfirm,
            suffix: _eyeBtn(_obscureConfirm,
                () => setState(() => _obscureConfirm = !_obscureConfirm))),
        if (_error.isNotEmpty) _errorBox(_error),
        const SizedBox(height: 16),
        _primaryBtn('Continue', _loading ? null : _handleSignup),
        TextButton(onPressed: () => _goTo(AuthFlow.choice), child: const Text('Back')),
      ],
    );
  }

  Widget _loginStep() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader('Welcome back', 'Email ya phone se login karo'),
        const SizedBox(height: 16),
        _methodToggle(
          method: _loginMethod,
          onChanged: (m) => setState(() => _loginMethod = m),
        ),
        const SizedBox(height: 16),
        _field(
          _loginContactCtrl,
          _loginMethod == ContactMethod.email ? 'Email address' : 'Phone number',
          _loginMethod == ContactMethod.email
              ? Icons.email_outlined
              : Icons.phone_outlined,
          keyboard: _loginMethod == ContactMethod.email
              ? TextInputType.emailAddress
              : TextInputType.phone,
          inputFormatters: _loginMethod == ContactMethod.phone
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          maxLength: _loginMethod == ContactMethod.phone ? 10 : null,
        ),
        const SizedBox(height: 12),
        _field(_loginPassCtrl, 'Password', Icons.lock_outline_rounded,
            obscure: _obscurePass,
            suffix: _eyeBtn(_obscurePass, () => setState(() => _obscurePass = !_obscurePass))),
        if (_error.isNotEmpty) _errorBox(_error),
        const SizedBox(height: 16),
        _primaryBtn('Login', _loading ? null : _handleLogin),
        TextButton(onPressed: () => _goTo(AuthFlow.choice), child: const Text('Back')),
      ],
    );
  }

  Widget _otpStep() {
    return Column(
      key: const ValueKey('otp'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _stepHeader('Verify OTP', 'Code bheja gaya ${_auth.contactLabel(_pendingContact)} par'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF144E2C).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Demo OTP: 1234',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        _field(_otpCtrl, 'Enter OTP', Icons.pin_outlined,
            keyboard: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 4),
        if (_error.isNotEmpty) _errorBox(_error, success: _error.contains('Verified')),
        const SizedBox(height: 16),
        _primaryBtn('Continue', _loading ? null : _handleOtp),
      ],
    );
  }

  Widget _stepHeader(String title, String subtitle) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 6),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _methodToggle({
    required ContactMethod method,
    required ValueChanged<ContactMethod> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _methodChip('Email', ContactMethod.email, method, onChanged),
          _methodChip('Phone', ContactMethod.phone, method, onChanged),
        ],
      ),
    );
  }

  Expanded _methodChip(
    String label,
    ContactMethod value,
    ContactMethod selected,
    ValueChanged<ContactMethod> onChanged,
  ) {
    final active = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF144E2C) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : const Color(0xFF6F6A62),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF144E2C)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFFAFAF8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF144E2C), width: 1.5),
        ),
        counterText: '',
      ),
    );
  }

  Widget _eyeBtn(bool obscure, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
    );
  }

  Widget _errorBox(String msg, {bool success = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (success ? Colors.green : Colors.red).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          msg,
          style: TextStyle(
            color: success ? Colors.green.shade800 : Colors.red.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _primaryBtn(String label, VoidCallback? onPressed) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF144E2C),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: _loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
    );
  }

  Future<void> _handleSignup() async {
    final name = _nameCtrl.text.trim();
    if (name.length < 2) {
      return setState(() => _error = 'Valid naam enter karo.');
    }

    String? email;
    String? phone;

    if (_signupMethod == ContactMethod.email) {
      email = _emailCtrl.text.trim();
      phone = _optionalPhoneCtrl.text.trim();
      if (!_auth.isValidEmail(email)) {
        return setState(() => _error = 'Valid email enter karo.');
      }
      if (phone.isNotEmpty && !_auth.isValidPhone(phone)) {
        return setState(() => _error = 'Optional phone 10 digits ka hona chahiye.');
      }
    } else {
      phone = _phoneCtrl.text.trim();
      email = _optionalEmailCtrl.text.trim();
      if (!_auth.isValidPhone(phone)) {
        return setState(() => _error = 'Valid 10-digit phone enter karo.');
      }
      if (email.isNotEmpty && !_auth.isValidEmail(email)) {
        return setState(() => _error = 'Optional email valid hona chahiye.');
      }
    }

    if (_passCtrl.text.length < 6) {
      return setState(() => _error = 'Password kam se kam 6 characters ka ho.');
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      return setState(() => _error = 'Password aur confirm password match nahi kar rahe.');
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    final err = await _auth.register(
      name: name,
      password: _passCtrl.text,
      email: email.isEmpty == true ? null : email,
      phone: phone.isEmpty == true ? null : phone,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      return setState(() => _error = err);
    }

    _pendingUser = UserModel(
      id: 'pending',
      name: name,
      email: email.isEmpty == true ? null : email,
      phone: phone.isEmpty == true ? null : phone,
      password: _passCtrl.text,
    );
    _pendingContact = _signupMethod == ContactMethod.email ? email : phone;
    _isLogin = false;
    setState(() {
      _error = '';
      _otpCtrl.text = '1234';
      _flow = AuthFlow.otp;
    });
    _fadeCtrl.forward(from: 0);
  }

  Future<void> _handleLogin() async {
    final contact = _loginContactCtrl.text.trim();
    if (_loginMethod == ContactMethod.email) {
      if (!_auth.isValidEmail(contact)) {
        return setState(() => _error = 'Valid email enter karo.');
      }
    } else {
      if (!_auth.isValidPhone(contact)) {
        return setState(() => _error = 'Valid 10-digit phone enter karo.');
      }
    }

    if (_loginPassCtrl.text.length < 6) {
      return setState(() => _error = 'Password enter karo.');
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    final err = await _auth.login(
      contact: contact,
      password: _loginPassCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      return setState(() => _error = err);
    }

    final user = await _auth.findByContact(contact);
    if (user == null) return;

    _pendingUser = user;
    _pendingContact = contact;
    _isLogin = true;
    setState(() {
      _error = '';
      _otpCtrl.text = '1234';
      _flow = AuthFlow.otp;
    });
    _fadeCtrl.forward(from: 0);
  }

  Future<void> _handleOtp() async {
    if (_otpCtrl.text.trim() != '1234') {
      return setState(() => _error = 'Demo OTP 1234 enter karo.');
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    final user = _pendingUser;

    if (!mounted) return;
    setState(() => _loading = false);

    if (user == null) {
      return setState(() => _error = 'Account load nahi ho paya.');
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WelcomeScreen(user: user, returning: _isLogin),
      ),
    );
  }
}
