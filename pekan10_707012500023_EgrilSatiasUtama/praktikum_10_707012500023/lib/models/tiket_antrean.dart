class TiketAntrean {
  String nomor;
  String poli;
  DateTime tanggal;
  bool isAktif;

  TiketAntrean({
    required this.nomor,
    required this.poli,
    required this.tanggal,
    this.isAktif = true,
  });
}
