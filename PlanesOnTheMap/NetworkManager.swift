//
//  NetworkManager.swift
//  PlanesOnTheMap
//
//  Created by Sena Küçükerdoğan on 17.12.2024.
//

import Foundation

class NetworkManager {
    
    //MARK: - Request from Open Sky Network Api
    
    func fetchFlights(lomin: Double, lamin: Double, lomax: Double, lamax: Double, completion: @escaping (Result<FlightModel, Error>) -> Void) {
        let urlString = "https://{Kucuk:Kucuk123.}@opensky-network.org/api/states/all?lomin=\(lomin)&lamin=\(lamin)&lomax=\(lomax)&lamax=\(lamax)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let decodedData = try decoder.decode(FlightModel.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
