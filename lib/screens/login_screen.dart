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

  void _login() async {
    String email = _emailController.text.trim();
    String pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() {
        _errorMessage = "Todos los campos son obligatorios";
      });
      return;
    }

    Usuario? user = await _dbHelper.loginUser(email, pass);
    if (user != null) {
      setState(() => _errorMessage = "");
      if (user.rol == "admin") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminHome()));
      } else if (user.rol == "maestro") {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => MaestroHome(user: user)));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => EstudianteHome(user: user)));
      }
    } else {
      setState(() {
        _errorMessage = "Credenciales incorrectas";
      });
    }
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
                  obscure: true),
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
