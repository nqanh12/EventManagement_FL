class Department {
  final String id;
  final String departmentId;
  final String departmentName;

  Department({
    required this.id,
    required this.departmentId,
    required this.departmentName,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['_id'] ?? '',
      departmentId: json['departmentId'] ?? '',
      departmentName: json['departmentName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'departmentId': departmentId,
      'departmentName': departmentName,
    };
  }
}