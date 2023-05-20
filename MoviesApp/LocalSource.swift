//
//  LocalSource.swift
//  MoviesApp
//
//  Created by Alaa on 10/05/2023.
//

import Foundation
import CoreData
import UIKit

class LocalSource{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var  managedContext: NSManagedObjectContext
    var entity: NSEntityDescription
    init() {
        //all movies
        managedContext = appDelegate.persistentContainer.viewContext
        
        entity = NSEntityDescription.entity(forEntityName: "StoredMovie", in: managedContext)!
    }
    
    init(fav:String) {
        //fav movies
         
        
        managedContext = appDelegate.persistentContainer.viewContext
        
        entity = NSEntityDescription.entity(forEntityName: "FavMovie", in: managedContext)!
    }
    
   
    
}
