import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/category_classifier.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../services/notification_service.dart';
import 'widgets/category_selector.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _selectedCategory = 'Others';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  // Voice
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _descCtrl.addListener(_autoClassify);
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    setState(() {});
  }

  void _autoClassify() {
    if (_descCtrl.text.isNotEmpty) {
      final cat = CategoryClassifier.classify(_descCtrl.text);
      if (cat != _selectedCategory) {
        setState(() => _selectedCategory = cat);
      }
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      AppSnackbar.showInfo(context, 'Microphone not available');
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (result) {
        _descCtrl.text = result.recognizedWords;
        _descCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: _descCtrl.text.length),
        );
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
    );
    setState(() => _isListening = false);
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    // Capture all context-dependent values BEFORE any await.
    final uid = context.read<AppAuthProvider>().uid;
    if (uid == null) return;
    final expenseProvider = context.read<ExpenseProvider>();
    final userModel = context.read<AppAuthProvider>().userModel;

    final expense = ExpenseModel(
      id: const Uuid().v4(),
      uid: uid,
      amount: double.parse(_amountCtrl.text.replaceAll(',', '')),
      category: _selectedCategory,
      description: _descCtrl.text.trim(),
      date: _selectedDate,
      notes: _notesCtrl.text.trim(),
    );

    try {
      await expenseProvider.addExpense(expense);

      // Check budget and trigger notification if needed.
      // monthTotal is updated reactively; read after await is safe
      // because it comes from the provider, not BuildContext.
      final monthTotal = expenseProvider.monthTotal;
      if (userModel != null &&
          userModel.monthlyBudget > 0 &&
          monthTotal >= userModel.monthlyBudget) {
        await NotificationService.instance.showBudgetAlert(
          title: AppStrings.budgetExceededTitle,
          body: AppStrings.budgetExceededBody,
        );
      }

      if (mounted) {
        AppSnackbar.showSuccess(context, 'Expense added!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Failed to save expense');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _notesCtrl.dispose();
    _speech.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Add Expense', style: AppTextStyles.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Amount ──────────────────────────────────────────
                _sectionLabel('Amount (₹)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: AppTextStyles.amountLarge.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: AppTextStyles.amountLarge.copyWith(
                      color: AppColors.primary,
                    ),
                    hintText: '0.00',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter amount';
                    if (double.tryParse(v) == null) return 'Invalid amount';
                    if (double.parse(v) <= 0) return 'Amount must be > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ── Description + Voice ──────────────────────────────
                _sectionLabel('Description'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'e.g. Lunch at mess',
                    prefixIcon:
                        const Icon(Icons.description_outlined, size: 20),
                    suffixIcon: _speechAvailable
                        ? GestureDetector(
                            onTap: _isListening
                                ? _stopListening
                                : _startListening,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isListening
                                    ? AppColors.error.withAlpha(30)
                                    : AppColors.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _isListening
                                    ? Icons.mic_rounded
                                    : Icons.mic_none_rounded,
                                color: _isListening
                                    ? AppColors.error
                                    : AppColors.primary,
                                size: 22,
                              ),
                            ),
                          )
                        : null,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter a description';
                    }
                    return null;
                  },
                ),
                if (_isListening) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _pulseDot(),
                      const SizedBox(width: 8),
                      Text('Listening...',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.error)),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                // ── Category ─────────────────────────────────────────
                _sectionLabel('Category'),
                const SizedBox(height: 4),
                Text('Auto-detected from description — tap to override',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 12),
                CategorySelector(
                  selected: _selectedCategory,
                  onSelected: (cat) =>
                      setState(() => _selectedCategory = cat),
                ),
                const SizedBox(height: 24),

                // ── Date ─────────────────────────────────────────────
                _sectionLabel('Date'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isDark
                              ? Colors.white.withAlpha(30)
                              : const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(_selectedDate),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Notes ────────────────────────────────────────────
                _sectionLabel('Notes (optional)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Any additional details...',
                    prefixIcon: Icon(Icons.notes_rounded, size: 20),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Save ─────────────────────────────────────────────
                CustomButton(
                  label: 'Save Expense',
                  onTap: _save,
                  isLoading: _isSaving,
                  icon: Icons.check_rounded,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text,
        style: AppTextStyles.labelLarge.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ));
  }

  Widget _pulseDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, v, child) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha((v * 255).toInt()),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
