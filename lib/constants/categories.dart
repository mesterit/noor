enum JanatyCategory { athkar, quraan, sunnah, ruqiya, myad3yah, allahname }

const Map<JanatyCategory, String> categoryTitle = <JanatyCategory, String>{
  JanatyCategory.athkar: 'الأذكار',
  JanatyCategory.quraan: 'أدعية من القرآن الكريم',
  JanatyCategory.sunnah: 'أدعية من السنة النبوية',
  JanatyCategory.ruqiya: 'الرقية الشرعية',
  JanatyCategory.myad3yah: 'أدعيتي',
  JanatyCategory.allahname: 'أسماء الله الحسنى',
};
