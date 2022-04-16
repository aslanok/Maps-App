//
//  ViewController.swift
//  HaritaUygulamasi
//
//  Created by MacBook on 15.04.2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    var locationManager = CLLocationManager() //burda locationManager objesi yaratıldı
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //en iyi keskinliği sağlıyor. Bazen bu kadar keskinliğe gerek olmaz. Mesela 100m yakın kadarını buldursak yeterli olabilir. Gerekli ayarlamalar yapılır
        
        locationManager.requestWhenInUseAuthorization() //kullanıcı app'i kullanırken konum bilgisi alınır
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)
        
    
    }


}

