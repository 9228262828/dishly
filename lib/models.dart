class Dish {
  String id;
  String name;
  String category;
  double price;
  double rating;
  bool favorite;
  bool orderAgain;
  DateTime visitDate;
  String notes;

  Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.favorite,
    required this.orderAgain,
    required this.visitDate,
    required this.notes,
  });

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? 'Other',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        favorite: json['favorite'] as bool? ?? false,
        orderAgain: json['orderAgain'] as bool? ?? false,
        visitDate:
            DateTime.tryParse(json['visitDate'] as String? ?? '') ?? DateTime.now(),
        notes: json['notes'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'rating': rating,
        'favorite': favorite,
        'orderAgain': orderAgain,
        'visitDate': visitDate.toIso8601String(),
        'notes': notes,
      };
}

class Restaurant {
  String id;
  String name;
  String cuisine;
  String locationNote;
  DateTime createdAt;
  List<Dish> dishes;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.locationNote,
    required this.createdAt,
    required this.dishes,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        cuisine: json['cuisine'] as String? ?? '',
        locationNote: json['locationNote'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        dishes: ((json['dishes'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => Dish.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cuisine': cuisine,
        'locationNote': locationNote,
        'createdAt': createdAt.toIso8601String(),
        'dishes': dishes.map((e) => e.toJson()).toList(),
      };
}
