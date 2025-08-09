class Category {
  int id;
  String name;
  double plannedBudget;

  Category({
    required this.id,
    required this.name,
    required this.plannedBudget,
  });

  Map<String, dynamic> toJson() => {
    'id'             : id            ,
    'name'           : name          ,
    'plannedBudget'  : plannedBudget ,
  };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
        id: json['id'],
        name: json['name'],
        plannedBudget: (json['plannedBudget'] as num).toDouble(),
    );
  }
}