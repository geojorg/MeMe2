//
//  DetailViewController.swift
//  MeMe2
//
//  Created by Jorge Guerrero on 13/05/21.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var memedDetailedImage: UIImageView!
    var memeImage : UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.memedDetailedImage.image = self.memeImage
    }
}
