//
//  NetworkWeatherManager.swift
//  WeatherApp
//
//  Created by Denis Larin on 25.01.2021.
//

import Foundation
import CoreLocation
// сетевой код не должен быть во VC
//
//struct NetworkWeatherManager {
    // меняем struct на класс что бы в будущем можно было написать родительский класс который будет заниматься сетевыми запросами а NetworkWeatherManager будет подкласс для работы с API
class NetworkWeatherManager {
    enum RequestType {
        case cityName(city: String)
        case coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    }
    
    var onCompletion: ((CurrentWeather) -> Void)? // для второго варианта клоужер

    func fetchCurrentWeather(forRequestType requestType: RequestType) {
        var urlString = ""
        switch requestType {
        case .cityName(let city):
            urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(appId)&units=metric"
            
        case .coordinate(let latitude, let longitude):
            urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(appId)&units=metric"
        }
        performRequest(withURLString: urlString)
    }
    
    
    //    func fetchCurrentWeather(forCity city: String, completionHandler: @ escaping (CurrentWeather) -> Void) { // через клоужер
             
    
    // метод получения инфы о погоде по информации о названии города
//      func fetchCurrentWeather(forCity city: String) { // второй вариант реализации
//
////        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=585c9164bd1d8176e9f6e179d07c0e89" // appid лучше так не хранить а вынести в отдельную константу
//        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(appId)&units=metric"
//////        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=London&appid=585c9164bd1d8176e9f6e179d07c0e89" // просто адрес строки url
//////        let url = URL(string: urlString) // создаем url
////        guard let url = URL(string: urlString) else { return }// чтобы безопасно извлечь наш url
////        let session = URLSession(configuration: .default) // создаем сессию - вся работа с сетевыми запросами идет через сессию
////        let task = session.dataTask(with: url) { data, response, error in
////            if let data = data {
////                // данный код использовали для проверки - уже не нужно
//////                let dataString = String(data: data, encoding: .utf8)
//////                print(dataString!)
////                if let currentWeather = self.parseJSON(withData: data) {// передать данные currentWeather в VC можно через клоужер или через делегирование - 2 способа чтобы после передачи сразу запустился обновление интерфейса
//////                completionHandler(currentWeather)
////                    // второй вариант
////                    self.onCompletion?(currentWeather)
////
////                }
////            }
////        }
////        task.resume()
//        performRequest(withURLString: urlString)
//    }
//    // метод получение инфы о погоде по получению гео координате
//
//    func fetchCurrentWeather(forLatitude latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
//
//
//      let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(appId)&units=metric"
//
////      guard let url = URL(string: urlString) else { return }
////      let session = URLSession(configuration: .default)
////      let task = session.dataTask(with: url) { data, response, error in
////          if let data = data {
////
////              if let currentWeather = self.parseJSON(withData: data) {
////                  self.onCompletion?(currentWeather)
////
////              }
////          }
////      }
////      task.resume()
//        performRequest(withURLString: urlString)
//  }
    
    fileprivate func performRequest(withURLString urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                if let currentWeather = self.parseJSON(withData: data) {
                    self.onCompletion?(currentWeather)
                }
            }
        }
        task.resume()
    }
    
    
    fileprivate func parseJSON(withData data: Data) -> CurrentWeather?{
        let decoder = JSONDecoder() // если есть try нужен do catch  блок
        do {
            let currentWeatherData = try decoder.decode(CurrentWeatherData.self, from: data)// нужен try
//            print(currentWeatherData.main.temp)
            guard let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData) else {
                return nil
            }
            return currentWeather
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}
