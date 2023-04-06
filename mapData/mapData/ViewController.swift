//
//  ViewController.swift
//  mapData
//
//  Created by Berken Özbek on 21.03.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var nameTextField: UITextField!
    var locationManager = CLLocationManager()
    var selectedLatidtude = Double()
    var selectedLongitude = Double()

    var selectedName = ""
    var selectedId : UUID?
    
    var annotationTitle = ""
    var annotationAltitude = Double()
    var annotationLongitude = Double()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if selectedName != ""{
            if let UUIDstring = selectedId?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context =  appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Map")
                fetchRequest.predicate = NSPredicate(format: "Id : %@ ", UUIDstring )
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let result = try context.fetch(fetchRequest)
                    if result.count > 0 {
                        for i in result as! [NSManagedObject]{
                            if let name = i.value(forKey: "name") as? String{
                                annotationTitle = name
                                if let latitude = i.value(forKey: "altitude") as? Double{
                                    annotationAltitude = latitude
                                    if let longitude = i.value(forKey: "longitude") as? Double {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationAltitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        mapView.addAnnotation(annotation)
                                        nameTextField.text = annotationTitle
                             
                                    }
                                }
                            }
                        }
                    }
                }catch{
                    print("Error...")
                }
             }
        }else{
            
        }
        
        let locationRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(takeMap(gestureRecognizer: )))
        locationRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(locationRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
    @objc func takeMap(gestureRecognizer : UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began{
            let touchDot = gestureRecognizer.location(in: mapView)
            let touchCoordinate = mapView.convert(touchDot, toCoordinateFrom: mapView)
            
            selectedLatidtude = touchCoordinate.latitude
            selectedLongitude = touchCoordinate.longitude
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            annotation.title = nameTextField.text
            mapView.addAnnotation(annotation)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations[0].coordinate.latitude)
        print(locations[0].coordinate.longitude)
        
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)

    }
    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Map", into: context)
        
        newLocation.setValue(nameTextField.text, forKey: "name")
        newLocation.setValue(selectedLatidtude, forKey: "altitude")
        newLocation.setValue(selectedLongitude, forKey: "longitude")
        newLocation.setValue(UUID(), forKey: "id")
        
        do{
            try context.save()
            print("Saved...")

        }catch{
            print("Error...")
        }

    }
    
}

