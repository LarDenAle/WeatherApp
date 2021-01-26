//
//  ViewController.swift
//  WeatherApp
//
//  Created by Denis Larin on 24.01.2021.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var weatherIconImageView: UIImageView!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var temperatureLabel: UILabel!
    @IBOutlet var feelsLikeTemperatureLabel: UILabel!
    
    var networkWeatherManager = NetworkWeatherManager()
    lazy var locationManager: CLLocationManager = { // lazy тк пользователь может не разрешить смотреть геопозицию
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        lm.requestWhenInUseAuthorization() // в info.plist добавили запрос на гео позицию.
        
        return lm
    } ()
    
    @IBAction func searchPressed(_ sender: UIButton) {
        // можно разгрузить VC и сделать вызов метода через extension - расширение VC
        self.presentSearchAlertController(withTitle: "Введите название города", message: nil, style: .alert) { [unowned self] city in // [weak self] или [unowned self]добавили чтобы показать что точно нету цикла сильных ссылок а лист захвата если вдруг приложение разрастется и будет несколько экранов
            
//            self.networkWeatherManager.fetchCurrentWeather(forCity: city) { currentWeather in // через клоужер - 1 вариант
//                print(currentWeather.cityName)
            self.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityName(city: city)) // второй вариант
            
        }
    }
    
    // сетевой код не должен быть во VC - так как никак не относиться к управлению 
    override func viewDidLoad() { // используем метод viewDidLoad чтобы получить информация с сервиса
        super.viewDidLoad()
//        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=London&appid=585c9164bd1d8176e9f6e179d07c0e89" // просто адрес строки url
//        let url = URL(string: urlString) // создаем url
//        let session = URLSession(configuration: .default) // создаем сессию - вся работа с сетевыми запросами идет через сессию
//        let task = session.dataTask(with: url!) { data, response, error in
//            if let data = data {
//                let dataString = String(data: data, encoding: .utf8)
//                print(dataString)
//            }
//        }
//        task.resume()
//    }
//        networkWeatherManager.fetchCurrentWeather(forCity: "Moscow") { currentWeather in // через клоужер - 1 вариант
//            print(currentWeather.cityName)
        // второй вариант
        networkWeatherManager.onCompletion = { [weak self] currentWeather in
//            print(currentWeather.cityName)
            guard let self = self else {
                return
            }
            self.updateInterfaceWith(weather: currentWeather)
        }
//        networkWeatherManager.fetchCurrentWeather(forCity: "Moscow") // убираем первую погоду
        if CLLocationManager.locationServicesEnabled() { // если настройка гео выкл то можем вкл погоду и обновить или будет ошибка
            locationManager.requestLocation()
        }
    }
    func updateInterfaceWith(weather: CurrentWeather) {
        // добавляем DispatchQueue.main.async чтобы вызов был в главном потоке
        DispatchQueue.main.async {
            self.cityLabel.text = weather.cityName
            self.temperatureLabel.text = weather.temperatureString
            self.feelsLikeTemperatureLabel.text = weather.feelsLikeTemperatureString
            self.weatherIconImageView.image = UIImage(systemName: weather.systemIconNameString)
        }
       
    }
}
// подписываем VC под протокл CL
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude // получаем гео координаты пользователя
        let longitude = location.coordinate.longitude
        
        networkWeatherManager.fetchCurrentWeather(forRequestType: .coordinate(latitude: latitude, longitude: longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
