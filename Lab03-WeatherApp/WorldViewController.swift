//
//  WorldViewController.swift
//  Lab03-WeatherApp
//
//  Created by RNLD on 2023-11-13.
//

import UIKit

class WorldViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var countryListView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateScrollView()
        
    }

    @IBAction func btnDismiss(_ sender: UIButton) {
        
        dismiss( animated: true, completion: nil )
        
    }
    
    func populateScrollView() {
        let url = URL(string: "https://restcountries.com/v3.1/all")!

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching countries: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let countries = try JSONDecoder().decode([Country].self, from: data)
                DispatchQueue.main.async {
                    self.addCountriesToScrollView(countries)
                }
            } catch {
                print("Error decoding countries: \(error.localizedDescription)")
                // Display an alert to the user
                self.showAlert(message: "Error fetching countries. Please try again.")
            }
        }.resume()
    }

    
    
    
    func addCountriesToScrollView(_ countries: [Country]) {
        DispatchQueue.main.async {
            var yPosition: CGFloat = 0.0
            let labelHeight: CGFloat = 30.0

            for country in countries {
                let label = UILabel(frame: CGRect(x: 0, y: yPosition, width: self.countryListView.frame.width, height: labelHeight))
                label.text = country.name
                label.textAlignment = .center
                self.countryListView.addSubview(label)

                // Adjust yPosition for the next label
                yPosition += labelHeight
            }

            // Set the content size of the scroll view based on the total height of labels
            self.countryListView.contentSize = CGSize(width: self.countryListView.frame.width, height: yPosition)
        }
    }

    
}

struct Country: Codable {
    let name: String
    let alpha2Code: String
    // Add other properties as needed
}


extension WorldViewController {
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
