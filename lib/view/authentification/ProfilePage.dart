import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import '../../compenent/Navigation.dart';
import '../../controller/authController.dart';
import '../../model/userModel.dart';
import '../../serviceAu/apiServiceUser.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<User> _userFuture;
  bool _isEditing = false;
  bool _showPasswordFields = false;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final ApiService _apiService = ApiService();
  final AuthController _authController = AuthController();

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
  }

  Future<User> _loadUserData() async {
    try {
      final token = await _authController.getToken();
      if (token == null) throw Exception('Utilisateur non connecté');

      _apiService.setToken(token);
      final user = await _authController.getUser();
      if (user == null) throw Exception('Profil non trouvé');

      return user;
    } catch (e) {
      debugPrint('Erreur de chargement: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
    );
  }

  Future<void> _toggleEdit() async {
    if (_isEditing && _formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedUser = await _apiService.updateProfile(
          name: _nameController.text,
          phone: _phoneController.text,
        );
        _authController.setUser(updatedUser); // Ajoute cette ligne si disponible

        _showToast("Profil mis à jour");
        setState(() {
          _userFuture = Future.value(updatedUser);
          _isEditing = false;
        });
      } catch (e) {
        String errorMessage = 'Une erreur est survenue. Veuillez réessayer.';

        if (e.toString().contains('email')) {
          errorMessage = 'Le champ e-mail est requis.';
        } else if (e.toString().contains('password')) {
          errorMessage = 'Le champ mot de passe est requis.';
        } else if (e.toString().contains('credentials')) {
          errorMessage = 'Identifiants incorrects. Veuillez réessayer.';
        } else if (e.toString().contains('SocketException')) {
          errorMessage = 'Vérifiez votre connexion internet.';
        }

        _showToast(errorMessage);
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isEditing = !_isEditing);
    }
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showToast("Les mots de passe ne correspondent pas", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      _showToast("Mot de passe changé avec succès");
      setState(() {
        _showPasswordFields = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });
    } catch (e) {
      String errorMessage = 'Une erreur est survenue. Veuillez réessayer.';

      if (e.toString().contains('Le mot de passe actuel est incorrect')) {
        errorMessage = 'Le mot de passe actuel est incorrect.';
      } else if (e.toString().contains('Exception')) {
        errorMessage = 'Le champ e-mail est requis.';
      } else if (e.toString().contains('password')) {
        errorMessage = 'Le champ mot de passe est requis.';
      } else if (e.toString().contains('credentials')) {
        errorMessage = 'Identifiants incorrects. Veuillez réessayer.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Vérifiez votre connexion internet.';
      }

      _showToast(errorMessage);
    }
    finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    // Variable d'état pour gérer la visibilité du texte
    bool _obscureText = obscureText;

    return StatefulBuilder(
      builder: (context, setState) {
        return TextFormField(
          controller: controller,
          enabled: isEditing,
          obscureText: _obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: obscureText
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey, // Couleur grise pour l'icône
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : null,
            filled: true,
            fillColor: isEditing ? Colors.grey[200] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.orange, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
          validator: (value) => value!.isEmpty ? 'Ce champ est requis' : null,
        );
      },
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.orange,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: Icon(icon, color: color),
        label: Text(text, style: TextStyle(color: color)),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
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
        title: Text('Mon Profil', style: TextStyle(color: Colors.black)),

        actions: [
          if (!_showPasswordFields)
            IconButton(
              icon: _isLoading
                  ? CircularProgressIndicator(color: Colors.orange)
                  : Icon(_isEditing ? Icons.check : Icons.edit, color: Colors.orange),
              onPressed: _isLoading ? null : _toggleEdit,
            ),
        ],
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erreur: ${snapshot.error}', style: TextStyle(color: Colors.red)),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(() => _userFuture = _loadUserData()),
                    child: Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data!;
          if (!_isEditing) {
            _nameController.text = user.name;
            _phoneController.text = user.number_phone ?? '';
          }

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Form(

                    key: _formKey,
                    child: Column(
                      children: [
                      // Photo de profil
                      Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.orange,
                          child: Text(
                            user.name.split(' ').map((e) => e[0]).take(2).join(),
                            style: TextStyle(fontSize: 32, color: Colors.white),
                          ),
                        ),

                        if (_isEditing && !_showPasswordFields)
                          FloatingActionButton(
                            mini: true,
                            backgroundColor: Colors.orange,
                            child: Icon(Icons.camera_alt, size: 20),
                            onPressed: () => _showToast("Fonctionnalité à venir"),
                          ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Champs d'information
                    _buildProfileField(
                      label: 'Nom complet',
                      controller: _nameController,
                      isEditing: _isEditing && !_showPasswordFields,
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 16),
                    _buildProfileField(
                      label: 'Téléphone',
                      controller: _phoneController,
                      isEditing: _isEditing && !_showPasswordFields,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                        TextFormField(
                          initialValue: user.email,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                    // Section mot de passe
                    if (_showPasswordFields) ...[
                _buildProfileField(

                label: 'Mot de passe actuel',
                controller: _currentPasswordController,
                isEditing: true,
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              SizedBox(height: 16),
              _buildProfileField(
                label: 'Nouveau mot de passe',
                controller: _newPasswordController,
                isEditing: true,
                icon: Icons.lock_reset,
                obscureText: true,
              ),
              SizedBox(height: 16),
              _buildProfileField(
                label: 'Confirmer le mot de passe',
                controller: _confirmPasswordController,
                isEditing: true,
                icon: Icons.lock_outline,
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 50),
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
                    : Text('Valider le changement'),
              ),
              SizedBox(height: 16),
              TextButton(
                  onPressed: () => setState(() => _showPasswordFields = false),
                  child: Text('Annuler', style: TextStyle(color: Colors.orange)),
                  //SizedBox(height: 24),
                  )
                  ],

                  // Boutons d'action
                  if (!_isEditing && !_showPasswordFields) ...[
              _buildActionButton(
              text: 'Changer le mot de passe',
              icon: Icons.lock_outline,
              onPressed: () => setState(() => _showPasswordFields = true),
            ),
            SizedBox(height: 16),
            _buildActionButton(
              text: 'Déconnexion',
              icon: Icons.logout,
              color: Colors.red,
              onPressed: () => _authController.logout().then((_) {

                context.go('/login');
              }),
            ),
            ],
            ],
          ),
          ),
          ),
          ),
          );
        },
      ),

      bottomNavigationBar: Navigation(context:context).run(),
    );
  }
}