//
//  ViewController.swift
//  FoodBook
//
//  Created by Terry Jason on 2023/7/26.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedRestaurant = ""
    var selectedRestaurantId : UUID?
    
    var deleteIndexRow : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = button
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        var content = cell.defaultContentConfiguration()
        
        content.text = nameArray[indexPath.row]
        
        cell.contentConfiguration = content
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRestaurant = nameArray[indexPath.row]
        selectedRestaurantId = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fetch = fetchData()
            
            deleteIndexRow = indexPath.row
            
            let idString = idArray[deleteIndexRow!].uuidString
            
            fetch.predicate = NSPredicate(format: "id = %@", idString)
            
            takeResult(context: letDelegateContext(), fetch: fetch, many: false)
        }
    }
    
}

extension ViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destination = segue.destination as! DetailsVC
            destination.chosenRestaurant = selectedRestaurant
            destination.chosenRestaurantId = selectedRestaurantId
        }
    }
    
}

extension ViewController {
    
    @objc func getData() {
        nameArray.removeAll()
        idArray.removeAll()
        
        takeResult(context: letDelegateContext(), fetch: fetchData(), many: true)
    }
    
    @objc func addButtonClicked() {
        selectedRestaurant = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
}

extension ViewController {
    
    private func takeResult(context: NSManagedObjectContext, fetch: NSFetchRequest<NSFetchRequestResult>, many: Bool) {
        do {
            let results = try context.fetch(fetch)
            handleData(results: results, number: many)
        } catch {
            print("error")
        }
    }
    
    private func handleData(results: [Any], number: Bool) {
        if results.count > 0 {
            for result in results as! [NSManagedObject] {
                appendOrDelete(result: result, parameters: number)
            }
        }
    }
    
    private func appendOrDelete(result: NSManagedObject, parameters: Bool) {
        if parameters == true {
            appendArray(result: result)
        } else {
            deleteArray(result: result)
        }
        
        self.tableView.reloadData()
    }
    
    private func appendArray(result: NSManagedObject) {
        appendName(result: result)
        appendID(result: result)
    }
    
    private func appendName(result: NSManagedObject) {
        if let name = result.value(forKey: "name") as? String {
            self.nameArray.append(name)
        }
    }
    
    private func appendID(result: NSManagedObject) {
        if let id = result.value(forKey: "id") as? UUID {
            self.idArray.append(id)
        }
    }
    
    private func deleteArray(result: NSManagedObject) {
        letDelegateContext().delete(result)
        contextSave()
        
        nameArray.remove(at: deleteIndexRow!)
        idArray.remove(at: deleteIndexRow!)
        
        return
    }
    
}









































