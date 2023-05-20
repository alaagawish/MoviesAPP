//
//  FavouriteTableViewController.swift
//  MoviesApp
//
//  Created by Alaa on 10/05/2023.
//

import UIKit
import CoreData

class FavouriteTableViewController: UITableViewController {
    var movies: [Item] = [ ]
    var moviesR: [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        retrieveMovie()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        retrieveMovie()
        
        tableView.reloadData()
    }
 

    override func numberOfSections(in tableView: UITableView) -> Int {
         
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return movies.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = movies[indexPath.row].title
        // Configure the cell...

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = movies[indexPath.row]
        if  let details = self.storyboard?.instantiateViewController(withIdentifier:  "details") as? MovieViewController{
            
          details.item = selected
          details.isFav = true
          details.index = indexPath.row
          navigationController?.pushViewController(details, animated: true)
        }
    }

    func retrieveMovie(){
        let localS = LocalSource(fav: "l")
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavMovie")
       
        
        do{
            moviesR = try localS.managedContext.fetch(fetchRequest)
            movies = []
            tableView.reloadData()
            for item in moviesR{
                let newM = Item()
                newM.weeks = item.value(forKey: "weeks") as? String
                newM.gross = item.value(forKey: "gross") as? String
                newM.title = item.value(forKey: "title") as? String
                newM.image = item.value(forKey: "image") as? String
                newM.weekend = item.value(forKey: "weekend") as? String
                newM.rank = item.value(forKey: "rank") as? String
                newM.id = item.value(forKey: "id") as? String
                movies.append(newM)
              
            }
            
        }catch let error as NSError{
            print(error)
        }
        
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let alert : UIAlertController = UIAlertController(title: "Delete item", message: "ARE YOU SURE TO DELETE?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .default,handler: { action in
            print("delete done")
            self.movies.remove(at: indexPath.row)
            tableView.reloadData()
            let loc = LocalSource(fav: "fav")
            loc.managedContext.delete(self.moviesR[indexPath.row])
            self.moviesR.remove(at: indexPath.row)
            do{
                try loc.managedContext.save()
                
            }catch let error as NSError{
                print("error in deleteing \(error)")
            }
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel,handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    

}
