import 'package:flutter/material.dart';

class TodoForm extends StatefulWidget {
  const TodoForm({
    super.key,
    required this.onSubmit,
    this.initialTitle = '',
    this.initialDescription = '',
    this.submitLabel = 'Simpan',
  });

  final Future<bool> Function(String title, String description) onSubmit;
  final String initialTitle;
  final String initialDescription;
  final String submitLabel;

  @override
  State<TodoForm> createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Judul',
              prefixIcon: Icon(Icons.title_rounded),
            ),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isSubmitting ? null : _submit,
            icon: _isSubmitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(widget.submitLabel, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    final success = await widget.onSubmit(
      _titleController.text,
      _descriptionController.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _titleController.clear();
      _descriptionController.clear();
      FocusScope.of(context).unfocus();
    }
  }
}
