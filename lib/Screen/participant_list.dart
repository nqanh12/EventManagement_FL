import 'dart:convert';
import 'dart:io';
import 'package:eventmanagement/Component/button_access.dart';
import 'package:eventmanagement/Component/diglog_warning.dart';
import 'package:eventmanagement/Component/summary_card.dart';
import 'package:eventmanagement/Component/search_event.dart';
import 'package:eventmanagement/Component/text_font_family.dart';
import 'package:eventmanagement/Component/text_font_list.dart';
import 'package:eventmanagement/Service/localhost.dart';
import 'package:eventmanagement/Service/info_account.dart';
import 'package:eventmanagement/Until/format_date.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:eventmanagement/Component/event_card.dart';
import 'package:eventmanagement/Class/event.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';

class ParticipantListScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final DateTime dateEnd;
  const ParticipantListScreen({super.key, required this.eventId, required this.eventName, required this.dateEnd});

  @override
  ParticipantListScreenState createState() => ParticipantListScreenState();
}

class ParticipantListScreenState extends State<ParticipantListScreen> {
  final List<Participant> _students = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Tất cả';
  bool _selectAll = false;
  final Set<String> _selectedStudents = {};

  @override
  void initState() {
    super.initState();
    _fetchParticipants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchParticipants({int page = 1, int pageSize = 100}) async {
    if (!mounted) return;

    setState(() {});

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      setState(() {});
      return;
    }

    String bearerToken = 'Bearer $token';
    final response = await http.get(
      Uri.parse('${baseUrl}api/events/participants/${widget.eventId}?page=$page&pageSize=$pageSize'),
      headers: {
        'Authorization': bearerToken,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['code'] == 1000) {
        final List<Participant> participants = (data['result']['participants'] as List)
            .map((participantJson) => Participant.fromJson(participantJson))
            .toList();

        // Sort participants by check-out time, latest first
        participants.sort((a, b) {
          final aTime = a.checkOutTime ?? a.checkInTime;
          final bTime = b.checkOutTime ?? b.checkInTime;
          if (aTime != null && bTime != null) {
            return bTime.compareTo(aTime);
          } else if (aTime != null) {
            return -1;
          } else if (bTime != null) {
            return 1;
          }
          return 0;
        });

        // Fetch full name and class for each participant in parallel
        await Future.wait(participants.map((participant) async {
          try {
            final infoAccountService = InfoAccountService();
            final result = await infoAccountService.fetchFullNameAndClass(participant.userName);
            participant.fullName = result['fullName'];
            participant.classId = result['classId'];
          } catch (e) {
            // Handle error
          }
        }));

        if (!mounted) return;
        setState(() {
          _students
            ..clear()
            ..addAll(participants);
        });

        // Check if there are more participants to fetch
        if (participants.length == pageSize) {
          _fetchParticipants(page: page + 1, pageSize: pageSize);
        }
      } else {
        if (!mounted) return;
        setState(() {});
        throw Exception('Failed to fetch participants');
      }
    } else {
      if (!mounted) return;
      setState(() {});
      throw Exception('Failed to fetch participants');
    }
  }

  Future<void> _calculateTrainingPoints() async {
    showLoadingDialog(context, "Đang tính điểm...");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      Navigator.of(context).pop(); // Close the loading dialog
      throw Exception('Token is missing');
    }

    String bearerToken = 'Bearer $token';
    String url = '${baseUrl}api/users/calculateTrainingPointsForCurrentSemester/${widget.eventId}';

    List<Map<String, String>> requestBody = _selectedStudents.map((userName) {
      final student = _students.firstWhere((student) => student.userName == userName);
      return {
        "userName": student.userName,
        "classId": student.classId ?? '',
      };
    }).toList();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': bearerToken,
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['code'] == 1000) {
        showWarningDialog(context, "Thông báo", "Tính điểm hoàn tất", Icons.check_circle, Colors.green);

        // Call the additional API for each selected student
        for (var userName in _selectedStudents) {
          final confirmUrl = '${baseUrl}api/events/confirmPointByAdmin/${widget.eventId}/$userName';
          final confirmResponse = await http.put(
            Uri.parse(confirmUrl),
            headers: {
              'Authorization': bearerToken,
              'Content-Type': 'application/json',
            },
          );

          if (confirmResponse.statusCode != 200) {
            throw Exception('Failed to call confirm API: ${confirmResponse.statusCode}');
          }

          final confirmData = json.decode(confirmResponse.body);
          if (confirmData['code'] != 1000) {
            throw Exception('Failed to confirm points: ${confirmData['code']}');
          }
        }

        // Fetch updated participants data
        await _fetchParticipants();
      } else {
        throw Exception('Failed to calculate training points: ${data['code']}');
      }
    } else {
      throw Exception('Failed to call API: ${response.statusCode}');
    }

    Navigator.of(context).pop(); // Close the loading dialog
  }
  void showLoadingDialog(BuildContext context,String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text(text),
              ],
            ),
          ),
        );
      },
    );
  }
  List<Participant> _filterStudents() {
    String searchQuery = _searchController.text.toLowerCase();
    return _students.where((student) {
      bool matchesSearch = student.fullName?.toLowerCase().contains(searchQuery) ?? false;
      bool matchesStatus = _selectedStatus == 'Tất cả' ||
          (_selectedStatus == 'Đã hoàn thành' && student.checkInStatus && student.checkOutStatus) ||
          (_selectedStatus == 'Chưa hoàn thành' && (!student.checkInStatus || !student.checkOutStatus));
      return matchesSearch && matchesStatus;
    }).toList();
  }

  int _countCompletedStudents() {
    return _students.where((student) => student.checkInStatus && student.checkOutStatus).length;
  }

  int _countIncompleteStudents() {
    return _students.where((student) => !student.checkInStatus || !student.checkOutStatus).length;
  }
  int _countConfirmedStudents() {
    return _students.where((student) => student.confirmed).length;
  }
  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      if (_selectAll) {
        _selectedStudents.addAll(_students.map((student) => student.userName));
      } else {
        _selectedStudents.clear();
      }
    });
  }
  void _exportToExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Add header row
    sheetObject.appendRow(['MSSV', 'Họ và tên', 'Lớp', 'Trạng thái check - in', 'Giờ check - in', 'Trạng thái check - out', 'Giờ check - out']);

    // Add data rows
    for (var student in _students) {
      sheetObject.appendRow([
        student.userName,
        student.fullName ?? 'N/A',
        student.classId ?? 'N/A',
        student.checkInStatus ? 'Hoàn thành' : 'Chưa hoàn thành',
        student.checkInTime != null ? DateFormatUtil.formatDateTime(student.checkInTime!.add(const Duration(hours: 7))) : 'N/A',
        student.checkOutStatus ? 'Hoàn thành' : 'Chưa hoàn thành',
        student.checkOutTime != null ? DateFormatUtil.formatDateTime(student.checkOutTime!.add(const Duration(hours: 7))) : 'N/A',
      ]);
    }

    // Save the file
    var fileBytes = excel.save();
    if (fileBytes != null) {
      // Use the path_provider package to get the directory to save the file
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/students.xlsx';
      final file = File(path);
      await file.writeAsBytes(fileBytes, flush: true);

      // Show a success message
      showWarningDialog(context, "Thông báo", "Xuất file excel thành công $path", Icons.check_circle, Colors.green);
    }
  }
  void _toggleStudentSelection(String userName, bool? value) {
    setState(() {
      if (value ?? false) {
        _selectedStudents.add(userName);
      } else {
        _selectedStudents.remove(userName);
      }
    });
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
                      Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                          ),
                          child: IconButton(
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String? role = prefs.getString('role');
                              if (role?.contains('ADMIN_ENTIRE') ?? false) {
                                context.go('/dashboard');
                              } else {
                                context.go('/dashboard_department');
                              }
                            },
                            icon: Icon(Icons.arrow_back),
                          )
                      ),
                      Expanded(
                        child: SearchEvent(
                          textSearch: "Tìm kiếm sinh viên theo tên",
                          searchController: _searchController,
                          onChanged: (value) {
                            setState(() {});
                          },
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
                          items: <String>['Tất cả', 'Đã hoàn thành', 'Chưa hoàn thành']
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
                      Container(
                        margin: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              focusColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              hoverColor: Colors.white,
                              activeColor: Colors.white,
                              checkColor: Colors.white,
                              value: _selectAll,
                              onChanged: _toggleSelectAll,
                            ),
                            CustomElevatedButton(
                              onPressed: () {
                                if (DateTime.now().isBefore(widget.dateEnd)) {
                                  showWarningDialog(context, "Lỗi", "Sự kiện chưa kết thúc, không thể tính điểm", Icons.error, Colors.red);
                                }else if (_students.length == _countConfirmedStudents()) {
                                  showWarningDialog(context, "Lỗi", "Tất cả sinh viên đã được tính điểm hoàn tất", Icons.error, Colors.red);
                                } else {
                                  _calculateTrainingPoints();
                                }
                              },
                              text: "Tính điểm",
                              color: const Color.fromARGB(255, 255, 255, 255),
                              icon: Icons.calculate_outlined,
                              textColor: Colors.black,
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 20),
                        child:CustomElevatedButton(
                            onPressed: _exportToExcel,
                            text: "Xuất Excel",
                            color: const Color.fromARGB(255, 255, 255, 255),
                            icon: Icons.file_download,
                            textColor: Colors.black,
                            ),),
                      const SizedBox(height: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SummaryCard(title: "Sinh viên", value: _students.length.toString(), color: Colors.black.withOpacity(0.2)),
                      SummaryCard(title: "Chưa hoàn thành", value: _countIncompleteStudents().toString(), color: Colors.black.withOpacity(0.2)),
                      SummaryCard(title: "Đã hoàn thành", value: _countCompletedStudents().toString(), color: Colors.black.withOpacity(0.2)),
                      SummaryCard(
                        title: "Đã tính điểm",
                        value: _countConfirmedStudents().toString(),
                        color: Colors.black.withOpacity(0.2),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 20),
                        child: Column(
                          children: [
                            CustomElevatedButton(
                              onPressed: () {
                                context.go('/historyChange/${widget.eventId}/${widget.eventName}/${widget.dateEnd}');
                              },
                              text: "Lịch sử",
                              color: const Color.fromARGB(255, 255, 255, 255),
                              icon: Icons.history,
                              textColor: Colors.black,
                            ),
                            const SizedBox(height: 10),
                            CustomElevatedButton(
                              onPressed: () {
                                context.go('/feedback/${widget.eventId}/${widget.eventName}/${widget.dateEnd}');
                              },
                              text: "Phản hồi",
                              color: const Color.fromARGB(255, 255, 255, 255),
                              icon: Icons.feedback,
                              textColor: Colors.black,
                            ),

                            // Add more widgets here if needed
                          ],
                        ),
                      )
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
                                CustomText(text: "Danh sách sinh viên của ${widget.eventName}", fontSize: 18, color: Colors.white),
                                SizedBox(height: 10),
                                Expanded(
                                  child: _filterStudents().isEmpty
                                      ? Center(
                                    child: CustomText(
                                      text: "Hiện tại chưa có sinh viên đăng kí",
                                      fontSize: 18,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                  )
                                      : ListView.builder(
                                    itemCount: _filterStudents().length,
                                    itemBuilder: (context, index) {
                                      var student = _filterStudents()[index];
                                      String statusText;
                                      Color statusColor;

                                      if (student.checkInStatus && student.checkOutStatus) {
                                        statusText = "Đã hoàn thành";
                                        statusColor = Colors.green;
                                      } else if (!student.checkInStatus) {
                                        statusText = "Chưa check-in";
                                        statusColor = Colors.red;
                                      } else if (!student.checkOutStatus) {
                                        statusText = "Chưa check-out";
                                        statusColor = Colors.orange;
                                      } else {
                                        statusText = "Chưa hoàn thành";
                                        statusColor = Colors.red;
                                      }
                                      return EventCard(
                                        listTile: ListTile(
                                          leading: student.confirmed
                                              ? SizedBox.shrink()
                                              : Checkbox(
                                            focusColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                            hoverColor: Colors.white,
                                            activeColor: Colors.black87,
                                            checkColor: Colors.white,
                                            value: _selectedStudents.contains(student.userName),
                                            onChanged: (value) => _toggleStudentSelection(student.userName, value),
                                          ),
                                          title: CustomTextList(
                                            text: " ${student.fullName ?? 'Chưa bổ sung'}",
                                            fontSize: 24,
                                            color: Colors.black,
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CustomTextList(
                                                text: "MSSV: ${student.userName}",
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                              CustomTextList(
                                                text: "Lớp: ${student.classId ?? 'Chưa bổ sung'}",
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  CustomTextList(
                                                    text: "Check - in : ",
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                  Icon(
                                                    student.checkInStatus ? Icons.check_circle : Icons.cancel,
                                                    color: student.checkInStatus ? Colors.green : Colors.red,
                                                  ),
                                                ],
                                              ),
                                              CustomTextList(
                                                text: "Người check-in: ${student.userCheckIn ?? 'N/A'}",
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                              CustomTextList(
                                                text: "Giờ vào: ${student.checkInTime != null ? DateFormatUtil.formatDateTime(student.checkInTime!.add(const Duration(hours: 7))) : 'N/A'}",
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                              Row(
                                                children: [
                                                  CustomTextList(
                                                    text: "Check - out : ",
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                  Icon(
                                                    student.checkOutStatus ? Icons.check_circle : Icons.cancel,
                                                    color: student.checkOutStatus ? Colors.green : Colors.red,
                                                  ),
                                                ],
                                              ),
                                              CustomTextList(
                                                text: "Người check-out: ${student.userCheckOut ?? 'N/A'}",
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                              CustomTextList(
                                                text: "Giờ ra: ${student.checkOutTime != null ? DateFormatUtil.formatDateTime(student.checkOutTime!.add(const Duration(hours: 7))) : 'N/A'}",
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ],
                                          ),
                                          trailing: CustomText(text: statusText, fontSize: 30, color: statusColor),
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