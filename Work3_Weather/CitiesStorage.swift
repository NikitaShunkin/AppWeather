import Foundation
import CoreLocation

struct City: Codable {
    let name: String
    let coordinate: CLLocationCoordinate2D
}

// CLLocationCoordinate2D Codable
extension CLLocationCoordinate2D: Codable {
    enum CodingKeys: String, CodingKey { case latitude, longitude }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lat = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let lon = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.init(latitude: lat, longitude: lon)
    }
}

class CitiesStorage {

    private let key = "savedCities"
    static let shared = CitiesStorage()
    private init() {}

    func saveCity(name: String, coordinate: CLLocationCoordinate2D) {
        var cities = loadCities()
        let city = City(name: name, coordinate: coordinate)
        if !cities.contains(where: { $0.name == name }) {
            cities.append(city)
        }
        if let data = try? JSONEncoder().encode(cities) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadCities() -> [City] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let cities = try? JSONDecoder().decode([City].self, from: data) else {
            return []
        }
        return cities
    }
}
