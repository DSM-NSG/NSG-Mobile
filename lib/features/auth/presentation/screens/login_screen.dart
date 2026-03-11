import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/core/components/elevated_button.dart';
import 'package:nsg_mobile/core/text_form_field/text_form_field.dart';
import 'package:nsg_mobile/core/text_form_field/text_form_field_label.dart';
import 'package:nsg_mobile/features/auth/data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final smallSpacing = const SizedBox(height: 5);
  final middleSpacing = const SizedBox(height: 10);

  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool get _isButtonEnabled =>
      _idController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _idController.addListener(_onChanged);
    _passwordController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _idController.removeListener(_onChanged);
    _passwordController.removeListener(_onChanged);
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NsgColor.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFormFieldLabel(labelText: 'DAS 아이디'),
                      smallSpacing,
                      CustomTextFormField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          hintText: '아이디를 입력해주세요.',
                        ),
                      ),
                      middleSpacing,
                      CustomTextFormFieldLabel(labelText: '비밀번호'),
                      smallSpacing,
                      CustomTextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '비밀번호를 입력해주세요.',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Symbols.visibility_off
                                  : Symbols.visibility,
                              color: NsgColor.black400,
                              fill: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NsgElevatedButton(
                text: '로그인',
                enabled: _isButtonEnabled,
                onTap: _isButtonEnabled
                    ? () async {
                        await AuthService.setLoggedIn(true);
                        if (!mounted) return;
                        context.go('/share');
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
