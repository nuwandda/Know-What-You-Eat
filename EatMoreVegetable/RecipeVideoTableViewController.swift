//
//  RecipeVideoTableViewController.swift
//  EatMoreVegetable
//
//  Created by Rapsodo Mobile 6 on 25.12.2019.
//  Copyright © 2019 Rapsodo Mobile 6. All rights reserved.
//

import UIKit
import CoreData

class RecipeVideoTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var recipesTableView: UITableView!
    
    //MARK: Properties
    var recipeItems = [Recipe]() {
        didSet {
            if self.recipesTableView != nil {
                DispatchQueue.main.async {
                    self.recipesTableView.reloadData()
                }
            }
        }
    }
    var moc:NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    var videos: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recipesTableView.allowsSelection = true
        recipesTableView.allowsMultipleSelection = false
        recipesTableView.dataSource = self
        recipesTableView.delegate = self
        
        moc = appDelegate?.persistentContainer.viewContext
        
        loadInitialData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipeItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedRecipe = recipeItems[indexPath.row]
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "RecipeVideoViewController") as? RecipeVideoViewController{
            
            vc.recipe = selectedRecipe
            var tempRow = indexPath.row
            for _ in 0..<self.recipeItems.count {
                if tempRow >= recipeItems.count {
                    tempRow = 0
                }

                vc.recipes.append(self.recipeItems[tempRow])
                tempRow += 1
            }
//            vc.recipes = self.recipeItems
            vc.titleCounter = indexPath.row
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
        var cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell")
        if cell == nil || cell?.detailTextLabel == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "VideoCell")
        }
        
        let recipeItem = recipeItems[indexPath.row]
        
        let videoName = recipeItem.videoName

        cell?.textLabel?.text = videoName
        
        let videoCaption = recipeItem.videoCaption
        cell?.detailTextLabel?.text = videoCaption
        
        cell?.imageView?.image = UIImage(named: "gordon_ramsey")
        
        return cell!
    }

}

//MARK: RecipeVideoTableViewController
extension RecipeVideoTableViewController {
    
    func loadData() {
        
        let recipeRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "videoName", ascending: false)
        recipeRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try recipeItems = moc.fetch(recipeRequest)
        }
        catch {
            print("ERROR: Could not load data!")
        }
        
        self.recipesTableView.reloadData()
    }
    
    func loadInitialData() {
        
        if (AutoCountHelper.shared.autoCountData == 0) {
            
            // TODO: Change the name of the video to real one.
            guard let path1 = Bundle.main.path(forResource: "bulletTrain-clip", ofType:"mp4") else {
                debugPrint("Video not found")
                return
            }
            
            guard let path2 = Bundle.main.path(forResource: "CHRISTMAS RECIPE- Roasted Turkey With Lemon Parsley & Garlic - Gordon Ramsay", ofType:"mp4") else {
                debugPrint("Video not found")
                return
            }
            
            guard let path3 = Bundle.main.path(forResource: "Gordon Ramsay's Top 5 Chicken Recipes", ofType:"mp4") else {
                debugPrint("Video not found")
                return
            }
            
            var entity = NSEntityDescription.entity(forEntityName: "Recipe", in: self.moc)!
            var recipe = NSManagedObject(entity: entity, insertInto: self.moc)
            
            recipe.setValue("Christmas Recipe", forKey: "videoName")
            recipe.setValue("Christmas Beef Wellington", forKey: "videoCaption")
            recipe.setValue(path1, forKey: "videoUrl")
            self.videos?.append(path1)
            
            do {
                try self.moc.save()
            } catch let error as NSError {
              print("Could not save. \(error), \(error.userInfo)")
            }
            
            entity = NSEntityDescription.entity(forEntityName: "Recipe", in: self.moc)!
            recipe = NSManagedObject(entity: entity, insertInto: self.moc)
            
            recipe.setValue("Christmas Recipe", forKey: "videoName")
            recipe.setValue("Roasted Turkey With Lemon Parsley & Garlic", forKey: "videoCaption")
            recipe.setValue(path2, forKey: "videoUrl")
            self.videos?.append(path2)
            
            do {
                try self.moc.save()
            } catch let error as NSError {
              print("Could not save. \(error), \(error.userInfo)")
            }
            
            entity = NSEntityDescription.entity(forEntityName: "Recipe", in: self.moc)!
            recipe = NSManagedObject(entity: entity, insertInto: self.moc)
            
            recipe.setValue("Top 5 Recipes", forKey: "videoName")
            recipe.setValue("Gordon Ramsay's Top 5 Chicken Recipes", forKey: "videoCaption")
            recipe.setValue(path3, forKey: "videoUrl")
            self.videos?.append(path3)
            
            do {
                try self.moc.save()
            } catch let error as NSError {
              print("Could not save. \(error), \(error.userInfo)")
            }
            
            AutoCountHelper.shared.updateAutoCountData()
        }
    }
}
