import 'dart:async';

import 'package:eventmanagement/Class/course.dart';
import 'package:eventmanagement/Component/button_crud.dart';
import 'package:eventmanagement/Component/diglog_load.dart';
import 'package:eventmanagement/Component/event_card.dart';
import 'package:eventmanagement/Component/excel_dialog.dart';
import 'package:eventmanagement/Component/form_add_account_management.dart';
import 'package:eventmanagement/Component/form_edit_account.dart';
import 'package:eventmanagement/Component/icon_crud.dart';
import 'package:eventmanagement/Component/listtile.dart';
import 'package:eventmanagement/Component/form_add_account_admin.dart';
import 'package:eventmanagement/Component/summary_card.dart';
import 'package:eventmanagement/Component/search_user.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Component/text_font_list.dart';
import 'package:eventmanagement/Screen/course_management.dart';
import 'package:eventmanagement/Screen/department_management.dart';
import 'package:eventmanagement/Screen/event_management_entire.dart';
import 'package:eventmanagement/Service/course_service.dart';
import 'package:eventmanagement/Service/info_account.dart';
import 'package:eventmanagement/Service/department_service.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Service/user_service.dart';
import 'package:eventmanagement/Class/user.dart';
import 'package:eventmanagement/Class/department.dart';
import 'package:eventmanagement/Component/logout.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = 'Tất cả';
  String _selectedRole = 'Tất cả';
  String _selectedCourse = 'Toàn Khóa';
  int _selectedIndex = 0;
  List<Users> _users = [];
  List<Department> _departments = [];
  List<Courses> _courses = [];
  int _currentPage = 1;
  final int _pageSize = 50;
  bool _hasMoreUsers = true;
  bool _isLoadingMore = false;
  // ignore: unused_field
  bool _isLoading = true;
  OverlayEntry? _overlayEntry;
  String roleText = '';
  Timer? _timer;
  void _checkTokenAndFetchData() async {
    if (!await _isTokenValid()) {
      _handleLogout();
    } else {
      _fetchUsers();
      _fetchInfoAccount();
      _fetchDepartments();
      _startAutoRefresh();
      _fetchCourses();
    }
  }
  void _fetchCourses() async {
    try {
      final courses = await CourseService().getAllCourses();
      setState(() {
        _courses = courses;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Error', 'Failed to load courses: ${e.toString()}', Icons.error);
    }
  }
  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      _fetchUsers();
    });
  }
  Future<bool> _isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      return false;
    }
    return true;
  }
  void _handleLogout() {
    _timer?.cancel();
    showLod(context, 'Session Expired', 'You will be redirected to the login screen.', '/login');
    Future.delayed(Duration(milliseconds: 500), () {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/login');
    });
  }
  void _fetchInfoAccount() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await InfoAccountService().fetchUserInfo();
      setState(() {
        if (user != null) {
          _users = [user];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Error', e.toString(), Icons.error);
    }
  }
  void _fetchUsers({bool isLoadMore = false}) async {
    if (_isLoadingMore) return;

    setState(() {
      if (!isLoadMore) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final users = await UserService().fetchUsers(page: _currentPage, pageSize: _pageSize);
      setState(() {
        if (isLoadMore) {
          _users.addAll(users);
        } else {
          _users = users;
        }
        _isLoading = false;
        _isLoadingMore = false;
        _hasMoreUsers = users.length == _pageSize;
        if (_hasMoreUsers) {
          _currentPage++;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
      showWarningDialog(context, 'Error', e.toString(), Icons.error);
    }
  }
  void _fetchDepartments() async {
    try {
      final departments = await DepartmentService().fetchDepartments();
      setState(() {
        _departments = departments;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Error', 'Failed to load departments: ${e.toString()}', Icons.error);
    }
  }
  @override
  void initState() {
    super.initState();
    _checkTokenAndFetchData();
  }
  String _getDepartmentName(String departmentId) {
    final department = _departments.firstWhere((dept) => dept.departmentId == departmentId, orElse: () => Department(id: '', departmentId: '', departmentName: 'Unknown'));
    return department.departmentName;
  }
  final Map<String, String> roleLabels = {
    'Tất cả': 'Tất cả',
    'ADMIN_DEPARTMENT': 'Quản lí khoa',
    'USER': 'Sinh viên',
    'MANAGER_ENTIRE': 'Quét QR cho siện kiện toàn trường',
    'MANAGER_DEPARTMENT': 'Quét QR cho sự kiện khoa',
  };
  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
    Navigator.pop(context);
  }
  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FormAddAccountDialog(
          callback: () {
            _fetchUsers();
          },
        );
      },
    );
  }

  void _showEditAccountDialog(Users user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FormEditAccountDialog(
          user: user,
          callback: () {
            _fetchUsers();
          },
        );
      },
    );
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Users> _filterUsers() {
    String searchQuery = _searchController.text.trim().toLowerCase();
    return _users.where((user) {
      bool matchesFullName = user.fullName.toLowerCase().contains(searchQuery);
      bool matchesDepartment = _selectedDepartment == 'Tất cả' || (user.departmentId.startsWith(_selectedDepartment));
      bool matchesCourse = (_selectedCourse == 'Toàn Khóa' ||
          (user.classId.length >= 2 && _selectedCourse.length >= 2 &&
              (user.classId.startsWith('0') ? user.classId[1] == _selectedCourse[1] : user.classId.substring(0, 2) == _selectedCourse.substring(1))));
      bool matchesRole = _selectedRole == 'Tất cả' || (user.roles.contains(_selectedRole));
      bool notAdmin = !user.roles.contains('ADMIN_ENTIRE');
      return matchesFullName && matchesDepartment && matchesRole && notAdmin && matchesCourse;
    }).toList();
  }

  void _showOverlay(BuildContext context, Users user, Offset position) {

    String trainingPoints = user.trainingPoint.map((tp) {
      return '\n- Học kỳ 1: ${tp.semesterOne}\n- Học kỳ 2: ${tp.semesterTwo}\n- Học kỳ 3: ${tp.semesterThree}\n- Học kỳ 4: ${tp.semesterFour}\n- Học kỳ 5: ${tp.semesterFive}\n- Học kỳ 6: ${tp.semesterSix}\n- Học kỳ 7: ${tp.semesterSeven}\n- Học kỳ 8: ${tp.semesterEight}';
    }).join('\n');

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy - 200,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(2, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextList(
                  text: user.fullName,
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 8),
                CustomTextList(
                  text: 'Mã : ${user.userName}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                if (!user.roles.contains('ADMIN_DEPARTMENT') && !user.roles.contains('MANAGER_DEPARTMENT') && !user.roles.contains('MANAGER_ENTIRE'))
                CustomTextList(
                  text: 'Tổng số sự kiện đã đăng ký: ${user.totalEventsRegistered}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                if (!user.roles.contains('ADMIN_DEPARTMENT') && !user.roles.contains('MANAGER_DEPARTMENT') && !user.roles.contains('MANAGER_ENTIRE'))
                  CustomTextList(
                    text: 'Điểm rèn luyện: $trainingPoints',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                if (!user.roles.contains('MANAGER_DEPARTMENT') && !user.roles.contains('MANAGER_ENTIRE'))
                CustomTextList(
                  text: 'Giới tính: ${user.gender}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                if (!user.roles.contains('MANAGER_DEPARTMENT') && !user.roles.contains('MANAGER_ENTIRE'))
                CustomTextList(
                  text: 'Email: ${user.email}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                if (!user.roles.contains('MANAGER_DEPARTMENT') && !user.roles.contains('MANAGER_ENTIRE'))
                CustomTextList(
                  text: 'Sđt: ${user.phone?.isNotEmpty == true ? user.phone : 'Chưa cập nhật'}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                if (!user.roles.contains('MANAGER_DEPARTMENT') && !user.roles.contains('MANAGER_ENTIRE'))
                  CustomTextList(
                    text: 'Địa chỉ: ${user.address?.isNotEmpty == true ? user.address : 'Chưa cập nhật'}',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                if (!user.roles.contains('ADMIN_DEPARTMENT') && !user.roles.contains('MANAGER_DEPARTMENT') && !user.roles.contains('MANAGER_ENTIRE'))
                  CustomTextList(
                    text: 'Lớp: ${user.classId}',
                    fontSize: 16,
                    color: Colors.black,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }
  void _showAddAccountManagerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FormAddAccountManagerEntireDialog(
          callback: () {
            _fetchUsers();
          },
        );
      },
    );
  }
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
  void exampleFunction(List<String> items, int index) {
    if (index >= 0 && index < items.length) {
      // Access the item at the valid index
      print(items[index]);
    } else {
      // Handle the invalid index case
      print('Invalid index: $index');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      drawerScrimColor: Colors.black.withOpacity(0.7),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white), // Change the color here
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        backgroundColor: Color(0xFF2E3034),
        title: CustomText(text: "Quản trị", fontSize: 35, color: Colors.white),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Container(
            color: Color.fromARGB(255, 154, 154, 154).withOpacity(0.2),
            height: 2.0,
          ),
        ),
        actions: [
          const SizedBox(width: 20),
          PopupMenuButton<int>(
            onSelected: (int result) {
              if (result == 1) {
                showLod(context, 'Vui lòng đợi giây lát', 'Đang chuyển hướng đến trang thông tin ....', '/profile');
              } else if (result == 2) {
                showLogoutDialog(context);
                _timer?.cancel();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              const PopupMenuItem<int>(
                value: 1,
                child: CustomText(text: "Thông tin cá nhân ", fontSize: 16, color: Colors.black),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: CustomText(text: "Đăng xuất ", fontSize: 16, color: Colors.black),
              ),
            ],
            offset: Offset(0, 40),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
          ),
          const SizedBox(width: 50),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              duration: Duration(seconds: 1),
              decoration: BoxDecoration(
                color: Color(0xFF2E3034),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(text: _users.isNotEmpty ? _users[0].fullName : 'No Name', fontSize: 24, color: Colors.white),
                  const SizedBox(height: 10),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                ],
              ),
            ),
            ListTileItem(
              icon: Icons.account_circle,
              title: "Quản lí tài khoản",
              onTap: () {
                _navigateToPage(0);
              },
              selected: _selectedIndex == 0,
            ),
            ListTileItem(
              icon: Icons.event,
              title: "Quản lí sự kiện",
              onTap: () {
                _navigateToPage(1);
              },
              selected: _selectedIndex == 1,
            ),
            ListTileItem(
              icon: Icons.event,
              title: "Quản lí bộ phận khoa",
              onTap: () {
                _navigateToPage(2);
              },
              selected: _selectedIndex == 2,
            ),
            ListTileItem(
              icon: Icons.school,
              title: "Quản lí khóa năm học",
              onTap: () {
                _navigateToPage(3);
              },
              selected: _selectedIndex == 3,
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E3034),
              Color(0xFF2E3034),
            ],
          ),
        ),
        child: PageView(
          controller: _pageController,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SearchWidget(
                              searchController: _searchController,
                              onSearchChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),

                          const SizedBox(width: 20),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: DropdownButton<String>(
                              borderRadius: BorderRadius.circular(15),
                              value: _selectedDepartment,
                              items: [
                                DropdownMenuItem<String>(
                                  value: 'Tất cả',
                                  child: CustomText(text: 'Tất cả', fontSize: 18, color: Colors.black),
                                ),
                                ..._departments
                                    .where((department) => department.departmentId != 'EN')
                                    .map<DropdownMenuItem<String>>((Department department) {
                                  return DropdownMenuItem<String>(
                                    value: department.departmentId,
                                    child: CustomText(text: department.departmentName, fontSize: 18, color: Colors.black),
                                  );
                                }),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedDepartment = newValue!;
                                });
                              },
                              style: TextStyle(color: Colors.black),
                              dropdownColor: Colors.white,
                              underline: SizedBox(),
                              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                            child: DropdownButton<String>(
                              borderRadius: BorderRadius.circular(15),
                              value: _selectedRole,
                              items: roleLabels.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key,
                                  child: CustomText(text: entry.value, fontSize: 18, color: Colors.black),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRole = newValue!;
                                });
                              },
                              style: TextStyle(color: Colors.black),
                              dropdownColor: Colors.white,
                              underline: SizedBox(),
                              icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButton<String>(
                                borderRadius: BorderRadius.circular(15),
                                value: _selectedCourse,
                                items: [
                                  DropdownMenuItem<String>(
                                    value: 'Toàn Khóa',
                                    child: CustomText(
                                      text: 'Toàn Khóa',
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  ..._courses.where((course) => course.courseId != 'K0').toList().reversed.map((course) {
                                    return DropdownMenuItem<String>(
                                      value: course.courseId.toString(),
                                      child: CustomText(
                                        text: course.courseName,
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    );
                                  }),
                                ],
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCourse = newValue!;
                                  });
                                },
                                style: TextStyle(color: Colors.black),
                                dropdownColor: Colors.white,
                                underline: SizedBox(),
                                icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                              )
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SummaryCard(
                            title: "Số lượng tài khoản",
                            value: _filterUsers().length.toString(),
                            color: Colors.black.withOpacity(0.2),
                          ),
                          Row(
                            children: [
                              CustomElevatedButtonCRUD(onPressed: _showAddAccountManagerDialog, color: Colors.white, icon: "assets/images/add_manager.png", textColor: Colors.green,),
                              FilePickerButton(),
                              CustomElevatedButtonCRUD(onPressed: _showAddAccountDialog, color: Colors.white, icon: "assets/images/add.png", textColor: Colors.green,),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 20),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(text: "Danh sách tài khoản", fontSize: 18, color: Colors.white),
                                    SizedBox(height: 10),
                                    Expanded(
                                      child: NotificationListener<ScrollNotification>(
                                        onNotification: (ScrollNotification scrollInfo) {
                                          if (!_isLoadingMore && _hasMoreUsers && scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                                            _fetchUsers(isLoadMore: true);
                                          }
                                          return false;
                                        },
                                        child: ListView.builder(
                                          itemCount: _filterUsers().length + (_hasMoreUsers ? 1 : 0),
                                          itemBuilder: (context, index) {
                                            if (index == _filterUsers().length) {
                                              return Center(child: CircularProgressIndicator());
                                            }
                                            var user = _filterUsers()[index];
                                            String roleText;
                                            if (user.roles.contains('ADMIN_ENTIRE')) {
                                              roleText = 'Quản lí tổng';
                                            } else if (user.roles.contains('ADMIN_DEPARTMENT')) {
                                              roleText = 'Quản lí khoa';
                                            } else if (user.roles.contains('MANAGER_DEPARTMENT')) {
                                              roleText = 'Quét QR cho sự kiện khoa';
                                            } else
                                            if (user.roles.contains('MANAGER_ENTIRE')) {
                                              roleText = 'Quét QR cho sự kiện toàn trường';
                                            } else {
                                              roleText = 'Sinh viên';
                                            }
                                            return MouseRegion(
                                              onEnter: (event) {
                                                _showOverlay(context, user, event.position);
                                              },
                                              onExit: (event) {
                                                _hideOverlay();
                                              },
                                              child: EventCard(
                                                listTile: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: Color(0xFF2E3034),
                                                    child: CustomTextList(
                                                      text: user.fullName.isNotEmpty
                                                          ? user.fullName.split(' ').last[0].toUpperCase()
                                                          : '?',
                                                      fontSize: 24,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  title: CustomTextList(
                                                    text: user.fullName,
                                                    fontSize: 24,
                                                    color: Colors.black,
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CustomTextList(
                                                        text: user.roles.contains('ADMIN_DEPARTMENT') ? "Mã: ${user.userName}" : "Mã: ${user.userName}",
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                      CustomTextList(
                                                        text: _getDepartmentName(user.departmentId),
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                      CustomTextList(
                                                        text: "Vai trò: $roleText",
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      if(!user.roles.contains('MANAGER_DEPARTMENT') && !user.roles.contains('MANAGER_ENTIRE'))
                                                      IconCRUD(
                                                        onPressed: () {
                                                          _showEditAccountDialog(user);
                                                        },
                                                        icon: Icons.edit,
                                                        color: Colors.orange,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            EventManagementScreen(),
            DepartmentManagementScreen(),
            CourseManagementScreen(),
          ],
        ),
      ),
    );
  }
}