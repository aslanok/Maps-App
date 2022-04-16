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
    
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var notTextField: UITextField!
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
        
        //kullanici ekrana uzun süre basınca onu algılamak için alttaki satırı yazıyoruz
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
    }
    //burda dokunduğumuz yerin ne olduğunu dışardan aldık
    @objc func konumSec(gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state == .began { //gesture'ın durumuna baktık
            let dokunulanNokta = gestureRecognizer.location(in: mapView) //mapview'e dokunuyoruz
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView) //coordinateView'dan çekilecek ve bu da bizim mapView'imiz
            let annotation = MKPointAnnotation()
            annotation.coordinate = dokunulanKoordinat //burda annotation gösterilecek dedik
            annotation.title = isimTextField.text ?? "kullanici seçimi"
            annotation.subtitle = notTextField.text ?? "kullanici notu"
            mapView.addAnnotation(annotation)
            
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)
        //location değişkeni sayesinde bir yer değişkeni tanımladık
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        //region yaratırken de bizden span istiyor. alt satırda span yarattık
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) //0.1 0.1 burda yakın bir zoom sağlıyor fakat 0.5 mesela uzak bir görüntü verecektir
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true) //map'te gezinirken istenilen konuma doğru gitmeyi sağlayan kod satırı budur.Bunda region istiyor ve biz de region yarattık.
    }


}

