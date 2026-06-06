class ModeCopyData {
  final String signal;
  final String title;
  final String text;
  final String feed;
  final String promise;
  final String time;
  final String search;

  const ModeCopyData({
    required this.signal,
    required this.title,
    required this.text,
    required this.feed,
    required this.promise,
    required this.time,
    required this.search,
  });
}

class ModeCopy {
  static const veg = ModeCopyData(
    signal: 'Pure veg kitchens selected automatically',
    title: 'Fresh veg meals, snacks aur sweets in one rush.',
    text: 'System veg mode mein sirf veg restaurants aur veg items dikhata hai, taaki customer ko confusion na ho.',
    feed: 'Veg restaurants ready for launch',
    promise: 'Veg',
    time: '24 min',
    search: 'Search paneer, samosa, thali, sweets...',
  );

  static const nonveg = ModeCopyData(
    signal: 'Non-veg kitchens and items auto sorted',
    title: 'Tandoor, biryani aur chicken cravings, full rush mode.',
    text: 'Non-veg mode on hote hi app chicken, biryani, rolls aur curry items ko priority mein settle karta hai.',
    feed: 'Non-veg restaurants ready for launch',
    promise: 'Non-Veg',
    time: '28 min',
    search: 'Search chicken, biryani, rolls, curry...',
  );

  static ModeCopyData forMode(String mode) => mode == 'veg' ? veg : nonveg;
}