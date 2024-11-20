
import 'package:eventmanagement/Class/course.dart';

class Event {
  final String id;
  final String eventId;
  final String name;
  final String departmentId;
  final int capacity;
  final int currentParticipants;
  final String description;
  final String locationId;
  final DateTime dateStart;
  final DateTime dateEnd;
  final String managerName;
  final List<Participant> participants;
  final List<Courses> courses;

  Event({
    required this.id,
    required this.eventId,
    required this.name,
    required this.departmentId,
    required this.capacity,
    required this.currentParticipants,
    required this.description,
    required this.locationId,
    required this.dateStart,
    required this.dateEnd,
    required this.managerName,
    required this.participants,
    required this.courses,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      eventId: json['eventId'] ?? '',
      departmentId: json['departmentId'] ?? '',
      name: json['name'] ?? '',
      capacity: json['capacity'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      description: json['description'] ?? '',
      locationId: json['locationId'] ?? '',
      dateStart: DateTime.parse(json['dateStart']),
      dateEnd: DateTime.parse(json['dateEnd']),
      managerName: json['managerName'] ?? '',
      participants: (json['participants'] as List<dynamic>?)
          ?.map((participant) => Participant.fromJson(participant))
          .toList() ?? [],
      courses: (json['course'] as List<dynamic>?)
          ?.map((course) => Courses.fromJson(course))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'name': name,
      'departmentId': departmentId,
      'capacity': capacity,
      'currentParticipants': currentParticipants,
      'description': description,
      'locationId': locationId,
      'dateStart': dateStart.toIso8601String(),
      'dateEnd': dateEnd.toIso8601String(),
      'managerName': managerName,
      'participants': participants.map((participant) => participant.toJson()).toList(),
      'course': courses.map((course) => course.toJson()).toList(),
    };
  }
}

class Participant {
  final String userName;
  final bool confirmed;
  final bool checkInStatus;
  final String? userCheckIn;
  final bool checkOutStatus;
  final DateTime? checkInTime;
  final String? userCheckOut;
  final DateTime? checkOutTime;
  String? fullName;
  String? classId;

  Participant({
    required this.userName,
    this.confirmed = false,
    required this.checkInStatus,
    this.userCheckIn,
    required this.checkOutStatus,
    this.checkInTime,
    this.userCheckOut,
    this.checkOutTime,
    this.fullName,
    this.classId
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userName: json['userName'] ?? '',
      confirmed: json['confirmed'] ?? false,
      checkInStatus: json['checkInStatus'] ?? false,
      userCheckIn: json['userCheckIn'] ?? '',
      checkInTime: json['checkInTime'] != null ? DateTime.parse(json['checkInTime']) : null,
      checkOutStatus: json['checkOutStatus'] ?? false,
      userCheckOut: json['userCheckOut'] ?? '',
      checkOutTime: json['checkOutTime'] != null ? DateTime.parse(json['checkOutTime']) : null,
      fullName: json['fullName'] ?? 'Chưa bổ sung',
        classId: json['classId'] ?? 'Chưa bổ sung'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'confirmed': confirmed,
      'checkInStatus': checkInStatus,
      'userCheckIn': userCheckIn,
      'checkInTime': checkInTime?.toIso8601String(),
      'checkOutStatus': checkOutStatus,
      'userCheckOut': userCheckOut,
      'checkOutTime': checkOutTime?.toIso8601String(),
      'fullName': fullName,
      'classId': classId
    };
  }
}