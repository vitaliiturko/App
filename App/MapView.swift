import SwiftUI
import MapKit

struct CustomLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let imageName: String
}

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 49.86178040663408, longitude: 24.017566040711145),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var routeLine: MKPolyline?
    @State private var showFullMap = false

    let locations = [
        CustomLocation(coordinate: CLLocationCoordinate2D(latitude: 49.86178040663408, longitude: 24.017566040711145), imageName: "Bitcoin"),
        CustomLocation(coordinate: CLLocationCoordinate2D(latitude: 49.870032281418204, longitude: 24.02273499702508), imageName: "Bitcoin")
    ]

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Інформація про термінали")
                    .font(.title)
                    .bold()
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)

                HStack {
                    Image("terminal")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 5)

                    Spacer()

                    Button {
                        showFullMap.toggle()
                    } label: {
                        Image("map")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .sheet(isPresented: $showFullMap) {
                        fullMap
                    }
                }
                .padding(.horizontal)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.8), Color.black.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
                )
                .cornerRadius(12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        TerminalInfoView(
                            title: "Біткоїн-банкомат у ТРЦ “Інтерсіті”",
                            address: "просп. В’ячеслава Чорновола, 67г",
                            locationDetails: "1-й поверх, біля головного входу, поруч з ліфтом та меблевим магазином",
                            schedule: ["Пн–Сб: 10:00–20:00", "Нд: 10:00–19:00"],
                            currencies: "BTC, ETH, USDT, LTC, TRX, DASH, BNB, WLD",
                            operations: "купівля та продаж криптовалюти за готівку"
                        )

                        TerminalInfoView(
                            title: "Біткоїн-банкомат у ТРЦ “Спартак”",
                            address: "вул. Гетьмана Мазепи, 1Б",
                            locationDetails: "під ескалатором, біля магазину Brocard",
                            schedule: ["щодня з 10:00 до 22:00"],
                            currencies: "BTC, ETH, USDT, LTC, TRX",
                            operations: "купівля/продаж криптовалют за готівку"
                        )
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top)
            .background(Color(.systemBackground))
            .navigationTitle("Карта")
        }
    }

    var fullMap: some View {
        MapViewContainer(region: $region, locations: locations, routeLine: $routeLine)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                let tappedCoordinate = region.center
                selectedCoordinate = tappedCoordinate
                if let selectedCoordinate = selectedCoordinate {
                    getRoute(to: selectedCoordinate)
                }
            }
    }

    func getRoute(to destinationCoordinate: CLLocationCoordinate2D) {
        let userLocation = CLLocationCoordinate2D(latitude: 49.86178040663408, longitude: 24.017566040711145)

        let userLocationPlacemark = MKPlacemark(coordinate: userLocation)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userLocationPlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                return
            }
            self.routeLine = route.polyline
        }
    }
}

struct TerminalInfoView: View {
    let title: String
    let address: String
    let locationDetails: String
    let schedule: [String]
    let currencies: String
    let operations: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text("Адреса: \(address)")
            Text("Розташування: \(locationDetails)")

            Text("Графік роботи:")
            ForEach(schedule, id: \.self) { line in
                Text("• \(line)")
            }

            Text("Підтримувані валюти: \(currencies)")
            Text("Операції: \(operations)")
        }
        .font(.subheadline)
        .foregroundColor(.primary)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MapViewContainer: UIViewRepresentable {
    var region: Binding<MKCoordinateRegion>
    var locations: [CustomLocation]
    var routeLine: Binding<MKPolyline?>

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(region.wrappedValue, animated: true)
        uiView.removeAnnotations(uiView.annotations)

        for location in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = location.coordinate
            uiView.addAnnotation(annotation)
        }

        uiView.removeOverlays(uiView.overlays)

        if let routeLine = routeLine.wrappedValue {
            uiView.addOverlay(routeLine)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(routeLine: routeLine)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var routeLine: Binding<MKPolyline?>

        init(routeLine: Binding<MKPolyline?>) {
            self.routeLine = routeLine
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

#Preview {
    MapView()
}
