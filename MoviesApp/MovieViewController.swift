//
//  MovieViewController.swift
//  MoviesApp
//
//  Created by Alaa on 08/05/2023.
//

import UIKit
import Kingfisher
import CoreData

class MovieViewController: UIViewController {
    
    @IBOutlet weak var movieImg: UIImageView!
    
    @IBOutlet weak var movieRank: UILabel!
    
    @IBOutlet weak var movieTitle: UILabel!
    
    
    @IBOutlet weak var movieWeekend: UILabel!
    
    @IBOutlet weak var movieGross: UILabel!
    
    @IBOutlet weak var movieWeeks: UILabel!
    
    @IBOutlet weak var favButton: UIButton!
    
    
    @IBOutlet weak var deleteButton: UIButton!
    var item: Item?
    var isFav = false
    var favFromHome = false
    var index: Int = 0
    var collectionDelete: DeleteFromCollection?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if isFav {
            
            let img = UIImage(systemName: "heart.fill")
            favButton.setImage(img, for: UIControl.State.normal)
        }else{
             
            let img = UIImage(systemName: "heart")
            favButton.setImage(img, for: UIControl.State.normal)
            
            let loc =  LocalSource(fav: "f")
            let fetchReq = NSFetchRequest<NSManagedObject>(entityName: "FavMovie")
            
            do{
               let  moviesFr = try loc.managedContext.fetch(fetchReq)
                for i in moviesFr{
                   
                    let item = Item()
                    item.rank = i.value(forKey: "rank") as? String
                    item.image = i.value(forKey: "image") as? String
                    item.weekend = i.value(forKey: "weekend") as? String
                    item.weeks = i.value(forKey: "weeks") as? String
                    item.title = i.value(forKey: "title") as? String
                    item.id = i.value(forKey: "id") as? String
                    item.gross = i.value(forKey: "gross") as? String
                    if movieTitle.text == item.title{
                        let img = UIImage(systemName: "heart.fill")
                        favButton.setImage(img, for: UIControl.State.normal)
                        favFromHome = true
                       // favButton.isEnabled = false
                        break
                    }
                        
                }
                
            }catch let error as NSError{
                print("error retreved stored movies: \(error)")
            }
            
            
        }
   
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movieRank.text =  item?.rank
        movieGross.text = item?.gross
        movieTitle.text = item?.title
        movieWeeks.text = item?.weeks
        movieWeekend.text = item?.weekend
        
        
        let url = URL(string: item?.image ?? "")
        movieImg.kf.setImage(with: url)
        if isFav {
            deleteButton.isHidden = true
        }
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func removeItem(_ sender: Any) {
        
        
        let alert : UIAlertController = UIAlertController(title: "Delete item", message: "ARE YOU SURE TO DELETE?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "YES", style: .default,handler: { action in
            print("delete begin")
            
            let loc = LocalSource()
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "StoredMovie")
            print(self.movieTitle.text!)
            let myPreducate = NSPredicate(format: "title == %@", self.movieTitle.text!)
            fetchRequest.predicate = myPreducate
            do{
                let mm = try loc.managedContext.fetch(fetchRequest)
           
                loc.managedContext.delete(mm[0])
                print(self.index)
                self.collectionDelete?.deleteMov(index: self.index)
                try loc.managedContext.save()
             
                print("delete donneeeee\n\n")
                self.navigationController?.popViewController(animated: true)
              
            }catch let error as NSError{
                print("error in deleteing \(error)")
            }
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel,handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func addItemToFav(_ sender: Any) {
   
        if isFav == false{
            if favFromHome {
                removeFromFav()
            }else{
                
                print("!isfav")
                addToFav()
                favFromHome = true
                let img = UIImage(systemName: "heart.fill")
                favButton.setImage(img, for: UIControl.State.normal)
               // favButton.isEnabled = false
            }
        }else{
//            if !isFav {
//                print("!isfav")
//                addToFav()
//                let img = UIImage(systemName: "heart.fill")
//                favButton.setImage(img, for: UIControl.State.normal)
//                favButton.isEnabled = false
//                //        }else if !favFromHome{
//                //            print("!favfromhome")
//                //            addToFav()
//                //            let img = UIImage(systemName: "heart.fill")
//                //            favButton.setImage(img, for: UIControl.State.normal)
//                //            favFromHome = true
//                //        }else if favFromHome{
//                //            print("favfromhome")
//                //            removeFromFav()
//                //            favFromHome = false
//                //            let img = UIImage(systemName: "heart")
//                //            favButton.setImage(img, for: UIControl.State.normal)
//            }else{
                removeFromFav()
                
//            }
        }
   
 
    }
    func addToFav(){
        let localSource = LocalSource(fav: "f")
        let movie = NSManagedObject(entity: localSource.entity, insertInto: localSource.managedContext)
        movie.setValue(item?.id, forKey: "id")
        movie.setValue(item?.title, forKey: "title")
        movie.setValue(item?.weekend, forKey: "weekend")
        movie.setValue(item?.rank, forKey: "rank")
        movie.setValue(item?.image, forKey: "image")
        movie.setValue(item?.gross, forKey: "gross")
        movie.setValue(item?.weeks, forKey: "weeks")
        
        do{
            try localSource.managedContext.save()
            print("\n\n\ndone adding to fav\n\n\n\n")
            // favButton.image(for: UIImage(named: "heart-filled"))
        }catch let error as NSError{
            print(error)
            print("Erorr saving object to  fav ")
        }
    }
    func removeFromFav(){
        let localSource = LocalSource(fav: "f")
       
            
            let alert : UIAlertController = UIAlertController(title: "Delete item", message: "ARE YOU SURE TO remove from fav?", preferredStyle: .alert)
      
        alert.addAction(UIAlertAction(title: "YES", style: .default,handler: { action in
            print("delete begin")
            
            let loc = LocalSource()
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavMovie")
            print(self.movieTitle.text!)
            let myPreducate = NSPredicate(format: "title == %@", self.movieTitle.text!)
            fetchRequest.predicate = myPreducate
            do{
                let mm = try loc.managedContext.fetch(fetchRequest)
           
                loc.managedContext.delete(mm[0])
                print(self.index)
                self.collectionDelete?.deleteMov(index: self.index)
                try loc.managedContext.save()
                let img = UIImage(systemName: "heart")
                self.favButton.setImage(img, for: UIControl.State.normal)
                print("delete donneeeee\n\n")
                self.navigationController?.popViewController(animated: true)
              
            }catch let error as NSError{
                print("error in deleteing \(error)")
            }
        }))
        alert.addAction(UIAlertAction(title: "NO", style: .cancel,handler: nil))
        self.present(alert, animated: true, completion: nil)
        }
    }

