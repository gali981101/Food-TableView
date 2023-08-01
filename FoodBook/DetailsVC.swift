//
//  DetailsVC.swift
//  FoodBook
//
//  Created by Terry Jason on 2023/7/26.
//

import UIKit
import CoreData

class DetailsVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var locationText: UITextField!
    @IBOutlet weak var priceText: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenRestaurant = ""
    var chosenRestaurantId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenRestaurant != "" {
            saveButton.isHidden = true
            filterData()
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = .clear
            nameText.text = ""
            locationText.text = ""
            priceText.text = ""
        }
        
        view.addGestureRecognizer(createGesture(action: #selector(hideKeyboard)))
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(createGesture(action: #selector(selectImage)))
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        saveData()
    }
    
}

extension DetailsVC {
    
    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
}

extension DetailsVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.imageView.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        saveButton.isEnabled = true
        saveButton.backgroundColor = .systemBlue
        picker.dismiss(animated: true)
    }
}

extension DetailsVC {
    func createGesture(action: Selector?) -> UITapGestureRecognizer {
        let gesture = UITapGestureRecognizer(target: self, action: action)
        return gesture
    }
}

extension DetailsVC {
    
    private func saveData() {
        insertData(name: nameText.text!, location: locationText.text!, price: priceText.text!, image: imageView.image!)
        
        notificationCenterPost()
        self.navigationController?.popViewController(animated: true)
    }
    
    private func filterData() {
        solveResult(context: letDelegateContext(), fetch: fetchData())
    }
    
    private func solveResult(context: NSManagedObjectContext, fetch: NSFetchRequest<NSFetchRequestResult>) {
        
        let idString = chosenRestaurantId?.uuidString
        fetch.predicate = NSPredicate(format: "id = %@", idString!)
    
        do {
            let results = try context.fetch(fetch)
            handleResult(results: results)
        } catch {
            print("Failure")
        }
        
    }
    
    private func handleResult(results: [Any]) {
        if results.count > 0 {
            for result in results as! [NSManagedObject] {
                displayResult(result: result)
            }
        }
    }
    
    private func displayResult(result: NSManagedObject) {
        displayName(result: result)
        displayLocation(result: result)
        displayPrice(result: result)
        displayImage(result: result)
    }
    
    private func displayName(result: NSManagedObject) {
        if let name = result.value(forKey: "name") as? String {
            nameText.text = name
        }
    }
    
    private func displayLocation(result: NSManagedObject) {
        if let location = result.value(forKey: "location") as? String {
            locationText.text = location
        }
    }
    
    private func displayPrice(result: NSManagedObject) {
        if let price = result.value(forKey: "price") as? Int {
            priceText.text = String(price)
        }
    }
    
    private func displayImage(result: NSManagedObject) {
        if let image = result.value(forKey: "image") as? Data {
            imageView.image = UIImage(data: image)
        }
    }
    
}

















