import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Screen/personal_infomation.dart';
import 'package:eventmanagement/Service/info_account.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Class/user.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late Future<Users?> _userInfo;

  @override
  void initState() {
    super.initState();
    _userInfo = InfoAccountService().fetchUserInfo();
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5, // Adjust this based on the number of tabs
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD), // Light background
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: 200,
          flexibleSpace: Stack(
            children: [
              // Gradient background
              Container(
                height: 250,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF2E3034),
                      Color(0xFF2E3034),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    FutureBuilder<Users?>(
                      future: _userInfo,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (!snapshot.hasData) {
                          return const Text('No user data found');
                        } else {
                          final user = snapshot.data!;
                          return Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage("assets/images/avatar.png"), // Replace with actual image
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(Icons.verified_user,
                                          size: 18, color: Colors.white70),
                                      const SizedBox(width: 5),
                                      Text(
                                        user.roles.contains('ADMIN_DEPARTMENT')
                                            ? 'Quản lí khoa'
                                            : user.roles.contains('ADMIN_ENTIRE')
                                            ? 'Quản lí toàn trường'
                                            : user.roles.contains('MANAGER_ENTIRE') || user.roles.contains('MANAGER_DEPARTMENT')
                                            ? 'Sinh viên quét QR'
                                            : 'Sinh viên',
                                        style: TextStyle(color: Colors.white70),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Tab Bar
                    TabBar(
                      indicatorColor: Colors.white70,
                      automaticIndicatorColorAdjustment: true,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      isScrollable: true,
                      tabs: const [
                        Tab(text: 'Thông tin cá nhân'),
                        Tab(text: 'Đổi mật khẩu'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProfileInfoSection(),
            buildPasswordChangeSection(),
          ],
        ),
      ),
    );
  }

  Widget buildPasswordChangeSection() {
    final TextEditingController oldPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    return Container(
      color: Color(0xFF2E3034), // Set the background color here
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password Fields inside Cards
            Card(
              color: Color(0xFF323639),
              shadowColor: Color(0xFFD9E2E4),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: PasswordField(
                  label: 'Mật khẩu hiện tại',
                  controller: oldPasswordController,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              color: Color(0xFF323639),
              shadowColor: Color(0xFFD9E2E4),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: PasswordField(
                  label: 'Mật khẩu mới',
                  hintText: '*************',
                  controller: newPasswordController,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              color: Color(0xFF323639),
              shadowColor: Color(0xFFD9E2E4),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: PasswordField(
                  label: 'Nhập lại mật khẩu mới',
                  hintText: '*************',
                  controller: confirmPasswordController,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Align(
              alignment: Alignment.centerRight,
              child: CustomElevatedButton(
                onPressed: () async {
                  if (newPasswordController.text != confirmPasswordController.text) {
                    showWarningDialog(context, "Thông báo", "Mật khẩu mới không khớp", Icons.error, Colors.red);
                    return;
                  }
                  if (oldPasswordController.text == newPasswordController.text) {
                    showWarningDialog(context, "Thông báo", "Mật không mới không được trùng khớp với mật khẩu cũ", Icons.error, Colors.red);
                    return;
                  }
                  if (newPasswordController.text.length < 8) {
                    showWarningDialog(context, "Thông báo", "Mật khẩu phải ít nhất 8 ký tự", Icons.error, Colors.red);
                    return;
                  }
                  try {
                    await InfoAccountService().changePassword(
                      oldPasswordController.text,
                      newPasswordController.text,
                    );
                    showWarningDialog(context, "Thông báo", "Đổi mật khẩu thành công", Icons.check_circle, Colors.green);

                    // Clear the TextField controllers
                    oldPasswordController.clear();
                    newPasswordController.clear();
                    confirmPasswordController.clear();

                    // Navigate back to ProfileInfoSection
                    DefaultTabController.of(context).animateTo(0);
                  } catch (e) {
                    showWarningDialog(context, "Thông báo", "Đổi mật khẩu thất bại hoặc nhập sai mật khẩu hiện tại", Icons.error, Colors.red);
                  }
                },
                color: Color(0xFFD9E2E4), // Define your button color here
                text: 'Lưu thông tin',
                textColor: Color(0xFF323639),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;

  const PasswordField({
    required this.label,
    this.hintText,
    required this.controller,
    super.key,
  });

  @override
  PasswordFieldState createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD9E2E4)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: widget.hintText ?? '',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.lock, color: Color(0xFF323639)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Color(0xFF323639),
              ),
              onPressed: _togglePasswordVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFFD9E2E4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.purple),
            ),
          ),
        ),
      ],
    );
  }
}