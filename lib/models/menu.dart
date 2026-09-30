class Menu {
  final List<MenuItem> foods;
  final List<MenuItem> drinks;

  const Menu({required this.foods, required this.drinks});

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
    foods: List<MenuItem>.from(json['foods'].map((x) => MenuItem.fromJson(x))),
    drinks: List<MenuItem>.from(
      json['drinks'].map((x) => MenuItem.fromJson(x)),
    ),
  );
}

class MenuItem {
  final String name;

  const MenuItem({required this.name});

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      MenuItem(name: json['name']);
}
