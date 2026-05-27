// Static, realistic-ish reference data for the visa/residence scoring prototype.
// Numbers are monthly EUR unless noted. Approval values are baseline acceptance
// rates for a typical applicant on the most common long-stay route.

window.PASSPORT_POWER = {
  // 3-letter code -> mobility/strength score 0..1 (higher = stronger passport)
  UKR: 0.52, RUS: 0.40, BLR: 0.38, KAZ: 0.45, GEO: 0.55, ARM: 0.48,
  TUR: 0.50, IND: 0.42, CHN: 0.46, BRA: 0.70, USA: 0.92, GBR: 0.93,
  CAN: 0.91, AUS: 0.90, NGA: 0.30, EGY: 0.38, IRN: 0.28, PAK: 0.27,
  MEX: 0.66, PHL: 0.44, IDN: 0.48, ZAF: 0.58, SRB: 0.62, MDA: 0.60,
};

window.COUNTRY_NAMES = {
  UKR: "Украина", RUS: "Россия", BLR: "Беларусь", KAZ: "Казахстан",
  GEO: "Грузия", ARM: "Армения", TUR: "Турция", IND: "Индия",
  CHN: "Китай", BRA: "Бразилия", USA: "США", GBR: "Великобритания",
  CAN: "Канада", AUS: "Австралия", NGA: "Нигерия", EGY: "Египет",
  IRN: "Иран", PAK: "Пакистан", MEX: "Мексика", PHL: "Филиппины",
  IDN: "Индонезия", ZAF: "ЮАР", SRB: "Сербия", MDA: "Молдова",
};

// Shared document catalog
const DOC = {
  passport: { id: "passport", title: "Скан паспорта", hint: "Цветной разворот с фото" },
  photo: { id: "photo", title: "Биометрическое фото", hint: "35×45 мм, белый фон" },
  insurance: { id: "insurance", title: "Медицинская страховка", hint: "Покрытие ≥ 30 000 €" },
  funds: { id: "funds", title: "Подтверждение средств", hint: "Выписка за 3–6 мес." },
  accommodation: { id: "accommodation", title: "Подтверждение жилья", hint: "Договор аренды / бронь" },
  employment: { id: "employment", title: "Трудовой договор / оффер", hint: "Для рабочих виз" },
  diploma: { id: "diploma", title: "Диплом об образовании", hint: "С апостилем/переводом" },
  criminal: { id: "criminal", title: "Справка о несудимости", hint: "Не старше 6 мес." },
  motivation: { id: "motivation", title: "Мотивационное письмо", hint: "Цель пребывания" },
  business: { id: "business", title: "Бизнес-план", hint: "Для стартап/ИП виз" },
};

window.DESTINATIONS = [
  {
    code: "DE", flag: "🇩🇪", name: "Германия",
    route: "Job Seeker / Blue Card",
    avgSalary: 3200, costOfLiving: 1500, baseApproval: 0.74,
    processingWeeks: "6–12 нед.",
    fees: { gov: 75, service: 220, legal: 350, insurance: 110 },
    docs: [DOC.passport, DOC.photo, DOC.insurance, DOC.funds, DOC.diploma, DOC.employment, DOC.criminal, DOC.motivation],
  },
  {
    code: "NL", flag: "🇳🇱", name: "Нидерланды",
    route: "Highly Skilled Migrant",
    avgSalary: 3100, costOfLiving: 1700, baseApproval: 0.71,
    processingWeeks: "4–8 нед.",
    fees: { gov: 380, service: 250, legal: 300, insurance: 130 },
    docs: [DOC.passport, DOC.photo, DOC.insurance, DOC.funds, DOC.employment, DOC.diploma, DOC.criminal],
  },
  {
    code: "PT", flag: "🇵🇹", name: "Португалия",
    route: "D7 / Digital Nomad",
    avgSalary: 1400, costOfLiving: 1100, baseApproval: 0.80,
    processingWeeks: "8–16 нед.",
    fees: { gov: 90, service: 300, legal: 500, insurance: 90 },
    docs: [DOC.passport, DOC.photo, DOC.insurance, DOC.funds, DOC.accommodation, DOC.criminal, DOC.motivation],
  },
  {
    code: "ES", flag: "🇪🇸", name: "Испания",
    route: "Non-Lucrative / Nomad",
    avgSalary: 1700, costOfLiving: 1200, baseApproval: 0.77,
    processingWeeks: "8–12 нед.",
    fees: { gov: 80, service: 280, legal: 450, insurance: 95 },
    docs: [DOC.passport, DOC.photo, DOC.insurance, DOC.funds, DOC.accommodation, DOC.criminal],
  },
  {
    code: "PL", flag: "🇵🇱", name: "Польша",
    route: "Work / Temporary Residence",
    avgSalary: 1500, costOfLiving: 950, baseApproval: 0.82,
    processingWeeks: "4–10 нед.",
    fees: { gov: 100, service: 180, legal: 250, insurance: 70 },
    docs: [DOC.passport, DOC.photo, DOC.insurance, DOC.employment, DOC.accommodation, DOC.criminal],
  },
  {
    code: "IE", flag: "🇮🇪", name: "Ирландия",
    route: "Critical Skills Permit",
    avgSalary: 3500, costOfLiving: 2100, baseApproval: 0.66,
    processingWeeks: "6–10 нед.",
    fees: { gov: 1000, service: 300, legal: 400, insurance: 140 },
    docs: [DOC.passport, DOC.photo, DOC.insurance, DOC.employment, DOC.diploma, DOC.criminal],
  },
  {
    code: "EE", flag: "🇪🇪", name: "Эстония",
    route: "Startup / Digital Nomad",
    avgSalary: 1800, costOfLiving: 1100, baseApproval: 0.79,
    processingWeeks: "2–6 нед.",
    fees: { gov: 100, service: 160, legal: 280, insurance: 75 },
    docs: [DOC.passport, DOC.photo, DOC.insurance, DOC.funds, DOC.business, DOC.criminal, DOC.motivation],
  },
  {
    code: "FR", flag: "🇫🇷", name: "Франция",
    route: "Talent Passport",
    avgSalary: 2600, costOfLiving: 1600, baseApproval: 0.69,
    processingWeeks: "6–12 нед.",
    fees: { gov: 225, service: 260, legal: 420, insurance: 100 },
    docs: [DOC.passport, DOC.photo, DOC.insurance, DOC.funds, DOC.employment, DOC.diploma, DOC.criminal, DOC.motivation],
  },
];

// A sample MRZ-extracted profile used by the demo "scan" step.
window.DEMO_PROFILES = [
  { surname: "PETROV", given: "IVAN", nationality: "UKR", sex: "M", dob: "1992-04-18", passportNo: "FX1234567", expiry: "2031-09-30" },
  { surname: "KOVALENKO", given: "OLENA", nationality: "UKR", sex: "F", dob: "1995-11-02", passportNo: "EX7654321", expiry: "2030-05-14" },
  { surname: "NURLANOV", given: "ASKAR", nationality: "KAZ", sex: "M", dob: "1989-07-23", passportNo: "N09887766", expiry: "2029-12-01" },
];
