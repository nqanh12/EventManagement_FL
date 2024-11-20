import 'dart:async';

import 'package:eventmanagement/Class/course.dart';
import 'package:eventmanagement/Component/button_crud.dart';
import 'package:eventmanagement/Component/diglog_load.dart';
import 'package:eventmanagement/Component/event_card.dart';
import 'package:eventmanagement/Component/form_add_account_user.dart';
import 'package:eventmanagement/Component/form_edit_account_user.dart';
import 'package:eventmanagement/Component/icon_crud.dart';
import 'package:eventmanagement/Component/listtile.dart';
import 'package:eventmanagement/Component/summary_card.dart';
import 'package:eventmanagement/Component/search_user.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Component/text_font_list.dart';
import 'package:eventmanagement/Screen/event_management_department.dart';
import 'package:eventmanagement/Class/user.dart';
import 'package:eventmanagement/Service/course_service.dart';
import 'package:eventmanagement/Service/crud_account_service.dart';
import 'package:eventmanagement/Service/info_account.dart';
import 'package:eventmanagement/Service/notification_service.dart';
import 'package:eventmanagement/Until/format_date.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/logout.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardDepartmentScreen extends StatefulWidget {
  const DashboardDepartmentScreen({super.key});

  @override
  DashboardDepartmentScreenState createState() => DashboardDepartmentScreenState();
}

class DashboardDepartmentScreenState extends State<DashboardDepartmentScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'Tất cả';
  String _selectedCourse = 'Toàn Khóa';
  int _selectedIndex = 0;
  List<Users> _users = [];
  bool _isLoading = true;
  OverlayEntry? _overlayEntry;
  String roleText = '';
  List<Courses> _courses = [];
  int _currentPage = 1;
  final int _pageSize = 50;
  bool _hasMoreUsers = true;
  bool _isLoadingMore = false;
  late Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  void _checkTokenAndFetchData() async {
    if (!await _isTokenValid()) {
      _handleLogout();
    } else {
      _fetchUsers();
      _fetchInfoAccount();
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
  Future<bool> _isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      return false;
    }
    return true;
  }

  void _handleLogout() {
    showLod(context, 'Session Expired', 'You will be redirected to the login screen.', '/login');
    Future.delayed(Duration(milliseconds: 500), () {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void initState() {
    super.initState();
    _checkTokenAndFetchData();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _fetchUsers();
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
      final users = await CrudAccountService().listUsersByDepartment(page: _currentPage, pageSize: _pageSize);
      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
      showWarningDialog(context, 'Error', e.toString(), Icons.error);
    }
  }



  final Map<String, String> roleLabels = {
    'Tất cả': 'Tất cả',
    'USER': 'Sinh viên',
    'MANAGER_DEPARTMENT': 'Quản lí sự kiện khoa',
    'MANAGER_ENTIRE': 'Quản lí sự kiện toàn trường',
  };
  final Map<String, String> roleTranslations = {
    'ADMIN_ENTIRE': 'Quản lí tổng',
    'ADMIN_DEPARTMENT': 'Quản lí khoa',
    'MANAGER_DEPARTMENT': 'Quản lí sự kiện khoa',
    'MANAGER_ENTIRE': 'Quản lí sự kiện toàn trường',
    'USER': 'Sinh viên',
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
        return FormAddAccountUserDialog(
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
        return FormEditAccountUserDialog(
          userName: user.userName,
          email: user.email,
          fullName: user.fullName,
          classId: user.classId,
          gender: user.gender,
          phone: user.phone ?? '',
          address: user.address ?? '',
          roles: user.roles,
          callback: () {
            _fetchUsers();
          },
        );
      },
    );
  }

  List<Users> _filterUsers() {
    String searchQuery = _searchController.text.trim().toLowerCase();
    return _users.where((user) {
      bool matchesFullName = user.fullName.toLowerCase().contains(searchQuery);
      bool matchesRole = _selectedRole == 'Tất cả' || (user.roles.contains(_selectedRole));
      bool matchesCourse = _selectedCourse == 'Toàn Khóa' ||
          user.classId.substring(0, 2) == _selectedCourse.substring(1);
      bool notAdmin = !user.roles.contains('ADMIN_ENTIRE');
      return matchesFullName && matchesRole && notAdmin && matchesCourse;
    }).toList();
  }

  void _showOverlay(BuildContext context, Users user, Offset position)  {


    String trainingPoints = user.trainingPoint.map((tp) {
      return '\n- Học kỳ 1: ${tp.semesterOne}\n- Học kỳ 2: ${tp.semesterTwo}\n- Học kỳ 3: ${tp.semesterThree}\n- Học kỳ 4: ${tp.semesterFour}\n- Học kỳ 5: ${tp.semesterFive}\n- Học kỳ 6: ${tp.semesterSix}\n- Học kỳ 7: ${tp.semesterSeven}\n- Học kỳ 8: ${tp.semesterEight}';
    }).join('\n');

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy - 300,
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
                if (!user.roles.contains('ADMIN_DEPARTMENT'))
                  CustomTextList(
                    text: 'Tổng số sự kiện đã đăng ký: ${user.totalEventsRegistered}',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                if (!user.roles.contains('ADMIN_DEPARTMENT'))
                  CustomTextList(
                    text: 'Điểm rèn luyện: $trainingPoints',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                CustomTextList(
                  text: 'Giới tính: ${user.gender}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                CustomTextList(
                  text: 'Email: ${user.email}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                CustomTextList(
                  text: 'Sđt: ${user.phone?.isNotEmpty == true ? user.phone : 'Chưa cập nhật'}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                if (!user.roles.contains('ADMIN_DEPARTMENT'))
                  CustomTextList(
                    text: 'Địa chỉ: ${user.address?.isNotEmpty == true ? user.address : 'Chưa cập nhật'}',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                if (!user.roles.contains('ADMIN_DEPARTMENT'))
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

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor:Color(0xFF2E3034) ,
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
        title: CustomText(text: "Quản trị", fontSize: 35, color: Colors.white),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Container(
            color: Color.fromARGB(255, 154, 154, 154).withOpacity(0.2),
            height: 2.0,
          ),
        ),
        actions: [
          PopupMenuButton(
            offset: Offset(0, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                enabled: false,
                child: FutureBuilder<List<Notifications>>(
                  future: NotificationService().getNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(0),
                        child: Text(
                          'Failed to load notifications: ${snapshot.error}',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(0),
                        child: Text(
                          'Không có thông báo',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      );
                    } else {
                      // Xác định chiều cao dựa trên số lượng thông báo
                      int itemCount = snapshot.data!.length;
                      double itemHeight = 60.0; // Giảm chiều cao mỗi thông báo
                      double maxHeight = 300.0; // Giảm chiều cao tối đa cho popup
                      double calculatedHeight = (itemCount * itemHeight).clamp(0, maxHeight);

                      return SizedBox(
                        width: 250, // Giảm chiều rộng cố định
                        height: calculatedHeight, // Chiều cao tự động
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var notification = snapshot.data![index];
                            return Card(
                              color: Colors.white,
                              elevation: 5,
                              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: ListTile(
                                  leading: Icon(Icons.notifications, color: Colors.black, size: 18),
                                  title: CustomTextList(
                                    text: "Thông báo mới ",
                                    fontSize: 11,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  subtitle: CustomTextList(
                                    text: notification.message,
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                  trailing: CustomTextList(
                                    text: DateFormatUtil.formatRelativeDate(notification.createDate),
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications, color: Colors.white, size: 24),
                // Huy hiệu số lượng thông báo
                FutureBuilder<int>(
                  future: NotificationService().countUnreadNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '...', // Loading indicator
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10, // Giảm kích thước chữ
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '!', // Error indicator
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10, // Giảm kích thước chữ
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${snapshot.data}', // Thay bằng số lượng thông báo chưa đọc
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10, // Giảm kích thước chữ
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          PopupMenuButton<int>(
            onSelected: (int result) {
              if (result == 1) {
                showLod(context, 'Thông tin cá nhân', 'Đang chuyển hướng đến trang thông tin ....', '/profile');
              } else
              if (result == 2) {
                showLogoutDialog(context);
                _timer.cancel();
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
                color:  Color(0xFF2E3034),
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
                              CustomElevatedButtonCRUD(onPressed: _showAddAccountDialog, color: Colors.white, icon: "assets/images/importExcel.png", textColor: Colors.green,),
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
                                            if (user.roles.contains('ADMIN_DEPARTMENT')) {
                                              roleText = 'Quản lí khoa';
                                            } else if (user.roles.contains('MANAGER_DEPARTMENT')) {
                                              roleText = 'Quản lí sự kiện khoa';
                                            } else if (user.roles.contains('MANAGER_ENTIRE')) {
                                              roleText = 'Quản lí sự kiện toàn trường';
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
                                                    backgroundColor:  Color(0xFF2E3034),
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
                                                        text: user.departmentId,
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
            EventDepartmentManagementScreen(),
            EventDepartmentManagementScreen(),
            EventDepartmentManagementScreen(),
            EventDepartmentManagementScreen(),
            EventDepartmentManagementScreen(),
          ],
        ),
      ),
    );
  }
}