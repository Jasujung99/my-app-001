// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 참조 UI의 색상 팔레트
class AppColors {
  // Base Colors
  static const Color paper = Color(0xFFFAF8F1);
  static const Color midnight = Color(0xFF2F3E4B);
  static const Color grain = Color(0xFFE8DEC7);
  static const Color ink = Color(0xFF222426);
  static const Color stardust = Color(0xFFF4EFE3);
  
  // Accent & Point Colors
  static const Color accent = Color(0xFF6B8CAE); // 생동감 있는 블루
  static const Color primary = Color(0xFFC97C5D); // 산호 톤 - CTA/포인트용
  static const Color terracotta = Color(0xFFD97757); // 따뜻한 테라코타 - 모임 참여
  static const Color success = Color(0xFF7BA05B); // 올리브 그린 - 진행중 상태
  static const Color alert = Color(0xFFE8A05D); // 따뜻한 오렌지 - 임박/모집중
}

class AppTheme {
  // 새로운 텍스트 테마 정의 (세리프 폰트 강조)
  static final TextTheme _appTextTheme = TextTheme(
    displayLarge: GoogleFonts.lora(fontSize: 57, fontWeight: FontWeight.bold, color: AppColors.ink),
    headlineSmall: GoogleFonts.lora(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.ink),
    titleLarge: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.2),
    titleMedium: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink, letterSpacing: -0.1),
    titleSmall: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
    bodyLarge: GoogleFonts.notoSansKr(fontSize: 15, color: AppColors.ink, height: 1.6, letterSpacing: -0.1),
    bodyMedium: GoogleFonts.notoSansKr(fontSize: 13, color: AppColors.ink, height: 1.5),
    bodySmall: GoogleFonts.notoSansKr(fontSize: 12, color: AppColors.accent, height: 1.4),
    labelLarge: GoogleFonts.notoSansKr(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.2),
    labelMedium: GoogleFonts.notoSansKr(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.paper, // 기본 배경색
    colorScheme: const ColorScheme.light(
      primary: AppColors.midnight,
      secondary: AppColors.accent,
      surface: AppColors.paper,
      onSurface: AppColors.ink, // 그라데이션 끝 색상
    ),
    textTheme: _appTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white.withOpacity(0.9),
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.ink),
      titleTextStyle: _appTextTheme.titleMedium,
    ),
    // 카드 테마
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: AppColors.midnight.withOpacity(0.08),
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 12),
    ),
    // 버튼 테마
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.midnight,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: _appTextTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: BorderSide(color: AppColors.ink.withOpacity(0.15), width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        textStyle: _appTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.grain,
      labelStyle: _appTextTheme.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.95),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.grain, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.grain, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.midnight, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: _appTextTheme.bodyMedium,
    ),
    // 하단 탭 바 테마
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white.withOpacity(0.95),
      selectedItemColor: AppColors.midnight,
      unselectedItemColor: AppColors.accent,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: _appTextTheme.labelMedium?.copyWith(fontSize: 11),
      unselectedLabelStyle: _appTextTheme.labelMedium?.copyWith(fontSize: 11),
      type: BottomNavigationBarType.fixed,
    ),
  );

  // 다크 테마는 우선 라이트 테마와 동일하게 설정 (추후 디자인 확장 가능)
  static final ThemeData darkTheme = lightTheme;
}
