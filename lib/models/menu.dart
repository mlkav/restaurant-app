import 'menu_item.dart';

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
