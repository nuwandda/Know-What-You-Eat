

import UIKit
import CoreData
import Firebase

class EatMoreVegetableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewRecipesButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    //MARK: Properties
    var foodItems = [Food]() {
        didSet {
            if self.tableView != nil {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    var moc:NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setUI()
    }
    
    fileprivate func setUI() {
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.white
        
        
        moc = appDelegate?.persistentContainer.viewContext
        
        viewRecipesButton.layer.cornerRadius = 6
        viewRecipesButton.layer.borderWidth = 1
        viewRecipesButton.layer.borderColor = UIColor.black.cgColor
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
        
        if (foodItems.count == 0) {
            
            tableView.setEmptyView(title: "You don't have any history.", message: "Your meals will be in here.")
        }
        
        else {
            
            tableView.restore()
        }
        
        return foodItems.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let data = foodItems[indexPath.row]
            moc.delete(data)
            foodItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
            do {
                try moc.save()
            } catch {
                print("ERROR: Couldn't delete the selected item!")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedFood = foodItems[indexPath.row]
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "EatMoreVegetableDetailsViewController") as? EatMoreVegetableDetailsViewController{
            vc.food = selectedFood
            vc.delegate = self as? EatMoreVegetableDetailsViewControllerDelegate
            vc.pageMode = .updateProcess
            
            if selectedFood.foodType == "Meat" {
                vc.foodTypeMode = .meat
            }
            else if selectedFood.foodType == "Vegetable" {
                vc.foodTypeMode = .vegetable
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let foodItem = foodItems[indexPath.row]
        let foodType = foodItem.foodType
        cell.textLabel?.text = foodType
        
        let foodDate = foodItem.added!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy, hh:mm"
        
        cell.detailTextLabel?.text = dateFormatter.string(from: foodDate)
        
        if foodType == "Meat" {
            cell.imageView?.image = UIImage(named: "Hamburger")
        } else {
            cell.imageView?.image = UIImage(named: "Pumpkin")
        }
        
        return cell
    }
    
    @IBAction func addFruitToDatabase(_ sender: UIButton) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "EatMoreVegetableDetailsViewController") as? EatMoreVegetableDetailsViewController {
            
            if sender.tag == 0 {
                vc.foodTypeMode = .meat
            } else {
                vc.foodTypeMode = .vegetable
            }
            
            vc.pageMode = .createProcess
            vc.delegate = self as? EatMoreVegetableDetailsViewControllerDelegate
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    @IBAction func viewRecipes(_ sender: UIButton) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "RecipeVideoTableViewController") as? RecipeVideoTableViewController {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func logOutTapped(_ sender: UIButton) {
        
        do {
               try Auth.auth().signOut()
           }
        catch let signOutError as NSError {
               print ("Error signing out: %@", signOutError)
           }
           
           let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
           if let vc = mainStoryboard.instantiateViewController(withIdentifier: "StartViewController") as? StartViewController {
               
               self.navigationController?.pushViewController(vc, animated: true)
           }
    }
    
}

//MARK: EatMoreVegetableViewController
extension EatMoreVegetableViewController {
    
    func loadData() {
        
        let foodRequest:NSFetchRequest<Food> = Food.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "added", ascending: false)
        foodRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try foodItems = moc.fetch(foodRequest)
        } catch {
            print("ERROR: Could not load data!")
        }
        
        self.tableView.reloadData()
    }
    
    func addFood(food: Food) {
        
        let foodItem = Food(context: moc)
        
        foodItem.foodName = food.foodName
        foodItem.foodCalorie = food.foodCalorie
        foodItem.protein = food.protein
        foodItem.fat = food.fat
        foodItem.carbs = food.carbs
        foodItem.foodType = food.foodType
        foodItem.added = food.added
        foodItem.foodId = food.foodId
        foodItem.locationName = food.locationName
        foodItem.locationLatitude = food.locationLatitude
        foodItem.locationLongtitude = food.locationLongtitude
        
        appDelegate?.saveContext()
        
        self.loadData()
    }
    
    func foodAdded(food: Food) {
        self.addFood(food: food)
    }
    
    func foodUpdated(food: Food) {
        if let idx = self.foodItems.firstIndex(where: { $0.foodId == food.foodId }) {
            self.foodItems[idx] = food
        }
    }
    

}

//MARK: -UITableView
extension UITableView {
    
    func setEmptyView(title: String, message: String) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.lightGray
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        
        messageLabel.textColor = UIColor.darkGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
