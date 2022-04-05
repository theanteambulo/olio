//
//  ChatMessage.swift
//  Olio
//
//  Created by Jake King on 04/04/2022.
//

import CloudKit
import Foundation

struct ChatMessage: Identifiable {
    let id: String
    let from: String
    let text: String
    let date: Date
}

// Custom initializer in extension so don't lose member-wise initializer provided automatically by Swift
extension ChatMessage {
    init(from record: CKRecord) {
        id = record.recordID.recordName
        from = record["from"] as? String ?? "No author"
        text =  record["text"] as? String ?? "Empty message"
        date = record.creationDate ?? Date()
    }
}
