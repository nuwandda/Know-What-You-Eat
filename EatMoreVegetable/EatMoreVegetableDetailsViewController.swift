

import UIKit
import CoreData
import MapKit

protocol EatMoreVegetableDetailsViewControllerDelegate {
    
    func foodAdded(food: Food)
    func foodUpdated(food: Food)
}

enum FoodVCMode {
    
    case updateProcess
    case createProcess
}

enum FoodTypeMode {
    
    case meat
    case vegetable
}

class EatMoreVegetableDetailsViewController: UIViewController {

    @IBOutlet weak var foodImageView: UIImageView!
    @IBOutlet weak var foodNameTextField: UITextField!
    @IBOutlet weak var foodDateLabel: UILabel!
    @IBOutlet weak var foodCalorieLabel: UILabel!
    @IBOutlet weak var foodCalorieStepper: UIStepper!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var proteinTextField: UITextField!
    @IBOutlet weak var fatTextField: UITextField!
    @IBOutlet weak var carbsTextField: UITextField!
    @IBOutlet weak var visitPlaceButton: UIButton!
    
    //MARK: Properties
    var food: Food?
    var calorie: Int = 0
    var delegate: EatMoreVegetableDetailsViewControllerDelegate?
    var pageMode: FoodVCMode = .updateProcess
    var foodTypeMode: FoodTypeMode = .meat
    var moc:NSManagedObjectContext!
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let dateFormatter = DateFormatter()
    var location: String?
    var locationCoordinates: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if locationLabel.text != "Location" {
            visitPlaceButton.isEnabled = true
            visitPlaceButton.layer.borderColor = UIColor.black.cgColor
            visitPlaceButton.backgroundColor = UIColor.systemOrange
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
    }
    
    func setupUI() {
        
        // To set new food with a new image
        if self.foodTypeMode == .meat {
            foodImageView.image = UIImage(named: "Hamburger")
        }
        else if self.foodTypeMode == .vegetable {
            foodImageView.image = UIImage(named: "Pumpkin")
        }
        
        // To set date with the new food
        dateFormatter.dateFormat = "dd MMMM yyyy, hh:mm"
        let dateStr = dateFormatter.string(from: Date())
        foodDateLabel.text = dateStr
        
        updateFoodAfterNavigation()
        moc = appDelegate?.persistentContainer.viewContext
        
        self.foodNameTextField.delegate = self
        self.proteinTextField.delegate = self
        self.fatTextField.delegate = self
        self.carbsTextField.delegate = self
        
        // Make buttons and text fields rounded and bordered
        saveButton.layer.cornerRadius = 6
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.black.cgColor
        
        visitPlaceButton.layer.cornerRadius = 6
        visitPlaceButton.layer.borderWidth = 1
        visitPlaceButton.layer.borderColor = UIColor.black.cgColor
        
        locationButton.layer.cornerRadius = 6
        locationButton.layer.borderWidth = 1
        locationButton.layer.borderColor = UIColor.black.cgColor
        
        foodCalorieStepper.layer.cornerRadius = 6;
        foodCalorieStepper.layer.borderWidth = 1;
        foodCalorieStepper.layer.borderColor = UIColor.black.cgColor
        
        if locationLabel.text == "Location" {
            visitPlaceButton.isEnabled = false
            visitPlaceButton.layer.borderColor = UIColor.gray.cgColor
            visitPlaceButton.backgroundColor = UIColor.gray
        }
        else {
            visitPlaceButton.isEnabled = true
        }
        
        // Create alert for descriptions
//        createAlert()
    }
    
    func saveNewFood(){
        // Function that is responsible for creating a food or updating a food.
        // For the '.createProcess' case, it creates a new food.
        // For the '.updateProcess' case, it updates the selected food.
        
        switch self.pageMode {
        case .createProcess:
            guard
                let name = foodNameTextField.text
            else {
                return
            }
            
            food = Food(context: moc)
            food?.foodName = name
            food?.added = Date()
            food?.foodId = Int16(AutoCountHelper.shared.updateAutocount())
            food?.protein = proteinTextField.text
            food?.fat = fatTextField.text
            food?.carbs = carbsTextField.text
            food?.foodCalorie = Int16(self.calorie)
            food?.locationName = self.location
            food?.locationLatitude = self.locationCoordinates?.latitude ?? 0.0
            food?.locationLongtitude = self.locationCoordinates?.longitude ?? 0.0
            
            if foodTypeMode == .meat {
                food?.foodType = "Meat"
            }
            else if foodTypeMode == .vegetable {
                food?.foodType = "Vegetable"
            }
            
            self.delegate?.foodAdded(food: food!)
            break
            
        case .updateProcess:
            guard let initialFood = self.food else { return }
            
            initialFood.added = initialFood.added ?? Date()
            initialFood.foodName = self.foodNameTextField.text ?? initialFood.foodName
            initialFood.foodCalorie = Int16(foodCalorieLabel.text!) ?? 0
            initialFood.protein = self.proteinTextField.text ?? initialFood.protein
            initialFood.fat = self.fatTextField.text ?? initialFood.fat
            initialFood.carbs = self.carbsTextField.text ?? initialFood.carbs
            initialFood.locationName = locationLabel.text ?? initialFood.locationName
            initialFood.locationLatitude = self.locationCoordinates?.latitude ?? initialFood.locationLatitude
            initialFood.locationLongtitude = self.locationCoordinates?.longitude ?? initialFood.locationLongtitude
            
            if foodTypeMode == .meat {
                food?.foodType = "Meat"
            }
            else if foodTypeMode == .vegetable {
                food?.foodType = "Vegetable"
            }
            
            self.delegate?.foodUpdated(food: initialFood)
            break
        }
    }
    
    @IBAction func stepperCalorieChanged(_ sender: Any) {
        
        calorie = Int(foodCalorieStepper.value)
        foodCalorieLabel.text = calorie.description
    }
    
    @IBAction func saveFood(_ sender: UIButton) {
        
        saveNewFood()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectLocation(_ sender: UIButton) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "EatMoreVegetableLocationViewController") as? EatMoreVegetableLocationViewController {
            
            vc.pageMode = .pick
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func visitLocation(_ sender: UIButton) {
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "EatMoreVegetableLocationViewController") as? EatMoreVegetableLocationViewController {
            
            vc.pageMode = .visit
            vc.location = self.food?.locationName
            vc.latitude = self.food?.locationLatitude
            vc.longtitude = self.food?.locationLongtitude
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    
}
//MARK: EatMoreVegetableDetailsViewController

extension EatMoreVegetableDetailsViewController: UITextViewDelegate {
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        return true
    }
}

extension EatMoreVegetableDetailsViewController: UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.foodNameTextField {
            self.proteinTextField.becomeFirstResponder()
            self.fatTextField.becomeFirstResponder()
            self.carbsTextField.becomeFirstResponder()
            
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func createAlert() {
        
        // Create the alert controller
        let alertController = UIAlertController(title: "Help", message: "Please fill the text field with the nutritive values of the food.", preferredStyle: .alert)

        // Create the actions
        let okAction = UIAlertAction(title: "Continue", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }

        // Add the actions
        alertController.addAction(okAction)

        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Private Functions
    private func updateFoodAfterNavigation() {
        
        guard let f = self.food
            else {
                return
        }
        
        self.dateFormatter.dateFormat = "dd MMMM yyyy, hh:mm"
        let dateStr = self.dateFormatter.string(from: (f.added ?? nil)!)
        
        
        navigationItem.title = f.foodType
        foodNameTextField.text = f.foodName
        proteinTextField.text = f.protein
        fatTextField.text = f.fat
        carbsTextField.text = f.carbs
        foodCalorieLabel.text = String(f.foodCalorie)
        locationLabel.text = f.locationName
        self.foodDateLabel.text = dateStr
        
        if f.foodType == "Meat"{
            foodImageView.image = UIImage(named: "Hamburger")
        }
        else if  f.foodType == "Vegetable"{
            foodImageView.image = UIImage(named: "Pumpkin")
        }
    }
    
}

//MARK: EatMoreVegetableLocationViewControllerDelegate
extension EatMoreVegetableDetailsViewController: EatMoreVegetableLocationViewControllerDelegate {
    
    func setLocation(location: String){
        self.locationLabel.text = location
        self.location = location
    }
    
    func setLocationCoordinates(coordinates: CLLocationCoordinate2D) {
        self.locationCoordinates = coordinates
    }
    
}
