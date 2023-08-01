//
//  Extension.swift
//  FoodBook
//
//  Created by Terry Jason on 2023/7/31.
//

import UIKit
import CoreData

func letDelegateContext() -> NSManagedObjectContext {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    return context
}

func fetchData() -> NSFetchRequest<NSFetchRequestResult> {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Food")
    fetchRequest.returnsObjectsAsFaults = false
    
    return fetchRequest
}

func insertData(name: String, location: String, price: String, image: UIImage) {
    
    let newFood = NSEntityDescription.insertNewObject(forEntityName: "Food", into: letDelegateContext())
    
    newFood.setValue(name, forKey: "name")
    newFood.setValue(location, forKey: "location")
    
    if let price = Int(price) {
        newFood.setValue(price, forKey: "price")
    }
    
    newFood.setValue(UUID(), forKey: "id")
    
    let data = image.jpegData(compressionQuality: 1)
    
    newFood.setValue(data, forKey: "image")
    
    contextSave()
    
}

func contextSave() {
    do {
        try letDelegateContext().save()
        print("Success")
    } catch {
        print("Failure")
    }
}

func notificationCenterPost() {
    NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
}
