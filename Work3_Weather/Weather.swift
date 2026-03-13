import Foundation

struct Weather: Decodable {

    let name: String
    let main: Main
    let wind: Wind

}

struct Main: Decodable {
    let temp: Double
}

struct Wind: Decodable {
    let speed: Double
}
