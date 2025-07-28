//
//  AttributeTemplate.swift
//  Ordernise
//
//  Created by Aaron Strickland on 28/07/2025.
//

import Foundation
import SwiftData

@Model
class AttributeTemplate {
    var id: UUID
    var name: String
    var attributes: [String: String]
    var templateType: TemplateType
    var dateCreated: Date
    var isDefault: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        attributes: [String: String] = [:],
        templateType: TemplateType,
        dateCreated: Date = Date(),
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.attributes = attributes
        self.templateType = templateType
        self.dateCreated = dateCreated
        self.isDefault = isDefault
    }
}

enum TemplateType: String, Codable, CaseIterable {
    case stockItem = "Stock Item"
    case order = "Order"
}
