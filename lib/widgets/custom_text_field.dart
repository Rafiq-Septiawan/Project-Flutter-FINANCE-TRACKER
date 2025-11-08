import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? prefixText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixText: prefixText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade100,
      ),
    );
  }
}

// Custom TextField untuk Currency (Rupiah)
class CurrencyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const CurrencyTextField({
    super.key,
    this.controller,
    this.labelText,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: labelText ?? 'Jumlah',
      prefixText: 'Rp ',
      prefixIcon: Icons.attach_money,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Jumlah tidak boleh kosong';
            }
            if (double.tryParse(value) == null) {
              return 'Masukkan angka yang valid';
            }
            if (double.parse(value) <= 0) {
              return 'Jumlah harus lebih dari 0';
            }
            return null;
          },
      onChanged: onChanged,
    );
  }
}

// Custom TextField untuk Password
class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? Function(String?)? validator;

  const PasswordTextField({
    super.key,
    this.controller,
    this.labelText,
    this.validator,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: widget.controller,
      labelText: widget.labelText ?? 'Password',
      prefixIcon: Icons.lock,
      obscureText: _obscureText,
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Password tidak boleh kosong';
            }
            if (value.length < 8) {
              return 'Password minimal 8 karakter';
            }
            return null;
          },
    );
  }
}
