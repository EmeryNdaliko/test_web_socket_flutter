class UserModel {
  int id;
  String name;
  String image;

  UserModel({required this.id, required this.name, required this.image});

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      id: int.tryParse(data['id'].toString()) ?? 0,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'image': image};
}