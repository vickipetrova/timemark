import Foundation
import SwiftData
import SwiftUI

@Model
final class EventCategory {
    var id: UUID = UUID()
    var name: String = ""
    var sfSymbol: String = "folder.fill"
    var colorHex: String = "#3498DB"
    var sortOrder: Int = 0
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        name: String,
        sfSymbol: String,
        colorHex: String,
        sortOrder: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.sfSymbol = sfSymbol
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }

    var color: Color { Color(hex: colorHex) }
}

extension EventCategory {
    static let defaultSeed: [(name: String, symbol: String, hex: String)] = [
        ("Life", "heart.fill", "#E74C3C"),
        ("Work", "briefcase.fill", "#3498DB"),
        ("Health", "leaf.fill", "#27AE60"),
        ("Personal", "star.fill", "#F39C12")
    ]

    static let symbolOptions: [String] = [
        "heart.fill", "star.fill", "briefcase.fill", "house.fill", "leaf.fill",
        "flame.fill", "bolt.fill", "moon.fill", "sun.max.fill", "cloud.fill",
        "airplane", "car.fill", "bicycle", "figure.walk", "book.fill",
        "pencil", "graduationcap.fill", "music.note", "gamecontroller.fill",
        "trophy.fill", "gift.fill", "cart.fill", "creditcard.fill",
        "phone.fill", "envelope.fill", "camera.fill", "map.fill", "flag.fill",
        "bell.fill", "clock.fill", "calendar", "pill.fill", "cross.case.fill",
        "dumbbell.fill", "fork.knife", "cup.and.saucer.fill", "pawprint.fill",
        "person.fill", "globe"
    ]

    static let colorOptions: [String] = [
        "#E74C3C", "#E67E22", "#F1C40F", "#27AE60", "#2ECC71", "#1ABC9C",
        "#3498DB", "#2980B9", "#9B59B6", "#8E44AD", "#34495E", "#95A5A6"
    ]
}
