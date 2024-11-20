import 'dart:async';
import 'package:eventmanagement/Class/course.dart';
import 'package:eventmanagement/Class/department.dart';
import 'package:eventmanagement/Component/button_crud.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/form_add_event_department.dart';
import 'package:eventmanagement/Component/form_edit_event_department.dart';
import 'package:eventmanagement/Component/icon_crud.dart';
import 'package:eventmanagement/Component/show_log_delete.dart';
import 'package:eventmanagement/Component/summary_card.dart';
import 'package:eventmanagement/Component/search_event.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Component/text_font_list.dart';
import 'package:eventmanagement/Service/course_service.dart';
import 'package:eventmanagement/Service/department_service.dart';
import 'package:eventmanagement/Service/user_service.dart';
import 'package:eventmanagement/Until/format_date.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/event_card.dart';
import 'package:eventmanagement/Class/event.dart';
import 'package:eventmanagement/Service/crud_event_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
class EventDepartmentManagementScreen extends StatefulWidget {
  const EventDepartmentManagementScreen({super.key});

  @override
  EventDepartmentManagementScreenState createState() => EventDepartmentManagementScreenState();
}

class EventDepartmentManagementScreenState extends State<EventDepartmentManagementScreen> {
  List<Event> _events = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedYear = 'Tất cả';
  String _selectedStatus = 'Tất cả';
  String _selectedSemester = 'Tất cả';
  String _selectedCourse = 'Tất cả';
  Timer? _timer;
  OverlayEntry? _overlayEntry;
  List<Department> _departments = [];
  List<Courses> _courses = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _fetchDepartments();
    _fetchCourses();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final events = await CrudEventService().fetchEventsByDepartment();
      events.sort((a, b) => b.dateStart.compareTo(a.dateStart)); // Sort events in reverse order by dateStart
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }
  void _fetchCourses() async {
    try {
      final courses = await CourseService().getAllCourses();
      final filter = courses.where((course) => course.courseId != 'K0').toList().reversed.toList();
      setState(() {
        _courses = filter;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Error', 'Failed to load courses: ${e.toString()}', Icons.error);
    }
  }
  String _getCourseName(String courseId) {
    final course = _courses.firstWhere((course) => course.courseId == courseId.toString(), orElse: () => Courses(courseId: '', courseName: '', id: ''));
    return course.courseName;
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

  String _getDepartmentName(String departmentId) {
    final department = _departments.firstWhere((dept) => dept.departmentId == departmentId, orElse: () => Department(id: '', departmentId: '', departmentName: 'Unknown'));
    return department.departmentName;
  }
void editEvent(Event event) {
  Event modifiedEvent = Event(
    id: event.id,
    eventId: event.eventId,
    name: event.name,
    departmentId: event.departmentId,
    capacity: event.capacity,
    currentParticipants: event.currentParticipants,
    description: event.description,
    locationId: event.locationId,
    dateStart: event.dateStart.add(const Duration(hours: 7)),
    dateEnd: event.dateEnd.add(const Duration(hours: 7)),
    managerName: event.managerName,
    participants: event.participants,
    courses: event.courses,
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return FormEditEventDepartmentDialog(
        event: modifiedEvent,
        callback: () {
          _fetchEvents();
        },
      );
    },
  );
}
  List<Event> _filterEvents() {
    String searchQuery = _searchController.text.toLowerCase();
    return _events.where((event) {
      bool courseMatches = _selectedCourse == 'Tất cả' || event.courses.any((course) => course.courseId.toString() == _selectedCourse);
      bool matchesName = event.name.toLowerCase().contains(searchQuery);
      bool matchesYear = _selectedYear == 'Tất cả' || event.dateStart.year.toString() == _selectedYear;
      bool matchesStatus = _selectedStatus == 'Tất cả' ||
          (_selectedStatus == 'Đã kết thúc' && event.dateEnd.isBefore(DateTime.now())) ||
          (_selectedStatus == 'Chưa kết thúc' && event.dateEnd.isAfter(DateTime.now())) ||
          (_selectedStatus == 'Đang hoạt động' && event.dateStart.isBefore(DateTime.now()) && event.dateEnd.isAfter(DateTime.now()));
      bool matchesSemester = _selectedSemester == 'Tất cả' ||
          (_selectedSemester == 'HK1' && (event.dateStart.month >= 7 || event.dateStart.month <= 2)) ||
          (_selectedSemester == 'HK2' && (event.dateStart.month >= 3 && event.dateStart.month <= 6));
      return matchesName && matchesYear && matchesStatus && matchesSemester  && courseMatches;
    }).toList();
  }

  void _showOverlay(BuildContext context, Event event, Offset position) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy - 250,
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
                  text: event.name,
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 8),
                CustomTextList(
                  text: _getDepartmentName(event.departmentId),
                  fontSize: 16,
                  color: Colors.black,
                ),
                Text(
                  "Mô tả: ${event.description}",
                  style: GoogleFonts.lobster(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                CustomTextList(
                  text: 'Sức chứa: ${event.capacity}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                CustomTextList(
                  text: 'Số người đã đăng kí: ${event.currentParticipants}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                CustomTextList(
                  text: 'Địa điểm: ${event.locationId}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                CustomTextList(
                  text: 'Người chủ trì: ${event.managerName}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                CustomTextList(
                  text: 'Ngày bắt đầu: ${DateFormatUtil.formatDateTime(event.dateStart.add(const Duration(hours: 7)))}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                CustomTextList(
                  text: 'Ngày kết thúc: ${DateFormatUtil.formatDateTime(event.dateEnd.add(const Duration(hours: 7)))}',
                  fontSize: 16,
                  color: Colors.black,
                ),
                CustomTextList(
                  text: "Khóa được đăng kí: ${event.courses.map((course) => _getCourseName(course.courseId)).join(', ')}",
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
  void addEvent() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FormAddEventDepartmentDialog(
          callback: () {
            _fetchEvents();
          },
        );
      },
    );
  }
  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SearchEvent(
                          textSearch: 'Tìm kiếm sự kiện theo tên',
                          searchController: _searchController,
                          onChanged: (value) {
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
                          value: _selectedYear,
                          items: <String>['Tất cả', ...List.generate(DateTime.now().year - 2020, (index) => (DateTime.now().year - index).toString())]
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: CustomText(text: value, fontSize: 18, color: Colors.black),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedYear = newValue!;
                            });
                          },
                          style: TextStyle(color: Colors.black),
                          dropdownColor: Colors.white,
                          underline: SizedBox(),
                          icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                        ),
                      ) ,
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
                          value: _selectedSemester,
                          items: <String>['Tất cả', 'HK1', 'HK2']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: CustomText(text: value, fontSize: 18, color: Colors.black),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSemester = newValue!;
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
                          items: <String>['Tất cả', ..._courses.map((course) => course.courseId.toString())]
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: CustomText(
                                text: value == 'Tất cả' ? 'Tất cả' : _courses.firstWhere((course) => course.courseId.toString() == value).courseName,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCourse = newValue!;
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
                        margin: const EdgeInsets.only(right: 20),
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
                          value: _selectedStatus,
                          items: <String>['Tất cả', 'Đã kết thúc', 'Chưa kết thúc', 'Đang hoạt động']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: CustomText(text: value, fontSize: 18, color: Colors.black),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedStatus = newValue!;
                            });
                          },
                          style: TextStyle(color: Colors.black),
                          dropdownColor: Colors.white,
                          underline: SizedBox(),
                          icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SummaryCard(title: "Sự kiện", value: _filterEvents().length.toString(), color: Colors.black.withOpacity(0.2)),
                      CustomElevatedButtonCRUD(onPressed: addEvent, color: Colors.white, icon: "assets/images/add.png", textColor: Colors.green,),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Row(
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
                                CustomText(text: "Danh sách sự kiện ", fontSize: 18, color: Colors.white),
                                SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    padding: EdgeInsets.symmetric(horizontal: 50),
                                    itemCount: _filterEvents().length,
                                    itemBuilder: (context, index) {
                                      var event = _filterEvents()[index];
                                      bool isPastEvent = event.dateEnd.isBefore(DateTime.now());
                                      return MouseRegion(
                                        onEnter: (PointerEnterEvent event) {
                                          _showOverlay(context, _filterEvents()[index], event.position);
                                        },
                                        onExit: (PointerExitEvent event) {
                                          _hideOverlay();
                                        },
                                        child:Opacity(
                                          opacity: event.dateStart.isAfter(DateTime.now()) || event.dateEnd.isBefore(DateTime.now()) ? 0.5 : 1.0,
                                          child: GestureDetector(
                                            onTap: () {
                                              context.go('/participant_list/${event.eventId}/${event.name}/${event.dateEnd}');
                                            },
                                            child: EventCard(
                                              listTile: ListTile(
                                                leading: Icon(
                                                  Icons.circle,
                                                  color: event.dateStart.isAfter(DateTime.now())
                                                      ? Colors.yellow
                                                      : (event.dateEnd.isBefore(DateTime.now()) ? Colors.red : Colors.green),
                                                ),
                                                title: CustomTextList(
                                                  text: event.name,
                                                  fontSize: 24,
                                                  color: Colors.black,
                                                ),
                                                subtitle: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomTextList(
                                                      text: "Người chủ trì: ${event.managerName}",
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                    CustomTextList(
                                                      text: "Ngày bắt đầu: ${DateFormatUtil.formatDateTime(event.dateStart.add(const Duration(hours: 7)))}",
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                    ),
                                                    CustomTextList(
                                                      text: "Ngày kết thúc: ${DateFormatUtil.formatDateTime(event.dateEnd.add(const Duration(hours: 7)))}",
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
                                                        editEvent(event);
                                                      },
                                                      icon: Icons.edit,
                                                      color: Colors.orange,
                                                    ),
                                                    const SizedBox(width: 50),
                                                    IconCRUD(
                                                      onPressed: () async {
                                                        final showLogDelete = ShowLogDeleteState();
                                                        await showLogDelete.showConfirmationDialog(
                                                          context: context,
                                                          title: 'Xác nhận xóa',
                                                          content: 'Bạn có chắc chắn muốn xóa sự kiện này không?',
                                                          onConfirm: () async {
                                                            await Future.wait([
                                                              UserService().deleteEventAllUsers(event.eventId),
                                                              CrudEventService().deleteEvent(event.eventId),
                                                            ]);
                                                            _fetchEvents();
                                                            _filterEvents();
                                                          },
                                                        );
                                                      },
                                                      icon: Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
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
      ),
    );
  }
}