class AppStrings {
  AppStrings._();

  static const String appName = 'PanamFlow';
  static const String tagline = 'Every Spend Shapes You, Every Save Secures You';

  // Auth
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String orContinueWith = 'or continue with';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String dontHaveAccount = "Don't have an account? ";

  // Nav
  static const String home = 'Home';
  static const String analytics = 'Analytics';
  static const String addExpense = 'Add Expense';
  static const String goals = 'Goals';
  static const String profile = 'Profile';

  // Expense
  static const String amount = 'Amount';
  static const String category = 'Category';
  static const String description = 'Description';
  static const String notes = 'Notes (optional)';
  static const String date = 'Date';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';

  // Categories
  static const String food = 'Food';
  static const String travel = 'Travel';
  static const String bills = 'Bills';
  static const String shopping = 'Shopping';
  static const String others = 'Others';

  static const List<String> categories = [food, travel, bills, shopping, others];

  // Analytics
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String spendingByCategory = 'Spending by Category';
  static const String spendingTrend = 'Spending Trend';

  // Profile
  static const String monthlyIncome = 'Monthly Income';
  static const String monthlyBudget = 'Monthly Budget';
  static const String savingsGoal = 'Savings Goal';
  static const String editProfile = 'Edit Profile';
  static const String signOut = 'Sign Out';
  static const String darkMode = 'Dark Mode';

  // Budget
  static const String budgetUsed = 'Budget Used';
  static const String remaining = 'Remaining';
  static const String overspent = 'Overspent';

  // Insights
  static const String insights = 'Smart Insights';

  // Notifications
  static const String budgetExceededTitle = 'Budget Alert!';
  static const String budgetExceededBody =
      'You have exceeded your monthly budget. Time to cut back!';
  static const String weeklySummaryTitle = 'Weekly Summary';
  static const String savingsReminderTitle = 'Savings Reminder';
  static const String savingsReminderBody =
      'Have you transferred to your savings today?';

  // Currency
  static const String currencySymbol = '₹';
}
