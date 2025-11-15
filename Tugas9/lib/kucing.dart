import 'hewan.dart';

class Kucing extends Hewan {
  String warnaBulu;

  Kucing(String nama, double berat, this.warnaBulu) : super(nama, berat);

  @override
  String makan(Hewan hewan, double porsi) {
    super.makan(hewan, porsi);

    return 'kucing $nama sedang makan sebanyak $porsi gram.';
  }
}
