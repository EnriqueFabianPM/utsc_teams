import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../database/models/usuario.dart';
import 'admin/admin_home.dart';
import 'maestro/maestro_home.dart';
import 'estudiante/estudiante_home.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  String _errorMessage = "";

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final pass  = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorMessage = "Todos los campos son obligatorios");
      return;
    }

    final Usuario? user = await _dbHelper.loginUser(email, pass);

    // ✅ evita usar BuildContext si el widget ya no está montado
    if (!mounted) return;

    if (user != null) {
      setState(() => _errorMessage = "");

      if (user.rol == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHome()),
        );
      } else if (user.rol == "maestro") {
        // ❌ Antes: MaestroHome(user: user)  -> esa prop no existe
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MaestroHome()),
        );
      } else {
        // ❌ Antes: EstudianteHome(user: user) -> esa prop no existe
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EstudianteHome()),
        );
      }
    } else {
      setState(() => _errorMessage = "Credenciales incorrectas");
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Iniciar Sesión",
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 20),
              CustomTextField(controller: _emailController, hint: "Correo"),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _passwordController,
                hint: "Contraseña",
                obscure: true,
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              CustomButton(text: "Ingresar", onPressed: _login),
            ],
          ),
        ),
      ),
    );
  }
}
