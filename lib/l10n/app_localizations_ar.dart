// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مُبلّغ مشاكل البلدية';

  @override
  String get homeTitleMunicipality => 'بلدية فيل أون مونتاني';

  @override
  String get homeSubtitle => 'أبلغ عن مشكلة في حيّك';

  @override
  String get actionReportProblem => 'الإبلاغ عن مشكلة';

  @override
  String get actionAdminLogin => 'دخول الإدارة';

  @override
  String get hintPhotoDescriptionLocation => 'صورة، وصف، موقع';

  @override
  String get hintAdminDashboardAccess => 'الوصول إلى لوحة التحكم';

  @override
  String get tipTitle => 'نصيحة:';

  @override
  String get tipText => 'أضف صورة لتسريع معالجة طلبك.';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get serviceFooter => 'الخدمة البلدية • الإصدار 2.4.0';

  @override
  String get loginTitle => 'تسجيل دخول الإدارة';

  @override
  String get usernameLabel => 'اسم المستخدم';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get logoutButton => 'تسجيل الخروج';

  @override
  String get reportsTitle => 'لوحة الإدارة';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterNew => 'جديد';

  @override
  String get filterInProgress => 'قيد المعالجة';

  @override
  String get filterResolved => 'تم الحل';

  @override
  String get statusNew => 'جديد';

  @override
  String get statusInProgress => 'قيد المعالجة';

  @override
  String get statusResolved => 'تم الحل';

  @override
  String get delete => 'حذف';

  @override
  String get confirmDeleteTitle => 'تأكيد الحذف';

  @override
  String get confirmDeleteBody => 'هل أنت متأكد أنك تريد حذف هذا العنصر؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get ok => 'موافق';

  @override
  String get createReportTitle => 'إنشاء بلاغ';

  @override
  String get reportTitleLabel => 'العنوان';

  @override
  String get reportDescriptionLabel => 'الوصف';

  @override
  String get submit => 'إرسال';

  @override
  String get uploading => 'جارٍ الرفع...';

  @override
  String get savedSuccess => 'تم الحفظ بنجاح';

  @override
  String get errorGeneric => 'حدث خطأ ما.';

  @override
  String get pickFromGallery => 'اختيار من المعرض';

  @override
  String get openCamera => 'فتح الكاميرا';

  @override
  String get removeImage => 'إزالة الصورة';

  @override
  String get getLocation => 'الحصول على موقعي';

  @override
  String get confirmSubmit => 'تأكيد الإرسال';

  @override
  String get confirmSubmitMessage => 'هل تريد إرسال هذا البلاغ؟';

  @override
  String get noReports => 'لا توجد بلاغات بعد';

  @override
  String get noReportsHint => 'أنشئ بلاغًا للبدء.';

  @override
  String get saveFailed => 'تعذر حفظ البلاغ.';

  @override
  String get permissionDenied => 'تم رفض الإذن. يرجى تفعيله من الإعدادات.';

  @override
  String get locationServicesDisabled => 'خدمات الموقع غير مفعلة.';

  @override
  String get reportDetailsTitle => 'تفاصيل البلاغ';

  @override
  String get createdAt => 'تاريخ الإنشاء';

  @override
  String get photoLabel => 'الصورة';

  @override
  String get photoMissing => 'لا توجد صورة متاحة';

  @override
  String get locationLabel => 'الموقع';

  @override
  String get noLocation => 'لم يتم التقاط الموقع.';

  @override
  String get photoStatusPresent => 'الصورة متوفرة';

  @override
  String get photoStatusMissing => 'لا توجد صورة';

  @override
  String get locationStatusPresent => 'الموقع متوفر';

  @override
  String get locationStatusMissing => 'لا يوجد موقع';

  @override
  String locationCaptured(String lat, String lng) {
    return 'خط العرض: $lat، خط الطول: $lng';
  }

  @override
  String get adminLoginRequired => 'يتطلب تسجيل دخول الإدارة';

  @override
  String get searchReports => 'بحث في البلاغات';

  @override
  String get unableToLoadReports => 'تعذر تحميل البلاغات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get markAsNew => 'تعيين كجديد';

  @override
  String get markAsInProgress => 'تعيين كقيد المعالجة';

  @override
  String get markAsResolved => 'تعيين كمحلول';

  @override
  String get changeStatus => 'تغيير الحالة';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String statusUpdatedTo(String status) {
    return 'تم تحديث الحالة إلى $status';
  }

  @override
  String get reportDeleted => 'تم حذف البلاغ';

  @override
  String get deleteReport => 'حذف البلاغ';

  @override
  String get deleteReportButton => 'حذف البلاغ';

  @override
  String get deleteReportConfirmTitle => 'حذف البلاغ';

  @override
  String deleteReportConfirmBody(String title) {
    return 'هل أنت متأكد أنك تريد حذف \"$title\"؟';
  }

  @override
  String get deleteImageTitle => 'حذف الصورة';

  @override
  String get deleteImageBody => 'هل تريد إزالة هذه الصورة من البلاغ؟';

  @override
  String get imageUploaded => 'تم رفع الصورة';

  @override
  String get imageDeleted => 'تم حذف الصورة';

  @override
  String get addImage => 'إضافة صورة';

  @override
  String get deleteImage => 'حذف الصورة';

  @override
  String get onlyUploadedImagesCanBeDeleted => 'يمكن حذف الصور المرفوعة فقط.';

  @override
  String get noImages => 'لا توجد صور';

  @override
  String get noImagesMessage => 'أضف صورة لتوضيح البلاغ بشكل أفضل.';

  @override
  String get mapPreview => 'معاينة الخريطة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get signInAsAdmin => 'تسجيل الدخول كمسؤول';

  @override
  String get usernameRequired => 'اسم المستخدم مطلوب';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String uploadingProgress(String progress) {
    return 'جارٍ الرفع $progress٪';
  }

  @override
  String get statusLabel => 'الحالة';
}
