//
//  PhotoPreviewViewController.swift
//  VideoRecorder
//
//  Created by Morteza on 4/24/22.
//

import UIKit

class PhotoPreviewViewController: UIViewController {

    @IBOutlet weak var previewImageView: UIImageView!
    var photo: UIImage? = nil
    override func viewDidLoad() {
        super.viewDidLoad()

        previewImageView.layer.cornerRadius = previewImageView.frame.size.height / 2
        previewImageView.contentMode = .scaleAspectFill
        guard let photo = photo else {
            return
        }

        previewImageView.image = photo
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
