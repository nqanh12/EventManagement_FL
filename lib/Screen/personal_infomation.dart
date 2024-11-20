import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/text_field.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Service/info_account.dart';
import 'package:eventmanagement/Service/department_service.dart';
import 'package:eventmanagement/Class/user.dart';
import 'package:flutter/services.dart';

class ProfileInfoSection extends StatefulWidget {
  const ProfileInfoSection({super.key});

  @override
  ProfileInfoSectionState createState() => ProfileInfoSectionState();
}

class ProfileInfoSectionState extends State<ProfileInfoSection> {
  late Future<Users?> _userInfo;
  String? _departmentName;
  bool _isEditing = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isMale = true;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() {
    _userInfo = InfoAccountService().fetchUserInfo();
    _userInfo.then((user) {
      if (user != null) {
        DepartmentService().getDepartmentName(user.departmentId).then((name) {
          setState(() {
            _departmentName = name;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
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
        child: _isEditing ? buildUpdateForm() : buildUserInfo(),
      ),
    );
  }

  Widget buildUserInfo() {
    return FutureBuilder<Users?>(
      future: _userInfo,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No user data found'));
        } else {
          final user = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                buildCard(
                  title: "Thông tin cá nhân",
                  icon: Icons.person,
                  content: Column(
                    children: [
                      buildInfoRow(Icons.person, "Họ và tên", user.fullName),
                      buildInfoRow(Icons.school, "Khoa", _departmentName ?? 'Loading...'),
                      buildInfoRow(Icons.male, "Giới tính", user.gender),
                      buildInfoRow(Icons.male, "Email", user.email),
                      Visibility(
                        visible: !user.roles.contains("ADMIN_DEPARTMENT") && !user.roles.contains("ADMIN_ENTIRE"),
                        child: buildInfoRow(Icons.class_, "Lớp", user.classId),
                      ),
                      buildInfoRow(Icons.phone, "Số điện thoại", user.phone ?? 'Chưa cập nhật'),
                      buildInfoRow(Icons.home, "Địa chỉ", user.address ?? 'Chưa cập nhật'),
                      CustomElevatedButton(
                        onPressed: () {
                          setState(() {
                            _fullNameController.text = user.fullName;
                            _departmentController.text = _departmentName ?? '';
                            _emailController.text = user.email;
                            _phoneController.text = user.phone ?? '';
                            _addressController.text = user.address ?? '';
                            _isMale = user.gender == 'Nam';
                            _isEditing = true;
                          });
                        },
                        color: Color(0xFFD9E2E4), // Define your button color here
                        text: 'Cập nhật thông tin',
                        textColor: Color(0xFF323639),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Visibility(
                  visible: !user.roles.contains("ADMIN_DEPARTMENT") && !user.roles.contains("ADMIN_ENTIRE"),
                  child: buildCard(
                    title: "Điểm rèn luyện",
                    icon: Icons.star,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: user.trainingPoint
                          .map((point) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          point.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Visibility(
                  visible: !user.roles.contains("ADMIN_DEPARTMENT") && !user.roles.contains("ADMIN_ENTIRE"),
                  child: buildCard(
                    title: "Sự kiện đã tham gia",
                    icon: Icons.event,
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tổng số sự kiện đã đăng ký:",
                          style: TextStyle(fontSize: 16, color: Color(0xFFD9E2E4)),
                        ),
                        Text(
                          "${user.totalEventsRegistered}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD9E2E4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
  bool _isEmailEnabled = false;

  Widget buildUpdateForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: buildCard(
        title: "Cập nhật thông tin",
        icon: Icons.person,
        content: Column(
          children: [
            CustomTextField(
              controller: _fullNameController,
              labelText: 'Họ và tên',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 10),
            buildGenderRadio(),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _isEmailEnabled,
                  activeColor: Color(0xFFD9E2E4),
                  onChanged: (bool? value) {
                    setState(() {
                      _isEmailEnabled = value!;
                    });
                  },
                ),
                const SizedBox(width: 10),
                const Text(
                  'Cập nhật mail',
                  style: TextStyle(color: Color(0xFFD9E2E4)),
                ),
              ],
            ),
            const SizedBox(height: 5),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              prefixIcon: Icons.email,
              enabled: _isEmailEnabled,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _phoneController,
              labelText: 'Số điện thoại',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: _addressController,
              labelText: 'Địa chỉ',
              prefixIcon: Icons.home,
            ),
            const SizedBox(height: 20),
            CustomElevatedButton(
              onPressed: () async {
                try {
                  if (_isEmailEnabled) {
                    bool emailExists = await InfoAccountService().checkEmailExist(_emailController.text);
                    if (!emailExists) {
                      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$').hasMatch(_emailController.text)) {
                        showWarningDialog(context, 'Lỗi', 'Email sai định dạng', Icons.warning, Colors.red);
                        return;
                      }
                      await InfoAccountService().updateUserInfo(
                        _fullNameController.text,
                        _isMale ? 'Nam' : 'Nữ',
                        _emailController.text,
                        _phoneController.text,
                        _addressController.text,
                      );
                      showWarningDialog(context, "Thông báo", "Cập nhật thành công", Icons.check_circle, Colors.green);
                      setState(() {
                        _isEditing = false;
                      });
                      _fetchUserInfo();
                    } else {
                      showWarningDialog(context, "Thông báo", "Email đã tồn tại", Icons.error, Colors.red);
                    }
                  } else {
                    await InfoAccountService().updateUserInfoNotMail(
                      _fullNameController.text,
                      _isMale ? 'Nam' : 'Nữ',
                      _phoneController.text,
                      _addressController.text,
                    );
                    showWarningDialog(context, "Thông báo", "Cập nhật thành công", Icons.check_circle, Colors.green);
                    setState(() {
                      _isEditing = false;
                    });
                    _fetchUserInfo();
                  }
                } catch (e) {
                  showWarningDialog(context, "Thông báo", "Cập nhật thất bại", Icons.error, Colors.red);
                }
              },
              color: Color(0xFFD9E2E4), // Define your button color here
              text: 'Lưu thông tin',
              textColor: Color(0xFF323639),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGenderRadio() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới tính',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFD9E2E4),
          ),
        ),
        Row(
          children: [
            Radio<bool>(
              activeColor: Color(0xFFD9E2E4),
              value: true,
              groupValue: _isMale,
              onChanged: (bool? value) {
                setState(() {
                  _isMale = value!;
                });
              },
            ),
            const Text('Nam', style: TextStyle(color: Color(0xFFD9E2E4)),
            ),
            Radio<bool>(
              activeColor: Color(0xFFD9E2E4),
              value: false,
              groupValue: _isMale,
              onChanged: (bool? value) {
                setState(() {
                  _isMale = value!;
                });
              },
            ),
            const Text('Nữ',style: TextStyle(color: Color(0xFFD9E2E4)),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCard({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      elevation: 10,
      shadowColor: Color(0xFFD9E2E4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Color(0xFF323639),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Color(0xFFD9E2E4),),
                const SizedBox(width: 10),
                CustomText(text: title, fontSize: MediaQuery.of(context).size.width * 0.01, color: Color(0xFFD9E2E4),),
              ],
            ),
            const Divider(height: 20, thickness: 1),
            content,
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Color(0xFFD9E2E4),),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFD9E2E4),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD9E2E4),
            ),
          ),
        ],
      ),
    );
  }
}