class ResponsiveBreakpoints {
  // Breakpoints in pixels
  static const double mobile = 600;
  static const double tablet = 1200;
  static const double desktop = 1440;

  // Layout dimensions
  static const double sidebarWidthDesktop = 280;
  static const double sidebarWidthTablet = 240;
  static const double sidebarCollapsedWidth = 80;

  // Content padding
  static const double contentPaddingDesktop = 24;
  static const double contentPaddingTablet = 20;
  static const double contentPaddingMobile = 16;

  // Constraints
  static const double minContentWidth = 320;
  static const double maxContentWidth = 1600;

  // Helper methods
  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < tablet;
  static bool isDesktop(double width) => width >= tablet;

  static double getSidebarWidth(double screenWidth) {
    if (isMobile(screenWidth)) return 0;
    if (isTablet(screenWidth)) return sidebarWidthTablet;
    return sidebarWidthDesktop;
  }

  static double getContentPadding(double screenWidth) {
    if (isMobile(screenWidth)) return contentPaddingMobile;
    if (isTablet(screenWidth)) return contentPaddingTablet;
    return contentPaddingDesktop;
  }

  static int getGridColumns(double screenWidth) {
    if (isMobile(screenWidth)) return 1;
    if (isTablet(screenWidth)) return 2;
    return 3;
  }
}
