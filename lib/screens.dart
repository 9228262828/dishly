import 'package:flutter/material.dart';
import 'models.dart';
import 'store.dart';
import 'ui.dart';

class SplashScreen extends StatefulWidget {
  final DishlyStore store;
  const SplashScreen({super.key, required this.store});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    while (!widget.store.ready) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(store: widget.store)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DishlyMark(size: 96),
            SizedBox(height: 20),
            Text(
              'DISHLY',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'REMEMBER EVERY GREAT BITE',
              style: TextStyle(
                color: mustard,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final DishlyStore store;
  const HomeScreen({super.key, required this.store});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) {
        final q = search.trim().toLowerCase();
        final restaurants = widget.store.restaurants.where((r) {
          if (q.isEmpty) return true;
          return r.name.toLowerCase().contains(q) ||
              r.cuisine.toLowerCase().contains(q);
        }).toList();

        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 90),
              children: [
                Row(
                  children: [
                    const DishlyMark(size: 52),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DISHLY',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.3,
                            ),
                          ),
                          Text(
                            'YOUR FOOD JOURNAL',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StatsScreen(store: widget.store),
                        ),
                      ),
                      icon: const Icon(Icons.bar_chart_rounded),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(store: widget.store),
                        ),
                      ),
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  onChanged: (value) => setState(() => search = value),
                  decoration: const InputDecoration(
                    hintText: 'Search restaurants or cuisine',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                _FeaturedCard(store: widget.store),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Restaurants',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addRestaurant,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('NEW'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (restaurants.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.restaurant_rounded,
                            color: deepRed,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No restaurants yet.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add your first restaurant and start saving memorable dishes.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...restaurants.map(
                    (restaurant) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RestaurantCard(
                        restaurant: restaurant,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestaurantScreen(
                              store: widget.store,
                              restaurantId: restaurant.id,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: deepRed,
            foregroundColor: Colors.white,
            onPressed: _addRestaurant,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Restaurant'),
          ),
        );
      },
    );
  }

  Future<void> _addRestaurant() async {
    final value = await showDialog<Restaurant>(
      context: context,
      builder: (_) => const RestaurantDialog(),
    );
    if (value != null) await widget.store.addRestaurant(value);
  }
}

class _FeaturedCard extends StatelessWidget {
  final DishlyStore store;
  const _FeaturedCard({required this.store});

  @override
  Widget build(BuildContext context) {
    final dish = store.featuredDish;
    final restaurant =
        dish == null ? null : store.restaurantForDish(dish.id);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: deepRed,
        borderRadius: BorderRadius.circular(26),
      ),
      child: dish == null
          ? const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FAVORITE DISH',
                  style: TextStyle(
                    color: Color(0xFFFFE3B4),
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start your food journal.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Save dishes you loved and remember what to order again.',
                  style: TextStyle(
                    color: Color(0xFFFFEED7),
                    height: 1.45,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: mustard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.local_dining_rounded,
                    color: coffee,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FAVORITE DISH',
                        style: TextStyle(
                          color: Color(0xFFFFE3B4),
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        dish.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        restaurant?.name ?? 'Restaurant',
                        style: const TextStyle(color: Color(0xFFFFEED7)),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${dish.rating.toStringAsFixed(1)} ★',
                        style: const TextStyle(
                          color: mustard,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rated = restaurant.dishes.where((e) => e.rating > 0).toList();
    final avg = rated.isEmpty
        ? 0.0
        : rated.fold<double>(0, (sum, e) => sum + e.rating) / rated.length;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: mustard.withOpacity(.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: deepRed,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (restaurant.cuisine.isNotEmpty)
                      Text(
                        restaurant.cuisine,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 7),
                    Text(
                      '${restaurant.dishes.length} dishes • ${avg.toStringAsFixed(1)} ★',
                      style: const TextStyle(
                        color: olive,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class RestaurantScreen extends StatelessWidget {
  final DishlyStore store;
  final String restaurantId;

  const RestaurantScreen({
    super.key,
    required this.store,
    required this.restaurantId,
  });

  Restaurant? _restaurant() {
    for (final item in store.restaurants) {
      if (item.id == restaurantId) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final restaurant = _restaurant();
        if (restaurant == null) {
          return const Scaffold(
            body: Center(child: Text('Restaurant not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('RESTAURANT'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _menu(context, restaurant, value),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit restaurant')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete restaurant'),
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: coffee,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (restaurant.cuisine.isNotEmpty)
                      Text(
                        restaurant.cuisine,
                        style: const TextStyle(
                          color: Color(0xFFFFE6C4),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (restaurant.locationNote.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            color: mustard,
                            size: 19,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              restaurant.locationNote,
                              style: const TextStyle(
                                color: Color(0xFFFFF1DF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Dishes',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${restaurant.dishes.length} saved',
                    style: const TextStyle(
                      color: deepRed,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (restaurant.dishes.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Center(
                      child: Text(
                        'No dishes saved yet.\nAdd the first dish you tried.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              else
                ...restaurant.dishes.map(
                  (dish) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: DishCard(
                      store: store,
                      restaurant: restaurant,
                      dish: dish,
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: deepRed,
            foregroundColor: Colors.white,
            onPressed: () => _addDish(context, restaurant),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add dish'),
          ),
        );
      },
    );
  }

  Future<void> _addDish(BuildContext context, Restaurant restaurant) async {
    final value = await showDialog<Dish>(
      context: context,
      builder: (_) => const DishDialog(),
    );
    if (value != null) await store.addDish(restaurant, value);
  }

  Future<void> _menu(
    BuildContext context,
    Restaurant restaurant,
    String value,
  ) async {
    if (value == 'edit') {
      final edited = await showDialog<Restaurant>(
        context: context,
        builder: (_) => RestaurantDialog(restaurant: restaurant),
      );
      if (edited != null) await store.updateRestaurant(edited);
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete restaurant?'),
        content: const Text('All dishes inside it will also be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await store.deleteRestaurant(restaurant.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class DishCard extends StatelessWidget {
  final DishlyStore store;
  final Restaurant restaurant;
  final Dish dish;

  const DishCard({
    super.key,
    required this.store,
    required this.restaurant,
    required this.dish,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFFFEDD3),
              child: Icon(Icons.local_dining_rounded, color: deepRed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dish.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => store.toggleFavorite(dish),
                        icon: Icon(
                          dish.favorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: dish.favorite ? deepRed : null,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${dish.category} • ${dish.rating.toStringAsFixed(1)} ★',
                    style: const TextStyle(
                      color: olive,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (dish.price > 0)
                    Text('Price: ${dish.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (dish.orderAgain)
                        const Chip(label: Text('Order again')),
                      Chip(label: Text(dateLabel(dish.visitDate))),
                    ],
                  ),
                  if (dish.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      dish.notes,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _menu(context, value),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit dish')),
                PopupMenuItem(value: 'delete', child: Text('Delete dish')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _menu(BuildContext context, String value) async {
    if (value == 'delete') {
      await store.deleteDish(restaurant, dish.id);
      return;
    }

    final edited = await showDialog<Dish>(
      context: context,
      builder: (_) => DishDialog(dish: dish),
    );
    if (edited != null) await store.updateDish(restaurant, edited);
  }
}

class RestaurantDialog extends StatefulWidget {
  final Restaurant? restaurant;
  const RestaurantDialog({super.key, this.restaurant});

  @override
  State<RestaurantDialog> createState() => _RestaurantDialogState();
}

class _RestaurantDialogState extends State<RestaurantDialog> {
  late String name;
  late String cuisine;
  late String locationNote;

  @override
  void initState() {
    super.initState();
    name = widget.restaurant?.name ?? '';
    cuisine = widget.restaurant?.cuisine ?? '';
    locationNote = widget.restaurant?.locationNote ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.restaurant == null
          ? 'Add restaurant'
          : 'Edit restaurant'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: name,
              autofocus: true,
              onChanged: (v) => name = v,
              decoration: const InputDecoration(labelText: 'Restaurant name'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: cuisine,
              onChanged: (v) => cuisine = v,
              decoration: const InputDecoration(
                labelText: 'Cuisine',
                hintText: 'Italian, Burgers, Egyptian...',
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: locationNote,
              onChanged: (v) => locationNote = v,
              decoration: const InputDecoration(
                labelText: 'Location note',
                hintText: 'Mall, street, neighborhood...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  void _save() {
    if (name.trim().isEmpty) return;
    final old = widget.restaurant;
    Navigator.pop(
      context,
      Restaurant(
        id: old?.id ?? '${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        cuisine: cuisine.trim(),
        locationNote: locationNote.trim(),
        createdAt: old?.createdAt ?? DateTime.now(),
        dishes: old?.dishes ?? [],
      ),
    );
  }
}

class DishDialog extends StatefulWidget {
  final Dish? dish;
  const DishDialog({super.key, this.dish});

  @override
  State<DishDialog> createState() => _DishDialogState();
}

class _DishDialogState extends State<DishDialog> {
  late String name;
  late String category;
  late String price;
  late double rating;
  late bool favorite;
  late bool orderAgain;
  late DateTime visitDate;
  late String notes;

  @override
  void initState() {
    super.initState();
    final d = widget.dish;
    name = d?.name ?? '';
    category = d?.category ?? 'Burger';
    price = d == null || d.price == 0 ? '' : d.price.toString();
    rating = d?.rating ?? 4;
    favorite = d?.favorite ?? false;
    orderAgain = d?.orderAgain ?? true;
    visitDate = d?.visitDate ?? DateTime.now();
    notes = d?.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dish == null ? 'Add dish' : 'Edit dish'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: name,
              autofocus: true,
              onChanged: (v) => name = v,
              decoration: const InputDecoration(labelText: 'Dish name'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: category,
              items: dishCategories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => category = v);
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (v) => price = v,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'Rating',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: deepRed,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 8,
              activeColor: mustard,
              onChanged: (v) => setState(() => rating = v),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('Visit date'),
              subtitle: Text(dateLabel(visitDate)),
              onTap: _pickDate,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: favorite,
              onChanged: (v) => setState(() => favorite = v),
              title: const Text('Favorite'),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: orderAgain,
              onChanged: (v) => setState(() => orderAgain = v),
              title: const Text('Would order again'),
            ),
            TextFormField(
              initialValue: notes,
              minLines: 2,
              maxLines: 4,
              onChanged: (v) => notes = v,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: visitDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => visitDate = picked);
  }

  void _save() {
    if (name.trim().isEmpty) return;
    Navigator.pop(
      context,
      Dish(
        id: widget.dish?.id ?? '${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        category: category,
        price: double.tryParse(price.trim()) ?? 0,
        rating: rating,
        favorite: favorite,
        orderAgain: orderAgain,
        visitDate: visitDate,
        notes: notes.trim(),
      ),
    );
  }
}

class StatsScreen extends StatelessWidget {
  final DishlyStore store;
  const StatsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('FOOD STATS')),
          body: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'Your food journal',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      value: '${store.restaurants.length}',
                      label: 'RESTAURANTS',
                      icon: Icons.storefront_rounded,
                      color: deepRed,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      value: '${store.allDishes.length}',
                      label: 'DISHES',
                      icon: Icons.local_dining_rounded,
                      color: mustard,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      value: '${store.favoriteCount}',
                      label: 'FAVORITES',
                      icon: Icons.favorite_rounded,
                      color: deepRed,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatTile(
                      value: store.averageRating.toStringAsFixed(1),
                      label: 'AVG RATING',
                      icon: Icons.star_rounded,
                      color: olive,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final DishlyStore store;
  const SettingsScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('SETTINGS')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: SwitchListTile(
                  value: store.darkMode,
                  onChanged: store.setDarkMode,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Privacy Policy',
                            body: privacyText,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Terms & Conditions'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalScreen(
                            title: 'Terms & Conditions',
                            body: termsText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  textColor: deepRed,
                  iconColor: deepRed,
                  leading: const Icon(Icons.delete_sweep_outlined),
                  title: const Text('Reset all data'),
                  subtitle: const Text(
                    'Delete all restaurants, dishes, and statistics.',
                  ),
                  onTap: () => _reset(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset DISHLY?'),
        content: const Text(
          'All restaurants and dishes will be deleted from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );

    if (ok == true) await store.resetAll();
  }
}

class LegalScreen extends StatelessWidget {
  final String title;
  final String body;

  const LegalScreen({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SelectableText(body, style: const TextStyle(height: 1.7)),
        ],
      ),
    );
  }
}

const privacyText = '''DISHLY PRIVACY POLICY

DISHLY is an offline-first restaurant and dish journal.

The current core version does not require an account, login, Firebase, backend services, advertising, analytics, cloud synchronization, or precise location access.

Restaurant names, cuisine labels, optional location notes, dish names, categories, prices, ratings, favorites, order-again preferences, visit dates, notes, statistics, and appearance preferences are stored locally on your device.

This information is used only to provide the food-journal features inside DISHLY.

The app does not require camera, microphone, contacts, phone, SMS, calendar, photos, media, files, or payment information for the current core features.

DISHLY does not intentionally sell or rent your locally stored journal information and does not use it for personalized advertising.

You can delete restaurants and dishes or reset all data from Settings. Clearing application storage or uninstalling the app may also remove locally stored information, subject to operating-system backup and restore behavior.

If future releases add online services, accounts, cloud sync, analytics, ads, location services, image uploads, payments, or other permissions, this policy should be reviewed and updated before release.''';

const termsText = '''DISHLY TERMS & CONDITIONS

DISHLY is a personal restaurant and dish journal intended for organization and entertainment.

Ratings, prices, notes, favorites, and order-again choices are personal entries created by the user and are not guarantees about quality, safety, availability, ingredients, allergens, or pricing.

DISHLY does not provide food delivery, restaurant reservations, payments, medical advice, allergy advice, nutritional advice, or guarantees about restaurant information.

You are responsible for confirming allergies, ingredients, dietary requirements, prices, opening hours, and other important restaurant information directly with the relevant restaurant.

The current core version stores information locally. We do not guarantee recovery after uninstalling the app, clearing app data, device loss, storage failure, or operating-system changes.

DISHLY is provided on an "as available" basis to the extent permitted by applicable law.''';
