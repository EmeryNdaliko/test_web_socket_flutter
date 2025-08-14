class UserModel {
  int? id = 0;
  String name = '';
  String? image = '';
  String? password = '';

  UserModel();
  UserModel.build({this.id, required this.name, this.image, this.password});

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel.build(
      id: int.tryParse(data['id'].toString()) ?? 0,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'password': password,
  };
}
