import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class InventoryItem {
  final int? id;
  final String name;
  final int quantity;
  final int unitCost;

  InventoryItem({
    this.id,
    required this.name,
    required this.quantity,
    required this.unitCost,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'unitCost': unitCost,
  };

  factory InventoryItem.fromMap(Map<String, dynamic> map) => InventoryItem(
    id: map['id'],
    name: map['name'],
    quantity: map['quantity'],
    unitCost: map['unitCost'],
  );
}

class InventoryDatabase {
  static final InventoryDatabase instance = InventoryDatabase._init();

  static Database? _database;

  InventoryDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('inventory.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unitCost INTEGER NOT NULL
      )
    ''');
  }

  Future<InventoryItem> create(InventoryItem item) async {
    final db = await instance.database;
    final id = await db.insert('inventory', item.toMap());
    return item.copyWith(id: id);
  }

  Future<List<InventoryItem>> readAll() async {
    final db = await instance.database;
    final result = await db.query('inventory');
    return result.map((e) => InventoryItem.fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete('inventory', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

extension on InventoryItem {
  InventoryItem copyWith({
    int? id,
    String? name,
    int? quantity,
    int? unitCost,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
    );
  }
}
