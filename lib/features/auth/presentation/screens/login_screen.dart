import 'dart:developer';

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
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isButtonEnabled =>
      _idController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      !_isLoading;

  @override
  void initState() {
    super.initState();
    _idController.addListener(_onChanged);
    _passwordController.addListener(_onChanged);
    log('로그인 화면 진입', name: 'Login');
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

  Future<void> _onLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    log('로그인 시도: id=${_idController.text}', name: 'Login');
    try {
      await AuthService.login(_idController.text.trim(), _passwordController.text);
      log('로그인 성공', name: 'Login');
      if (!mounted) return;
      context.go('/map');
    } on AuthException catch (e) {
      log('로그인 실패: $e', name: 'Login');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      log('로그인 오류: $e', name: 'Login');
      if (!mounted) return;
      setState(() {
        _errorMessage = '네트워크 오류가 발생했습니다. 다시 시도해주세요.';
        _isLoading = false;
      });
    }
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
                      if (_errorMessage != null) ...[
                        middleSpacing,
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: NsgColor.danger,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NsgElevatedButton(
                text: _isLoading ? '로그인 중...' : '로그인',
                enabled: _isButtonEnabled,
                onTap: _isButtonEnabled ? _onLogin : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
