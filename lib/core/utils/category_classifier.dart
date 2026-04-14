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
    'Health': [
      'hospital', 'clinic', 'doctor', 'medicine', 'pharmacy', 'health',
      'medical', 'test', 'scan',
    ],
    'Education': [
      'school', 'college', 'class', 'course', 'tuition', 'book', 'exam',
      'fee', 'education',
    ],
    'Entertainment': [
      'movie', 'cinema', 'game', 'concert', 'party', 'netflix', 'hotstar',
      'entertainment', 'fun',
    ],
    'Personal Care': [
      'salon', 'spa', 'haircut', 'cosmetic', 'skin', 'care', 'grooming',
      'personal care',
    ],
    'Debt': [
      'borrowed', 'debt', 'owed', 'udhar', 'loan return', 'shop pending',
      'friend payment',
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
