import 'dart:async';
import 'package:eventmanagement/Class/department.dart';
import 'package:eventmanagement/Component/button_crud.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/form_crud_department.dart';
import 'package:eventmanagement/Component/icon_crud.dart';
import 'package:eventmanagement/Component/summary_card.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Component/text_font_list.dart';
import 'package:eventmanagement/Service/department_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DepartmentManagementScreen extends StatefulWidget {
  const DepartmentManagementScreen({super.key});

  @override
  DepartmentManagementScreenState createState() => DepartmentManagementScreenState();
}

class DepartmentManagementScreenState extends State<DepartmentManagementScreen> {
  List<Department> _departments = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDepartments() async {
    setState(() {
    });
    try {
      final departments = await DepartmentService().fetchDepartments();
      setState(() {
        _departments = departments.where((department) => department.departmentId != 'EN').toList().reversed.toList();
      });
    } catch (e) {
      setState(() {
      });
      // ignore: use_build_context_synchronously
      showWarningDialog(context, 'Error', 'Failed to load departments: ${e.toString()}', Icons.error);
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
                        title: "Khoa",
                        value: _departments.length.toString(),
                        color: Colors.black.withOpacity(0.2),
                      ),
                      CustomElevatedButtonCRUD(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return FormEditDepartmentDialog(
                                callback: _fetchDepartments,
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
                          CustomText(text: "Danh sách khoa", fontSize: 18, color: Colors.white),
                          SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 50),
                              itemCount: _departments.length,
                              itemBuilder: (context, index) {
                                var department = _departments[index];
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
                                        text: department.departmentName,
                                        fontSize: 24,
                                        color: Colors.black,
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconCRUD(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return FormEditDepartmentDialog(
                                                    department: department, // Pass the department to be edited
                                                    callback: _fetchDepartments, // Callback to refresh the department list
                                                  );
                                                },
                                              );
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