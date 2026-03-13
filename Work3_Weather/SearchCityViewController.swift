import UIKit
import MapKit

class SearchCityViewController: UIViewController {

    var onCitySelected: ((City) -> Void)?

    private let textField: UITextField = {
        let textField1 = UITextField()
        textField1.placeholder = "Enter city"
        textField1.borderStyle = .roundedRect
        textField1.translatesAutoresizingMaskIntoConstraints = false
        return textField1
    }()

    private let button: UIButton = {
        let button1 = UIButton(type: .system)
        button1.setTitle("Add City", for: .normal)
        button1.translatesAutoresizingMaskIntoConstraints = false
        return button1
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Add City"

        view.addSubview(textField)
        view.addSubview(button)

        button.addTarget(self, action: #selector(searchCity), for: .touchUpInside)

        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textField.widthAnchor.constraint(equalToConstant: 200),

            button.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func searchCity() {
        guard let cityName = textField.text, !cityName.isEmpty else { return }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(cityName) { [weak self] placemarks, error in
            guard let location = placemarks?.first?.location else { return }

            let city = City(name: cityName, coordinate: location.coordinate)
            CitiesStorage.shared.saveCity(name: city.name, coordinate: city.coordinate)
            self?.onCitySelected?(city)
            self?.navigationController?.popViewController(animated: true)
        }
    }
}
