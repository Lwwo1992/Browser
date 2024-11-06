

import Foundation
import WCDBSwift

struct DataBasePath {
    let dbPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last! + "/Browser/Browser.db"
}

class DBaseManager: NSObject {
    static let share = DBaseManager()

    let dataBasePath = URL(fileURLWithPath: DataBasePath().dbPath)
    var db: Database?
    override private init() {
        super.init()
        db = createDb()
    }

    /// 创建db
    private func createDb() -> Database {
        return Database(at: dataBasePath)
    }

    /// 创建表
    func createTable<T: TableDecodable>(table: String, of ttype: T.Type) -> Void {
        do {
            try db?.create(table: table, of: ttype)
        } catch let error {
            debugPrint("create table error \(error.localizedDescription)")
        }
    }

    /// 插入
    func insertToDb<T: TableEncodable>(objects: [T], intoTable table: String) -> Void {
        do {
            try db?.insert(objects, intoTable: table)
        } catch let error {
            debugPrint(" insert obj error \(error.localizedDescription)")
        }
    }

    /// 修改
    func updateToDb<T: TableEncodable>(table: String, on propertys: [PropertyConvertible], with object: T, where condition: Condition? = nil) -> Void {
        do {
            try db?.update(table: table, on: propertys, with: object, where: condition)
        } catch let error {
            debugPrint(" update obj error \(error.localizedDescription)")
        }
    }

    /// 删除
    func deleteFromDb(fromTable: String, where condition: Condition? = nil) {
        do {
            try db?.delete(fromTable: fromTable, where: condition)
        } catch let error {
            debugPrint("delete error \(error.localizedDescription)")
        }
    }

    /// 查询
    func qureyFromDb<T: TableDecodable>(fromTable: String,
                                        cls cName: T.Type,
                                        where condition: Condition? = nil,
                                        orderBy orderList: [OrderBy]? = nil,
                                        limit: Limit? = nil) -> [T]? {
        do {
            let allObjects: [T] = try (db?.getObjects(fromTable: fromTable, where: condition, orderBy: orderList, limit: limit))!
            debugPrint("\(allObjects)")
            return allObjects
        } catch let error {
            debugPrint("no data find \(error.localizedDescription)")
        }
        return nil
    }

    /// 删除数据表
    func dropTable(table: String) {
        do {
            try db?.drop(table: table)
        } catch let error {
            debugPrint("drop table error \(error)")
        }
    }

    /// 删除所有与该数据库相关的文件
    func removeDbFile() {
        do {
            try db?.close(onClosed: {
                try self.db?.removeFiles()
            })
        } catch let error {
            debugPrint("not close db \(error)")
        }
    }
}
