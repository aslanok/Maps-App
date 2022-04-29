//
//  ViewController.swift
//  HaritaUygulamasi
//
//  Created by MacBook on 15.04.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapsViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var notTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager() //burda locationManager objesi yaratıldı
    var secilenLatitude = Double()
    var secilenLongitude = Double()
    
    var secilenIsim : String = ""
    var secilenId : UUID?
    
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
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
        
        if secilenIsim != "" {
            //coreData'dan verileri çek
            if let uuidString = secilenId?.uuidString {
                print(uuidString) //secilenİsmin uuid String verisini aldık
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Yer")
                fetchRequest.predicate = NSPredicate(format: "id  = %@",uuidString) //filtreleme işlemi yapıyoruz burda. id'si uuidString'e eşit olanları getir diyoruz bu satırlarda
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest) //burda bize bi dizi dönüyor
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let  isim = sonuc.value(forKey: "isim") as? String {
                                annotationTitle = isim
                            }
                            if let not = sonuc.value(forKey: "not") as? String {
                                annotationSubtitle = not
                            }
                            if let latitude = sonuc.value(forKey: "latitude") as? Double {
                                annotationLatitude = latitude
                            }
                            if let longitude = sonuc.value(forKey: "longitude") as? Double {
                                annotationLongitude = longitude
                            }
                            let annotation = MKPointAnnotation()
                            annotation.title = annotationTitle
                            annotation.subtitle = annotationSubtitle
                            let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                            annotation.coordinate = coordinate
                            mapView.addAnnotation(annotation)
                            isimTextField.text = annotationTitle
                            notTextField.text = annotationSubtitle
                            //tableView'daki konuma bakarken bulunduğmuz konuma göre yapılan güncellemeyi yapmayı bırak diyorum
                            locationManager.stopUpdatingLocation()
                            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            let region = MKCoordinateRegion(center: coordinate, span: span)
                            mapView.setRegion(region, animated: true)
                        }
                    }
                } catch {
                    print("Hata")
                }
                
            }
            
        } else {
            //yeni veri eklenecektir
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { //eğer ki annotasyon kullanıcının kendi konumunu gösteriyorsa bişey yapmayacağız
            return nil
        }
        //tekrar kullanılabilir bi annotation oluşturduk
        let reuseId = "benimAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            //baştan oluşturucaz
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true //callout gösterilebilirmi'ye evet dediğimiz için gidip aşağıda da bu butona tıklanınca ne olacağını seçeceğiz
            pinView?.tintColor = .blue
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure) //bu buttonu kullanarak kullanıcının şu an bulunduğu konumdan tableView'dan tıkladığı konuma gitmesini sağlayacağız
            pinView?.rightCalloutAccessoryView = button
            
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if secilenIsim != "" {
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarkDizisi, hata in
                if let placemarks = placemarkDizisi { //placemark boş mu diye checkledik
                    if placemarks.count > 0 { //placemark içinde herhangi bi obje var mı diye checkledik
                        let yeniPlaceMark = MKPlacemark(placemark: placemarks[0])
                        let item = MKMapItem(placemark: yeniPlaceMark)
                        item.name = self.annotationTitle
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }
        }
    }
    
    //burda dokunduğumuz yerin ne olduğunu dışardan aldık
    @objc func konumSec(gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state == .began { //gesture'ın durumuna baktık
            let dokunulanNokta = gestureRecognizer.location(in: mapView) //mapview'e dokunuyoruz
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView) //coordinateView'dan çekilecek ve bu da bizim mapView'imiz
            
            //dokunulan noktadaki enlem ve boylamı aldık
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            
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
        
        //secilen isim boşsa alttaki satırlara giriyor çünkü eğer ki secilenisim boş olmazsa kullancı önceden kaydetmiş olduğu bi konuma gitmek isteyecektir
        if secilenIsim == ""{
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            //region yaratırken de bizden span istiyor. alt satırda span yarattık
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) //0.1 0.1 burda yakın bir zoom sağlıyor fakat 0.5 mesela uzak bir görüntü verecektir
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true) //map'te gezinirken istenilen konuma doğru gitmeyi sağlayan kod satırı budur.Bunda region istiyor ve biz de region yarattık.

        }
    }
    
    
    @IBAction func kaydetTapped(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(notTextField.text, forKey: "not")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        yeniYer.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("kayit edildi")
        } catch {
            print("Hata var ")
        }
        //notificationCenter'ı direkt kaydet'e bastıktan sonra tableView'e dönmek için oluşturduk
        NotificationCenter.default.post(name: NSNotification.Name("yeniYerOlusturuldu"), object: nil) //notificationcenterda böyle bir veri yolladık.
        navigationController?.popViewController(animated: true) //bir önceki viewController'a gitmemizi sağlıyor
    }

}

