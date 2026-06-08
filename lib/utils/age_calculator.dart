String calcAge(DateTime birthday, DateTime asOf) {
  int years = asOf.year - birthday.year;
  int months = asOf.month - birthday.month;
  if (asOf.day < birthday.day) months--;
  if (months < 0) {
    years--;
    months += 12;
  }
  if (years < 0) return '尚未出生';
  if (years == 0 && months == 0) {
    final days = asOf.difference(birthday).inDays;
    if (days < 0) return '尚未出生';
    if (days < 30) return '$days天';
    return '不到1个月';
  }
  if (years == 0) return '$months个月';
  if (months == 0) return '$years岁';
  return '$years岁$months个月';
}
