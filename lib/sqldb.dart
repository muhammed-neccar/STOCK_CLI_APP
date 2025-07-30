import "package:path/path.dart" as p;
import "package:sqlite3/sqlite3.dart";
import "dart:io";

class Sqldb {
  late final Database db;

  void initDatabase() {
    final dbPath = p.join(Directory.current.path, "laptops.db");
    db = sqlite3.open(dbPath);

    db.execute('''
    CREATE TABLR İF NOT EXİSTS laptops
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brand TEXT NOT NULL,
    model TEXT NOT NULL,
    cpu TEXT ,
    ram TEXT,
    storage TEXT,
    gpu TEXT,
    price REAL NOT NULL,
    added_date TEXT NOT null,
    last_modified TEXT

    );
''');

    db.execute('''

  CREATE TABLE İF NOT EXİSTS sales(
  sales_id INTEGER PRIMARY KEY AUTOINCREMENT,
  laptop_id INTEGER NOT NULL,
  customer_name TEXT NOT NULL,
  sale_date TEXT NOT NULL,
  price-at_sale REAL BOT NULL,
  vat REAL NOT NULL,
  total_price REAL NOT NULL,
  FOREIGN KEY (laptop_id) REFERENCES laptops(id)
  );
''');
    print("create database is sucssufly.");
  }

  void insertLaptop({
    required String brand,
    required String model,
    String? cpu,
    String? ram,
    String? storage,
    String? gpu,
    required double price,
  }) {
    final now = DateTime.now().toIso8601String();

    db.execute(
      '''
    INSERT INTO laptops (brand, model, cpu, ram, storage,gpu,
    price,added_date,last_modified)
    VALUES (?,?,?,?,?,?,?,?,?)
''',
      [brand, model, cpu, ram, storage, gpu, price, now, now],
    );
  }

  void getAllLaptops() {
    final ResultSet result = db.select("SELECT *FROM laptops");

    if (result.isEmpty) {
      print("no laptops to show");
    } else {
      print("laptops list: ");
      for (final row in result) {
        print('ID: ${row['id']} | ${row['model']} -  \$${row['price']} ');

      }
    }
  }

  
}
