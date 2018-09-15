//
//  ViewController.swift
//  Mapa
//
//  Created by Daniel Aguiar on 14/9/18.
//  Copyright © 2018 Daniel Aguiar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapVIew: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Mostrar a localizacao do usuario
        mapVIew.showsUserLocation = true
        
        //Rastrear a localizacao do usuario
        mapVIew.userTrackingMode = .follow
        
        // Definindo o delegate do mapview
        mapVIew.delegate = self
        
        
        //Define a delegate (classe que responde) da SearchBar
        searchBar.delegate = self
        
        
        requestestAuthorization()
        
    }
// Solicitando autorizacao do usuario para o uso da sua localizacao
    func requestestAuthorization(){
        
        // defininco a precisao da localizacao do usuario
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // solicitando autorizacao para uso da localizacao com o app em uso
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    
    
}


extension ViewController: UISearchBarDelegate{
    //Implementando método disparado pelo botao search da search bar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // retirando o foco da searchBar (Esconder o teclado)
        searchBar.resignFirstResponder()
        
        // Criando objeto que configura uma pesquisa de pontos de interese
        let request = MKLocalSearchRequest()
        
        // Configurando a região do mapa onde a pesquisa sera feita
        request.region = mapVIew.region
        
        // Definindo o que sera buscado
        request.naturalLanguageQuery = searchBar.text
        
        // criando objeto que realiza a pesquisa
        let search = MKLocalSearch(request: request)
        
        // realizando a pesquisa
        search.start { (response, error) in
            if error == nil { //Não teve erro na pesquisa
                guard let response = response else {return}
                
                // remover as anotations previamente adicionadas
                self.mapVIew.removeAnnotations(self.mapVIew.annotations)
            
                // varrer todos os pontos de interesse trazidos pela pesquisa
                for item in response.mapItems{
                    // criando uma annotation
                    let annotation = MKPointAnnotation()
                    
                    //definindo a latitude e a longitude da annotation
                    annotation.coordinate = item.placemark.coordinate
                    
                    // definindo um titulo e subtitulo da annotation
                    annotation.title = item.name
                    annotation.subtitle = item.url?.absoluteString
                    
                    // Adicionar annotation no mapa
                    self.mapVIew.addAnnotation(annotation)
                }
            }
        }
    }
}


extension ViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            
            renderer.lineWidth = 7.0
            renderer.strokeColor = .blue
            
            return renderer
        }else{return MKOverlayRenderer(overlay: overlay)}
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Criando um objeto de configuracao da requisicao de rota
        let request = MKDirectionsRequest()
        
        // configura a origem e o destino da rota
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: view.annotation!.coordinate))
        
        // criando objeto que realiza o calculo da rota
        let directions = MKDirections(request: request)
        
        // Calcular a rota
        directions.calculate { (response, error) in
            if error == nil{//nao deu erro
                guard let response = response else {return}
                
                //recuperando a rota
                guard let route = response.routes.first else {return}
                
                // Nome da rota
                print(route.name)
                
                // Distancia da rota
                print(route.distance)
                
                //Passo a passo da rota
                for step in route.steps{
                    print(step.distance)
                }
                
                
                //apagar as rotas anteriores
                self.mapVIew.removeOverlays(self.mapVIew.overlays)
                
                // adicionar a rota no mapa
                self.mapVIew.add(route.polyline, level: .aboveRoads)
            }
        }
    }
}


