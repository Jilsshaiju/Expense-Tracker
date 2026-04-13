class CategoryClassifier {
  CategoryClassifier._();

  static const Map<String, List<String>> _keywords = {
    'Food': [
      'food', 'eat', 'lunch', 'dinner', 'breakfast', 'snack', 'restaurant',
      'cafe', 'coffee', 'tea', 'pizza', 'burger', 'biryani', 'dosa', 'meal',
      'chicken', 'fish', 'rice', 'bread', 'milk', 'grocery', 'groceries',
      'swiggy', 'zomato', 'beverage', 'juice', 'hotel', 'canteen', 'mess',
    ],
    'Travel': [
      'travel', 'trip', 'flight', 'bus', 'train', 'cab', 'taxi', 'uber',
      'ola', 'auto', 'petrol', 'fuel', 'metro', 'ticket', 'transport',
      'ride', 'commute', 'toll', 'parking', 'hotel stay', 'booking',
      'rapido', 'bike',
    ],
    'Bills': [
      'bill', 'electricity', 'internet', 'wifi', 'phone', 'mobile', 'data',
      'recharge', 'rent', 'water', 'gas', 'insurance', 'emi', 'loan',
      'subscription', 'netflix', 'spotify', 'prime', 'hotstar', 'youtube',
      'broadband', 'maintenance',
    ],
    'Shopping': [
      'shop', 'shopping', 'clothes', 'shirt', 'pant', 'dress', 'shoes',
      'amazon', 'flipkart', 'meesho', 'myntra', 'ajio', 'bag', 'watch',
      'accessories', 'gadget', 'electronics', 'mobile', 'laptop', 'headphone',
      'purchase', 'buy', 'order', 'gift',
    ],
  };

  /// Returns the best matching category for a given description.
  static String classify(String description) {
    final lower = description.toLowerCase();

    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return 'Others';
  }
}
