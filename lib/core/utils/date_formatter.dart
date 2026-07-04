String formatDateTime(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  String twoDigits(int number) => number.toString().padLeft(2, '0');

  return '${value.day} ${months[value.month - 1]} ${value.year}, '
      '${twoDigits(value.hour)}:${twoDigits(value.minute)}';
}
