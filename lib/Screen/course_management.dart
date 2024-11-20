import 'dart:async';
import 'package:eventmanagement/Class/course.dart';
import 'package:eventmanagement/Component/button_crud.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/form_crud_course.dart';
import 'package:eventmanagement/Component/icon_crud.dart';
import 'package:eventmanagement/Component/show_log_delete.dart';
import 'package:eventmanagement/Component/summary_card.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Component/text_font_list.dart';
import 'package:eventmanagement/Service/course_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  CourseManagementScreenState createState() => CourseManagementScreenState();
}

class CourseManagementScreenState extends State<CourseManagementScreen> {
  List<Courses> _courses = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCourses() async {
    setState(() {
    });
    try {
      final courses = await CourseService().getAllCourses();
      setState(() {
        _courses = courses.where((course) => course.courseId != "K0").toList().reversed.toList();
      });
    } catch (e) {
      setState(() {
      });
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Error', 'Failed to load courses: ${e.toString()}', Icons.error);
    }
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SummaryCard(
                        title: "Khóa học",
                        value: _courses.length.toString(),
                        color: Colors.black.withOpacity(0.2),
                      ),
                      CustomElevatedButtonCRUD(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return FormAddCourseDialog(// Pass the course to be edited
                                callback: _fetchCourses, // Callback to refresh the course list
                              );
                            },
                          );
                        },
                        color: Colors.white,
                        icon: "assets/images/add.png",
                        textColor: Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
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
                          CustomText(text: "Danh sách các  Khóa", fontSize: 18, color: Colors.white),
                          SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              itemCount: _courses.length,
                              itemBuilder: (context, index) {
                                var course = _courses[index];
                                return MouseRegion(
                                  onEnter: (PointerEnterEvent event) {
                                    // Add any hover effect if needed
                                  },
                                  onExit: (PointerExitEvent event) {
                                    // Add any hover effect if needed
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 6,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      title: CustomTextList(
                                        text: course.courseName,
                                        fontSize: 24,
                                        color: Colors.black,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconCRUD(
                                            onPressed: () async {
                                              final showLogDelete = ShowLogDeleteState();
                                              await showLogDelete.showConfirmationDialog(
                                                context: context,
                                                title: 'Xác nhận xóa',
                                                content: 'Bạn có chắc chắn muốn xóa khóa học này không?',
                                                onConfirm: () async {
                                                  await CourseService().deleteCourse(course.id);
                                                  _fetchCourses();
                                                },
                                              );
                                            },
                                            icon: Icons.delete,
                                            color: Colors.red,
                                          )
                                        ],
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}