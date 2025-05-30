import 'package:flutter/material.dart';
import '../../controller/authController.dart';

class MotDePasseOublie extends StatefulWidget {
  @override
  _MotDePasseOublieState createState() => _MotDePasseOublieState();
}

class _MotDePasseOublieState extends State<MotDePasseOublie> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = AuthController();
  final _formKey = GlobalKey<FormState>();
  final _tokenFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _emailSent = false;
  bool _tokenValidated = false;
  String? _userEmail;

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authController.forgotPassword(_emailController.text);
      setState(() {
        _userEmail = _emailController.text;
        _emailSent = true;
      });
      _showSnackBar('Lien envoyé à ${_emailController.text}', isError: false);
    } catch (e) {
      _showSnackBar('Erreur: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

 /* Future<void> _validateToken() async {
    if (!_tokenFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Appel à votre AuthController pour valider le token
      await _authController.validateResetToken(
        email: _userEmail!,
        token: _tokenController.text,
      );

      setState(() => _tokenValidated = true);
      _showSnackBar('Code validé avec succès', isError: false);
    } catch (e) {
      _showSnackBar('Code invalide ou expiré: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }*/
  Future<void> _validateToken() async {
    if (!_tokenFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Ici vous devriez vérifier si le token est valide
      // Par exemple: await _authController.validateToken(_tokenController.text);
      // Pour cet exemple, nous supposons que le token est valide
      setState(() => _tokenValidated = true);
      _showSnackBar('Code validé', isError: false);
    } catch (e) {
      _showSnackBar('Erreur: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _authController.resetPassword(
        email: _userEmail!,
        token: _tokenController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      _showSnackBar('Mot de passe réinitialisé avec succès', isError: false);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnackBar('Erreur: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: _emailSent
                ? _tokenValidated
                ? _buildResetForm()
                : _buildTokenForm()
                : _buildEmailForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/logo2.png', height: 100),
          SizedBox(height: 30),
          Text(
            'Mot de passe oublié ?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Container(height: 2, width: 100, color: Colors.orange),
          SizedBox(height: 30),
          Text(
            'Entrez votre email pour recevoir le code de réinitialisation',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          _buildTextField(
            controller: _emailController,
            hintText: 'Adresse email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              )
                  : Text("Envoyer le code"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenForm() {
    return Form(
      key: _tokenFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/logo2.png', height: 100),
          SizedBox(height: 30),
          Text(
            'Vérification du code',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Container(height: 2, width: 100, color: Colors.orange),
          SizedBox(height: 30),
          Text(
            'Un code a été envoyé à $_userEmail',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),
          _buildTextField(
            controller: _tokenController,
            hintText: 'Code de réinitialisation',
            icon: Icons.lock_outline,
            validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
          ),
          SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _validateToken,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              )
                  : Text("Valider le code"),
            ),
          ),
          SizedBox(height: 20),
          TextButton(
            onPressed: () => setState(() => _emailSent = false),
            child: Text(
              'Modifier l\'email',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _resetFormKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/logo2.png', height: 100),
          SizedBox(height: 30),
          Text(
            'Nouveau mot de passe',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Container(height: 2, width: 100, color: Colors.orange),
          SizedBox(height: 30),
          _buildPasswordField(
            controller: _passwordController,
            hintText: 'Nouveau mot de passe',
            validator: (value) {
              if (value == null || value.isEmpty) return 'Ce champ est requis';
              if (value.length < 6) return '6 caractères minimum';
              return null;
            },
          ),
          SizedBox(height: 20),
          _buildPasswordField(
            controller: _confirmPasswordController,
            hintText: 'Confirmer le mot de passe',
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              )
                  : Text("Réinitialiser le mot de passe"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.orange, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    bool _obscureText = true;

    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          controller: controller,
          obscureText: _obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(Icons.lock_outline, color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            ),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.orange, width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        );
      },
    );
  }

}