enum Flavor { free, paid }

class FlavorConfig {
  final Flavor flavor;
  final String name;
  final bool canAddLocation;

  FlavorConfig._({
    required this.flavor,
    required this.name,
    required this.canAddLocation,
  });

  static FlavorConfig? _instance;

  static FlavorConfig get instance {
    _instance ??= FlavorConfig._(
      flavor: Flavor.free,
      name: 'Free',
      canAddLocation: false,
    );
    return _instance!;
  }

  static void initialize(Flavor flavor) {
    _instance = FlavorConfig._(
      flavor: flavor,
      name: flavor == Flavor.free ? 'Free' : 'Paid',
      canAddLocation: flavor == Flavor.paid,
    );
  }

  bool get isFree => flavor == Flavor.free;
  bool get isPaid => flavor == Flavor.paid;
}