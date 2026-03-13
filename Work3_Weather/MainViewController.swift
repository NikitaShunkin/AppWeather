import UIKit
import CoreLocation

class MainViewController: UIViewController {

    private let cityLabel: UILabel = {
        let label1 = UILabel()
        label1.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label1.textAlignment = .center
        label1.translatesAutoresizingMaskIntoConstraints = false
        return label1
    }()

    private let tempLabel: UILabel = {
        let label2 = UILabel()
        label2.font = UIFont.systemFont(ofSize: 48)
        label2.textAlignment = .center
        label2.translatesAutoresizingMaskIntoConstraints = false
        return label2
    }()

    private let windLabel: UILabel = {
        let label3 = UILabel()
        label3.font = UIFont.systemFont(ofSize: 20)
        label3.textAlignment = .center
        label3.translatesAutoresizingMaskIntoConstraints = false
        return label3
    }()

    private let weatherService = WeatherService()
    private let locationManager = LocationManager()
    private let sideMenu = SideMenuView()
    private var isMenuVisible = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Weather"

        setupUI()
        setupSideMenu()
        setupLocation()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal"),
            style: .plain,
            target: self,
            action: #selector(toggleSideMenu)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(openSearch)
        )
    }

    private func setupUI() {
        view.addSubview(cityLabel)
        view.addSubview(tempLabel)
        view.addSubview(windLabel)

        NSLayoutConstraint.activate([
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cityLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),

            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 20),

            windLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            windLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 20)
        ])
    }

    private func setupSideMenu() {
        sideMenu.frame = CGRect(x: -250, y: 0, width: 250, height: view.frame.height)
        view.addSubview(sideMenu)

        sideMenu.onCitySelected = { [weak self] city in
            self?.loadWeather(lat: city.coordinate.latitude, lon: city.coordinate.longitude)
            self?.toggleSideMenu()
        }

        sideMenu.reloadCities()
    }

    private func setupLocation() {
        locationManager.onLocationUpdate = { [weak self] coordinate in
            self?.loadWeather(lat: coordinate.latitude, lon: coordinate.longitude)
        }
        locationManager.requestLocation()
    }

    private func loadWeather(lat: Double, lon: Double) {
        weatherService.fetchWeather(latitude: lat, longitude: lon) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self?.cityLabel.text = weather.name
                    self?.tempLabel.text = "\(weather.main.temp)°C"
                    self?.windLabel.text = "Wind \(weather.wind.speed) m/s"
                    self?.sideMenu.reloadCities()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    @objc private func toggleSideMenu() {
        let targetX: CGFloat = isMenuVisible ? -250 : 0
        UIView.animate(withDuration: 0.3) {
            self.sideMenu.frame.origin.x = targetX
        }
        isMenuVisible.toggle()
    }

    @objc private func openSearch() {
        let searchViewController = SearchCityViewController()
        searchViewController.onCitySelected = { [weak self] city in
            self?.loadWeather(lat: city.coordinate.latitude, lon: city.coordinate.longitude)
        }
        navigationController?.pushViewController(searchViewController, animated: true)
    }
}
