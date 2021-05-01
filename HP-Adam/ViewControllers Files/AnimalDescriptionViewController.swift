//
//  AnimalDescriptionViewController.swift
//  HP-Adam
//
//  Created by Adam Dovciak on 26/03/2021.
//

import UIKit
import SDWebImage
import SwiftSoup
import SafariServices
import JGProgressHUD

class AnimalDescriptionViewController: UIViewController {
    
    @IBOutlet weak var animalImageView: UIImageView!
    @IBOutlet weak var animalFoundLabel: UILabel!
    @IBOutlet weak var searchInternet: UIButton!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var loadingState = LoadingState.loading
    
    enum LoadingState {
        case loading, loaded, failed
    }
    
    var animalReadyForTitle: String = ""
    var urlWikipedia: String = ""
    var animalFoundString: String = KeyVariables.MyVaraibles.foundAnimalUpload
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var URLSuffixForWikipedia: String = ""
    
    override func viewDidAppear(_ animated: Bool) {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        // General Variables
        let animal = "\(animalFoundString)"
        let animalToMultipleStrings = animal.components(separatedBy: " ")
        let numberOfWords = animalToMultipleStrings.count
        let cleanAnimal = animalToMultipleStrings.suffix(numberOfWords - 3)
        
        // MARK - URL Wikipedia
        let animalReadyForURL = cleanAnimal.joined(separator: "_")
        urlWikipedia = "https://en.wikipedia.org/wiki/\(animalReadyForURL)"
        
        // Mark - Title Text For A Page
        let animalReady = cleanAnimal.joined(separator: " ")
        animalFoundLabel.text = animalReady
        
        //
        if KeyVariables.MyVaraibles.firstImage.isEmpty {
            KeyVariables.MyVaraibles.firstImage = animalReady
        }
        
        let safeEmail = DatabaseManager.preprocessedEmail(emailAddress: email)
        
        let animalToURL =  KeyVariables.MyVaraibles.foundAnimalURLUpload
        
        let filename = safeEmail + "_picture_\(animalToURL).png"
        let path = "imageTakenByAUser/"+filename
        
        StorageManager.storageManager.URLDownloadImage(for: path, completion: { result in
            switch result {
            case .success(let url):
                self.animalImageView.sd_setImage(with: url, completed: nil)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        
        // MARK - Description from Dictionary
        
        do {
            let content = try String(contentsOf: URL(string: urlWikipedia)!)
            let doc: Document = try SwiftSoup.parse(content)
            
            let p: Element = try doc.select("p:nth-of-type(3)").first()!
            
            let data: String = p.ownText()
            
            descriptionTextLabel.text = data
            
            if descriptionTextLabel.text == nil {
                descriptionTextLabel.text = "No description"
            }
        } catch {
            print("No description from Dictionary")
        }
        
        searchInternet.backgroundColor = .link
        searchInternet.setTitle("Read More", for: .normal)
        searchInternet.setTitleColor(.white, for: .normal)
        
        spinner.dismiss()
    }
    
    @IBAction func LearnMoreAboutTheAnimal(_ sender: Any) {
        guard let url = URL(string: urlWikipedia) else {
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
}
