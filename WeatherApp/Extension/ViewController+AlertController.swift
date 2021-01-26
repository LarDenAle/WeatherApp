//
//  ViewController+AlertController.swift
//  WeatherApp
//
//  Created by Denis Larin on 24.01.2021.
//

import Foundation
import UIKit

extension ViewController {
    // метод создания Alert Controller - котнроллер предупреждений
    func presentSearchAlertController(withTitle title: String?, message: String?, style: UIAlertController.Style, completionHandler: @escaping (String) -> Void) {// добавляем клоужер completionHandler
        let ac = UIAlertController(title: title, message: message, preferredStyle: style) // создание AC
        ac.addTextField{ tf in // добавляем текстовое поле
            let cities = ["Moscow", "Tula", "Orel"]
            tf.placeholder = cities.randomElement() // размещение рандомного города в плэйсхолдере
        }
        let search = UIAlertAction(title: "Search", style: .default) { action in // создание первой кнопки в Alert Controller _ AC
            let textField = ac.textFields?.first // создаем текстовое поле
            guard let cityName = textField?.text else { return } // и это текстовое поле получает имя города
            if cityName != "" { // если поле не пустое то выводим
//                print("search info for the \(cityName)")
//                self.networkWeatherManager.fetchCurrentWeather(forCity: cityName) // вариант как выводить информацию по городу - вместо этого будем передовать информацию через клоужеры
                
                // проблема города из 2 слов не ищутся - нужно добавить - если пробел то будет объединение с символом %20
                let city = cityName.split(separator: " ").joined(separator: "%20")
                completionHandler(city)
            }
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil) // создание второй кнопки
        
        ac.addAction(search) // добавляем action в AC
        ac.addAction(cancel)
                
        present(ac, animated: true, completion: nil)
    }
}
