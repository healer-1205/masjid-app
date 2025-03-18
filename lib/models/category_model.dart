


class ModelCategories {
  String? sId;
  String? name;
  String? description;
  String? image;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  int? iV;

  ModelCategories(
      {this.sId,
        this.name,
        this.description,
        this.image,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.iV});

  ModelCategories.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    image = json['image'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['image'] = this.image;
    data['isActive'] = this.isActive;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
