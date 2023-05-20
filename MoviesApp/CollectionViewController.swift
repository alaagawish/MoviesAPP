//
//  CollectionViewController.swift
//  MoviesApp
//
//  Created by Alaa on 08/05/2023.
//

import UIKit
import Kingfisher
import Reachability
import CoreData


class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, DeleteFromCollection {
    var movies: MyResponse?
    var moviesFromCore: [NSManagedObject] = []
    var storedMovies: [Item] = [ ]
    var stored:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let reachability = try! Reachability()
        if reachability.connection != .unavailable {
            print("Network is available")
            stored = false
        } else {
            print("Network is not available")
            self.getStoredMovies()
            stored = true
        }

        reachability.whenReachable = { reachability in
            print("Network is available")
        }
        reachability.whenUnreachable = { reachability in
            print("Network is not available")
           
        }
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }

        
        getResponse { [weak self] (result) in
            DispatchQueue.main.async {
                if ((self?.stored) != true){
                self?.movies = result
                self?.storeMoviesToCore(m: self?.movies?.items ?? [])
                self?.collectionView.reloadData()}
            }
        }

    }
 
    func getStoredMovies(){
        
        let loc =  LocalSource()
        let fetchReq = NSFetchRequest<NSManagedObject>(entityName: "StoredMovie")
        
        do{
             moviesFromCore = try loc.managedContext.fetch(fetchReq)
            for i in moviesFromCore{
               
                let item = Item()
                item.rank = i.value(forKey: "rank") as? String
                item.image = i.value(forKey: "image") as? String
                item.weekend = i.value(forKey: "weekend") as? String
                item.weeks = i.value(forKey: "weeks") as? String
                item.title = i.value(forKey: "title") as? String
                item.id = i.value(forKey: "id") as? String
                item.gross = i.value(forKey: "gross") as? String
                storedMovies.append(item )
            }
            
        }catch let error as NSError{
            print("error retreved stored movies: \(error)")
        }
    }
    
    
    func storeMoviesToCore(m: [Item]){
        let localSource = LocalSource()
      
        storedMovies = []
        deleteAllInCoreData()
        for i in m{
            let movie = NSManagedObject(entity: localSource.entity, insertInto: localSource.managedContext)
            movie.setValue(i.id, forKey: "id")
            movie.setValue(i.title, forKey: "title")
            movie.setValue(i.weekend, forKey: "weekend")
            movie.setValue(i.rank, forKey: "rank")
            movie.setValue(i.image, forKey: "image")
            movie.setValue(i.gross, forKey: "gross")
            movie.setValue(i.weeks, forKey: "weeks")
            do{
               try localSource.managedContext.save()
                print("\n\n\ndone adding data to core data\n\n\n\n")
            }catch let error as NSError{
                print(error)
                print("Erorr saving object ")
            }
        }
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.size.width/2 - 10, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if stored{
            let selected = storedMovies[indexPath.row]
            if  let details = self.storyboard?.instantiateViewController(withIdentifier:  "details") as? MovieViewController{
                
                details.item = selected
                details.index = indexPath.row
                details.collectionDelete = self
                navigationController?.pushViewController(details, animated: true)
               
            }
        }else{
            let selected = movies?.items?[indexPath.row]
            if  let details = self.storyboard?.instantiateViewController(withIdentifier:  "details") as? MovieViewController{
                self.stored = true
                details.item = selected
                storedMovies = movies?.items ?? []
                details.collectionDelete = self
                details.index = indexPath.row
                navigationController?.pushViewController(details, animated: true)
            }
        }
    }
   

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        if stored{
            return storedMovies.count
        }
        return movies?.items?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if stored{
            (cell.viewWithTag(2) as! UILabel).text = storedMovies[indexPath.row].title
            (cell.viewWithTag(1) as! UIImageView).kf.setImage(with:  URL(string: (storedMovies[indexPath.row].image)!))
        }else{
            
            (cell.viewWithTag(2) as! UILabel).text = movies?.items![indexPath.row].title
            (cell.viewWithTag(1) as! UIImageView).kf.setImage(with:  URL(string: (movies?.items?[indexPath.row].image)!))
        }
        return cell
    }


    func deleteMov(index: Int) {
        print("kkkkkkkkkkkk \(index)")
        if stored{
            storedMovies.remove(at: index)
            collectionView.reloadData()
            print("reload done")
        }
    }
    
    func deleteAllInCoreData(){
        
        let loc =  LocalSource()
        let fetchReq = NSFetchRequest<NSManagedObject>(entityName: "StoredMovie")
        
        do{
            let movies = try loc.managedContext.fetch(fetchReq)
            for i in movies{
                loc.managedContext.delete(i)
            }
            try loc.managedContext.save()
            
        }catch let error as NSError{
            print("error retreved stored movies: \(error)")
        }
    }
}
