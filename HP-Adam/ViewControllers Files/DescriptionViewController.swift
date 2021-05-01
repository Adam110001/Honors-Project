//
//  DescriptionViewController.swift
//  HP-Adam
//
//  Created by Adam Dovciak on 22/01/2021.
//

import UIKit

class DescriptionViewController: UIViewController {

    @IBOutlet var viewMain: UIView!
    
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title2: UILabel!
    @IBOutlet weak var title3: UILabel!
    
    @IBOutlet weak var paragraph1: UILabel!
    @IBOutlet weak var paragraph2: UILabel!
    @IBOutlet weak var paragraph3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Help Screen"
        
        viewMain.backgroundColor = .systemGray5
        
        title1.text = "About Section"
        paragraph1.text = "This application has been created to help pet lovers and people who are looking to learn more about their pet, or pets. Thus, using this application user can distinguish 164 breeds of cats and dogs, which he/she can learn more interesting facts about in the app, or in the Wikipedia provided within the app."
        
        title2.text = "Privacy Policies"
        paragraph2.text = "This app is inline with GDPR rules to collect users information. We only store your email and a full name on a secure Google database powered by Firebase. However, if you feel like you do not want to your information stored on our database. Please, contact the developer 40325068."
        
        title3.text = "Contact"
        paragraph3.text = "Feel free to contact the developer 40325068 to learn more about the amazing features of this app has to offer."
    }
    
}
