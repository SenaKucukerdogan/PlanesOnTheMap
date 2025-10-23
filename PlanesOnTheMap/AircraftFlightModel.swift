//
//  AircraftFlightModel.swift
//  PlanesOnTheMap
//
//  Created by Sena Küçükerdoğan on 16.12.2024.
//

import Foundation

// Main Response Model
struct FlightModel: Codable {
    let time: Int
    let states: [[AnyCodable]]
}

// Wrapper for any type, "states" 
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Float.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else {
            value = try container.decodeNil()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let stringValue = value as? String {
            try container.encode(stringValue)
        } else if let intValue = value as? Int {
            try container.encode(intValue)
        } else if let doubleValue = value as? Float {
            try container.encode(doubleValue)
        } else if let boolValue = value as? Bool {
            try container.encode(boolValue)
        } else {
            try container.encodeNil()
        }
    }
}


struct FlightData: Codable {
    let icao24: String?
    let callsign: String?
    let originCountry: String?
    let timePosition: Int?
    let lastContact: Int?
    let longitude: Float?
    let latitude: Float?
    let baroAltitude: Float?
    let onGround: Bool?
    let velocity: Float?
    let heading: Float?
    let verticalRate: Float?
    let geoAltitude: Float?
    let squawk: String?
    let spi: Bool?
    let positionSource: Int?

    init(from state: [AnyCodable]) {
        self.icao24 = state[safe: 0]?.value as? String
        self.callsign = state[safe: 1]?.value as? String
        self.originCountry = state[safe: 2]?.value as? String
        self.timePosition = state[safe: 3]?.value as? Int
        self.lastContact = state[safe: 4]?.value as? Int
        self.longitude = state[safe: 5]?.value as? Float
        self.latitude = state[safe: 6]?.value as? Float
        self.baroAltitude = state[safe: 7]?.value as? Float
        self.onGround = state[safe: 8]?.value as? Bool
        self.velocity = state[safe: 9]?.value as? Float
        self.heading = state[safe: 10]?.value as? Float
        self.verticalRate = state[safe: 11]?.value as? Float
        self.geoAltitude = state[safe: 13]?.value as? Float
        self.squawk = state[safe: 14]?.value as? String
        self.spi = state[safe: 15]?.value as? Bool
        self.positionSource = state[safe: 16]?.value as? Int
    }
}


extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
