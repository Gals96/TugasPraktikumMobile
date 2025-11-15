class Hewan {
  String nama;
  double berat;

  Hewan(this.nama, this.berat);

  String makan(Hewan hewan, double porsi) {
    hewan.berat += porsi / 1000;
    return 'Hewan ${hewan.nama} telah makan sebanyak $porsi gram.';
  }
}
