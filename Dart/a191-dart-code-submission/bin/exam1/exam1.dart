dynamic studentInfo() {
  // TODO 1

  String name = "Anggi Maulana";
  int favNumber = 7;
  bool isDicodingStudent = true;

  // End of TODO 1
  return [name, favNumber, isDicodingStudent];
}

dynamic circleArea(num r) {
  if (r < 0) {
    return 0.0;
  } else {
    const double pi = 3.1415926535897932; //π sama dengan library dart.math;

    // TODO 2

    return pi * r * r;

    // End of TODO 2
  }
}

int? parseAndAddOne(String? input) {
  // TODO 3
  if (input == null) return null;

  try {
    int number = int.parse(input);
    return number + 1;
  } catch (e) {
    throw Exception('Input harus berupa angka');
  }

  // return 0;
  // End of TODO 3
}
