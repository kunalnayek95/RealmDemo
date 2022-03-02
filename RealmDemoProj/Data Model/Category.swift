//
//  Category.swift
//  RealmDemoProj
//
//  Created by Kunal's MacBook on 28/02/22.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
}
