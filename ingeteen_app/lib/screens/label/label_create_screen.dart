import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/label_provider.dart';

class CreateLabelScreen extends StatefulWidget {
  final int userId;

  const CreateLabelScreen({
    super.key,
    required this.userId,
  });

  @override
  State<CreateLabelScreen> createState() => _CreateLabelScreenState();
}

class _CreateLabelScreenState extends State<CreateLabelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _selectedColor = '#FF941A';
  bool _isSaving = false;

  final List<String> _colors = [
    '#80AFFF',
    '#FFDA55',
    '#FF941A',
    '#56E65D',
    '#E94C50',
    '#EF91B6',
    '#A985E8',
    '#D99A31',
    '#E6D5B7',
    '#666970',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    final value = hex.replaceFirst('#', '');

    return Color(
      int.parse(
        value.length == 6 ? 'FF$value' : value,
        radix: 16,
      ),
    );
  }

  // Proses menyimpan label.
  Future<void> _saveLabel() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Tampilkan dialog loading.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _SavingLabelDialog(),
    );

    // Memberikan waktu agar animasi loading terlihat.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    bool success = false;

    try {
      success = context.read<LabelProvider>().addLabel(
            userId: widget.userId,
            labelName: _nameController.text.trim(),
            colorCode: _selectedColor,
          );
    } catch (_) {
      success = false;
    }

    if (!mounted) return;

    // Tutup dialog loading.
    Navigator.of(context, rootNavigator: true).pop();

    setState(() {
      _isSaving = false;
    });

    if (success) {
      // Tampilkan dialog berhasil.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const _SuccessLabelDialog(),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } else {
      // Tampilkan dialog gagal.
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return _FailedLabelDialog(
            onTryAgain: () {
              Navigator.pop(dialogContext);
            },
            onDismiss: () {
              Navigator.pop(dialogContext);
            },
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8F1),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF26364A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Label',
          style: TextStyle(
            color: Color(0xFF26364A),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Label',
                  style: TextStyle(
                    color: Color(0xFF26364A),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Group notes and tasks for easy access.',
                  style: TextStyle(
                    color: Color(0xFF8A8A8A),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Label name',
                  style: TextStyle(
                    color: Color(0xFF26364A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'Label name',
                    hintStyle: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(
                        color: Color(0xFFEAE7E0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(
                        color: Color(0xFFFFA800),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Label name wajib diisi.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  'Label color (optional)',
                  style: TextStyle(
                    color: Color(0xFF26364A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 22,
                  runSpacing: 18,
                  children: _colors.map((color) {
                    final isSelected = _selectedColor == color;

                    return GestureDetector(
                      onTap: _isSaving
                          ? null
                          : () {
                              setState(() {
                                _selectedColor =
                                    isSelected ? null : color;
                              });
                            },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _parseColor(color),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Colors.white,
                                  width: 2,
                                )
                              : null,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 0,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 19,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: Color(0xFF8A8A8A),
                        size: 14,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Colors include label names for clarity.',
                          style: TextStyle(
                            color: Color(0xFF8A8A8A),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveLabel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA800),
                      disabledBackgroundColor:
                          const Color(0xFFFFA800).withValues(alpha: 0.6),
                      foregroundColor: const Color(0xFF26364A),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Save Label',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// DIALOG 1: SAVING LABEL
// ======================================================

class _SavingLabelDialog extends StatelessWidget {
  const _SavingLabelDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFEFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 30,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(11),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1DF),
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFFFF941A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Saving label...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101C3C),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please wait while we save your label.\n'
              'This will only take a moment.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.6,
                color: Color(0xFF777777),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// DIALOG 2: FAILED TO SAVE LABEL
// ======================================================

class _FailedLabelDialog extends StatelessWidget {
  final VoidCallback onTryAgain;
  final VoidCallback onDismiss;

  const _FailedLabelDialog({
    required this.onTryAgain,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFEFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFCE9E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Color(0xFFE94C50),
                size: 25,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Couldn't save label",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101C3C),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Your label wasn't saved. Check your connection and try again.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.6,
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onTryAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA800),
                  foregroundColor: const Color(0xFF101C3C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: onDismiss,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF101C3C),
                  side: const BorderSide(
                    color: Color(0xFFE5DED2),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Dismiss',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// DIALOG 3: LABEL SAVED
// ======================================================

class _SuccessLabelDialog extends StatelessWidget {
  const _SuccessLabelDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFEFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5EA),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF23823B),
                size: 25,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Label saved!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101C3C),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your label has been saved successfully.\n'
              "You're all set!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.6,
                color: Color(0xFF777777),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA800),
                  foregroundColor: const Color(0xFF101C3C),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
