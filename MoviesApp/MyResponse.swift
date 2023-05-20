//
//  MyResponse.swift
//  MoviesApp
//
//  Created by Alaa on 08/05/2023.
//

import Foundation

class MyResponse: Decodable{
    
    var items: [Item]?
    var errorMessage: String?
}
