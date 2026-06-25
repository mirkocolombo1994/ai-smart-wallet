/// Formatta un valore double in valuta euro italiana (es. € 1.200,50)
String formatCurrency(double val) {
  return '€ ${val.toStringAsFixed(2).replaceAll('.', ',').replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
}
