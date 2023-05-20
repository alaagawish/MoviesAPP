//
//  RemoteSource.swift
//  MoviesApp
//
//  Created by Alaa on 08/05/2023.
//

import Foundation

func getResponse( handler: @escaping(MyResponse?) -> Void){
    let url = URL(string: "https://imdb-api.com/en/API/BoxOffice/k_3jb3naz8")!
    let request = URLRequest(url: url)
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    let task = session.dataTask(with: request) { data , response , error  in
        
        guard let data = data else{
            return
        }
        do{
            let result = try JSONDecoder().decode(MyResponse.self, from: data)
           // print(result.items?[0].title ?? "nothing")
            print(" \n\n\n\n\n\(result.items?.count ?? 0)")
            handler(result)
        }catch{
            print("error getting data")
            handler(nil)
        }
    }
    task.resume()
    
    
}
