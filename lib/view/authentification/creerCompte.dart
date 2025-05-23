import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../controller/authController.dart';
import '../client/pageAccueille.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Création de Compte',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: CreationCompte(),
    );
  }
}

class CreationCompte extends StatefulWidget {
  @override
  _CreationCompteState createState() => _CreationCompteState();
}

class _CreationCompteState extends State<CreationCompte> {
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = AuthController();

  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showToast('Les mots de passe ne correspondent pas');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authController.register(
        _nomController.text,
        _emailController.text,
        _passwordController.text,
        _phoneController.text.isEmpty ? null : _phoneController.text,
      ).timeout(const Duration(seconds: 10));

      _showToast('Bienvenue ${user.name} !', isError: false);

      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PageAccueil()),
        );
      });

    } catch (e) {
      _showToast(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String message, {bool isError = true}) {
    debugPrint(message);
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center( // Ajout du widget Center principal
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400), // Largeur maximale pour les grands écrans
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre avec ligne orange
                Column(
                  children: [
                    Text(
                      'Création Compte',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center, // Centrage du texte
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 2,
                      width: 100,
                      color: Colors.orange,
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Champs de formulaire
                _buildTextField(
                  controller: _nomController,
                  hintText: 'Nom complet',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _emailController,
                  hintText: 'Adresse email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _phoneController,
                  hintText: 'Numéro de téléphone (optionnel)',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _passwordController,
                  hintText: 'Mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  controller: _confirmPasswordController,
                  hintText: 'Confirmer le mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 32),

                // Bouton d'inscription
                SizedBox(
                  width: double.infinity, // Prend toute la largeur disponible
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text(
                      'Créer mon compte',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textAlign: TextAlign.start, // Alignement du texte à gauche dans le champ
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}