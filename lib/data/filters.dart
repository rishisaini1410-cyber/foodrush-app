class Filters {
  static const veg = ['All', 'Thali', 'Snacks', 'Sweets', 'Fast', 'Veg'];
  static const nonveg = ['All', 'Chicken', 'Biryani', 'Rolls', 'Curry', 'Fast'];

  static List<String> forMode(String mode) => mode == 'veg' ? veg : nonveg;
}