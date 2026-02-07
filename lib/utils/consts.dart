import 'package:flutter/material.dart';

// کلاسی که شما ارائه دادید
class AppConstVariables {
  static double mainPadding = 20.0;
  static Color redColor = Color(0xffFF6464);
  static Color blackColor = Color(0xff545974); // خاکستری تیره مایل به بنفش
  static Color greenColor = Color(0xff43e97b);
}

// کلاس تم‌ها
class AppThemes {

  // --- تم روشن (Light Theme) ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // رنگ اصلی و تأکید
    primaryColor: AppConstVariables.greenColor, // استفاده از سبز به عنوان رنگ اصلی مثبت
    colorScheme: ColorScheme.light(
      primary: AppConstVariables.greenColor,
      secondary: AppConstVariables.redColor, // استفاده از قرمز برای هشدارها یا اقدامات ثانویه
      error: AppConstVariables.redColor,
      surface: Colors.white,
      onPrimary: AppConstVariables.blackColor, // متن روی رنگ اصلی
    ),
    // پس زمینه اصلی اپلیکیشن
    scaffoldBackgroundColor: Colors.white,
    // رنگ کارت‌ها و سطوح
    cardColor: const Color(0xffF7F7F7), // یک سفید بسیار روشن برای تفکیک

    // متن (Text Theme)
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 57.0,
        fontWeight: FontWeight.normal,
        color: AppConstVariables.blackColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.normal,
        color: AppConstVariables.blackColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: AppConstVariables.blackColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: AppConstVariables.blackColor,
      ),
    ),

    // آیکون‌ها
    iconTheme: IconThemeData(
      color: AppConstVariables.blackColor,
      size: 24.0,
    ),
    // نوار بالایی (AppBar)
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppConstVariables.blackColor),
      titleTextStyle: TextStyle(
        color: AppConstVariables.blackColor,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // --- تم تیره (Dark Theme) ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    // رنگ اصلی و تأکید
    primaryColor: AppConstVariables.greenColor, // سبز برای نمایش در حالت تیره
    colorScheme: ColorScheme.dark(
      primary: AppConstVariables.greenColor,
      secondary: AppConstVariables.redColor,
      error: AppConstVariables.redColor,
      // پس زمینه تیره اصلی - یک خاکستری بسیار تیره برای راحتی چشم
      surface: const Color(0xFF1C1C1E),
      background: const Color(0xFF121212), // پس زمینه عمیق‌تر
      onPrimary: Colors.white, // متن روی رنگ اصلی سبز
    ),
    // پس زمینه اصلی اپلیکیشن (از رنگی نزدیک به مشکی اما نه کاملاً مشکی استفاده می‌کنیم)
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    // رنگ کارت‌ها و سطوح (کمی روشن‌تر از پس زمینه)
    cardColor: const Color(0xFF2C2C2E),

    // متن (Text Theme)
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 57.0,
        fontWeight: FontWeight.normal,
        color: Colors.white, // متن روشن در پس زمینه تیره
      ),
      headlineMedium: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: Colors.white.withOpacity(0.9), // کمی شفافیت برای زیبایی
      ),
    ),

    // آیکون‌ها
    iconTheme: IconThemeData(
      color: Colors.white70,
      size: 24.0,
    ),
    // نوار بالایی (AppBar)
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
