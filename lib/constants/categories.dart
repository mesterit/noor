enum AlmuslimCategory { athkar, quraan, sunnah, ruqiya, myad3yah, allahname }

const Map<AlmuslimCategory, String> categoryTitle = <AlmuslimCategory, String>{
  AlmuslimCategory.athkar: 'الأذكار',
  AlmuslimCategory.quraan: 'أدعية من القرآن الكريم',
  AlmuslimCategory.sunnah: 'أدعية من السنة النبوية',
  AlmuslimCategory.ruqiya: 'الرقية الشرعية',
  AlmuslimCategory.myad3yah: 'أدعيتي',
  AlmuslimCategory.allahname: 'أسماء الله الحسنى',
};
