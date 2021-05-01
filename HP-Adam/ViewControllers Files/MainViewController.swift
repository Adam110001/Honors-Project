//
//  MainViewController.swift
//  HP-Adam
//
//  Created by Adam Dovciak on 22/01/2021.
//

import UIKit
import FirebaseAuth
import SDWebImage

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileActionButton: UIButton!
    @IBOutlet var MainUIView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewNoLogin: UITableView!
    @IBOutlet weak var noAnimalsScanned: UILabel!
    
    var models = [Model]()
    var animalFoundStringUpload: String = KeyVariables.MyVaraibles.foundAnimalUpload
    var animalFoundStringReal: String = KeyVariables.MyVaraibles.foundAnimalReal
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Application"
        
        profileView.backgroundColor = .link
        
        MainUIView.backgroundColor = .systemGray5
                
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .link
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            tableViewNoLogin.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let email = UserDefaults.standard
        
        if FirebaseAuth.Auth.auth().currentUser != nil {
            
            // Profile picture part
            let safeEmail = DatabaseManager.preprocessedEmail(emailAddress: email.value(forKey: "email") as! String)
            let filename = safeEmail + "_profile_picture.png"
            let path = "images/"+filename

            tableView.register(TableViewCell.nib(), forCellReuseIdentifier: TableViewCell.identifier)
            tableView.delegate = self
            tableView.dataSource = self
            
            if KeyVariables.MyVaraibles.firstImage.isEmpty {
                noAnimalsScanned.isHidden = false
                tableView.isHidden = true
                tableViewNoLogin.isHidden = true
            } else {
                noAnimalsScanned.isHidden = true
                tableView.isHidden = false
                tableViewNoLogin.isHidden = true
                
                let firstName = KeyVariables.MyVaraibles.firstImage
                print(firstName)
                
                // Models
                models.append(Model(text: "\(firstName)")) // #1
            }

            // Models
            models.append(Model(text: "\(KeyVariables.MyVaraibles.firstImage)")) // #1
            models.append(Model(text: "\(KeyVariables.MyVaraibles.secondImage)")) // #2
            models.append(Model(text: "\(KeyVariables.MyVaraibles.thirdImage)")) // #3
            models.append(Model(text: "\(KeyVariables.MyVaraibles.fourthImage)")) // #4
            models.append(Model(text: "\(KeyVariables.MyVaraibles.fifthImage)")) // #5
            
            profileActionButton.layer.masksToBounds = true
            profileActionButton.layer.cornerRadius = profileActionButton.frame.size.width/2
                        
            StorageManager.storageManager.URLDownloadImage(for: path, completion: { result in
                switch result {
                case .success(let url):
                    self.profileActionButton.sd_setImage(with: url, for: .normal, completed: nil)
                case .failure(let error):
                    print("Failed to get download url: \(error)")
                }
            })
        } else {
            noAnimalsScanned.isHidden = true
            tableView.isHidden = true
            tableViewNoLogin.isHidden = false
            
            tableViewNoLogin.register(NoLoginViewCell.nib(), forCellReuseIdentifier: NoLoginViewCell.identifier)
            tableViewNoLogin.delegate = self
            tableViewNoLogin.dataSource = self
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let cell = tableViewNoLogin.dequeueReusableCell(withIdentifier: NoLoginViewCell.identifier, for: indexPath) as! NoLoginViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier, for: indexPath) as! TableViewCell
            cell.configure(with: models)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    @IBAction func uploadActionButton(_ sender: Any) {
    }
}

struct Model {
    let text: String
    
    init(text: String) {
        self.text = text
    }
}
