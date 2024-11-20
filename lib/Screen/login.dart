import 'package:eventmanagement/Component/diglog_load.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Service/login_service.dart';
import 'package:eventmanagement/Component/button_access.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final LoginService _loginService = LoginService();
  late BuildContext _context;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _context = context;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final userName = _userNameController.text;
    final password = _passwordController.text;

    if (userName.isEmpty || password.isEmpty) {
      showWarningDialog(
        _context,
        'Thông báo',
        'Tài khoản và mật khẩu không được để trống!',
        Icons.warning,
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final responseData = await _loginService.loginApi(userName, password);
      if (responseData['code'] == 1000) {
        String role = responseData['result']['role'];
        String departmentId = responseData['result']['departmentId'];
        role = role.replaceAll('[', '').replaceAll(']', ''); // Remove square brackets

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('role', role);
        await prefs.setString('departmentId', departmentId);

        if (role.contains('ADMIN_ENTIRE') && departmentId.contains("EN")) {
          showLod(_context, 'Đăng nhập thành công', 'Chuyển hướng đến trang quản trị...', '/dashboard');
        } else if (role.contains('ADMIN_DEPARTMENT')) {
          showLod(_context, 'Đăng nhập thành công', 'Chuyển hướng đến trang quản trị...', '/dashboard_department');
        } else if (role.contains('USER')) {
          showLod(_context, 'Đăng nhập thành công', 'Chuyển hướng đến trang sinh viên...', '/dashboard_student');
        } else {
          showWarningDialog(
            _context,
            'Thông báo',
            'Tài khoản không có quyền truy cập!',
            Icons.warning,
          );
        }
      } else {
        showWarningDialog(
          _context,
          'Thông báo',
          'Đăng nhập thất bại!',
          Icons.warning,
        );
      }
    } catch (e) {
      showWarningDialog(
        _context,
        'Thông báo',
        "Đăng nhập thất bại",
        Icons.warning,
        Colors.red,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      // Token exists, navigate to DashboardScreen
      _context.go('/dashboard');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.fill,
                alignment: Alignment.topCenter,
                opacity: 0.8,
                colorFilter: ColorFilter.mode(
                  Colors.black54, // Adjust the color and opacity as needed
                  BlendMode.darken,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.3,
              padding: EdgeInsets.all(24.0),

              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: CustomText(
                      text: "HỆ THỐNG ĐĂNG NHẬP",
                      fontSize: MediaQuery.of(context).size.width * 0.02,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  TextField(
                    controller: _userNameController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      hintText: 'Tài khoản',
                      prefixIcon: Icon(Icons.person, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                    ),
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      suffixIcon: IconButton(
                        color: Colors.white70,
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      fillColor: Colors.white.withOpacity(0.1),
                      hintText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock, color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                    ),
                    obscureText: !_isPasswordVisible, // Bind to _isPasswordVisible
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  CustomElevatedButton(
                    color: Color(0xFF2E3034),
                    onPressed: _login,
                    text: 'Đăng nhập',
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}