//
//  FirstViewController.swift
//  mapData
//
//  Created by Berken Özbek on 4.04.2023.
//

import UIKit
import CoreData

class FirstViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        locationName = nameArray[indexPath.row]
        locationId = idArray[indexPath.row ]
         performSegue(withIdentifier: "toSecondVC", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSecondVC"{
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedName = locationName
            destinationVC.selectedId = locationId
        }
    }
    

    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var locationName = ""
    var locationId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(image: .add, style: UIBarButtonItem.Style.plain, target: self, action: #selector(clickedAddButton))
        takeData()
    }
    func takeData(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Map")
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(request)
            if results.count > 0 {
                nameArray.removeAll()
                idArray.removeAll()
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String{
                        nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }
                    
                }
                tableView.reloadData()
            }
            }catch{
                print("Error...")
            }
            
        }
        @objc func clickedAddButton(){
            locationName = ""
            performSegue(withIdentifier: "toSecondVC", sender: nil )
        }
 

}
