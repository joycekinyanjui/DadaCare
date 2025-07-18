import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'inventory_db.dart';

class InventoryLoader {
  static Future<void> loadExcelIfNeeded() async {
    final existing = await InventoryDatabase.instance.readAll();
    if (existing.isNotEmpty) {
      return; // already loaded before
    }

    // load the Excel from assets
    final data = await rootBundle.load(
      'assets/Resources Inventory Cost Sheet.xlsx',
    );
    final bytes = data.buffer.asUint8List();
    final excel = Excel.decodeBytes(bytes);

    // assuming the first sheet contains: name | quantity | unitCost
    final sheet = excel.tables.keys.first;
    final rows = excel.tables[sheet]!.rows;

    for (var row in rows.skip(1)) {
      // skip header
      final name = row[0]?.value?.toString() ?? 'Unknown';
      final qty = int.tryParse(row[1]?.value.toString() ?? '0') ?? 0;
      final cost = int.tryParse(row[2]?.value.toString() ?? '0') ?? 0;

      final item = InventoryItem(name: name, quantity: qty, unitCost: cost);
      await InventoryDatabase.instance.create(item);
    }
  }
}
