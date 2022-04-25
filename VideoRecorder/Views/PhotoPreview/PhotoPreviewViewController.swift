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
    var viewModel = DigitalAuthViewModel()
    var photoPath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        previewImageView.layer.cornerRadius = previewImageView.frame.size.height / 2
        previewImageView.contentMode = .scaleAspectFill
        guard let photo = photo else {
            return
        }
//        uploadPhoto(photoPath: photoPath)
        previewImageView.image = photo
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        binding()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unobserveAll()
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        guard let photoPath = photoPath else {
            return
        }


        viewModel.uploadedImage(photoPath: photoPath)
    }
    
//    func uploadPhoto(photoPath: String) {
//        let semaphore = DispatchSemaphore (value: 0)
//
//        let parameters = [
//          [
//            "key": "file",
//            "src": photoPath,
//            "type": "file"
//          ],
//          [
//            "key": "fileTypeId",
//            "value": "1",
//            "type": "text"
//          ]] as [[String : Any]]
//
//        let boundary = "Boundary-\(UUID().uuidString)"
//        var body = ""
//        var _: Error? = nil
//        for param in parameters {
//          if param["disabled"] == nil {
//            let paramName = param["key"]!
//            body += "--\(boundary)\r\n"
//            body += "Content-Disposition:form-data; name=\"\(paramName)\""
//            if param["contentType"] != nil {
//              body += "\r\nContent-Type: \(param["contentType"] as! String)"
//            }
//            let paramType = param["type"] as! String
//            if paramType == "text" {
//              let paramValue = param["value"] as! String
//              body += "\r\n\r\n\(paramValue)\r\n"
//            } else {
//              let paramSrc = param["src"] as! String
//                let fileData = try? NSData(contentsOfFile:photoPath, options:[]) as Data
////                let fileContent = String(data: fileData!, encoding: .utf8)!
//              body += "; filename=\"\(paramSrc)\"\r\n"
//                + "Content-Type: \"content-type header\"\r\n\r\n\(fileData)\r\n"
//            }
//          }
//        }
//        body += "--\(boundary)--\r\n";
//        let postData = body.data(using: .utf8)
//
        var request = URLRequest(url: URL(string: "http://185.135.30.104:8080/api/digital/files/2553465d-ba7a-4807-af16-a7947e1f2911")!,timeoutInterval: Double.infinity)
//        request.addValue("Bearer eyJhbGciOiJIUzUxMiJ9.eyJjZWxsUGhvbmVObyI6Ijk4OTEyNzIzMTczOSIsImlzcyI6IkJhYW0tRGlnaXRhbC1Db3JlIiwic3ViIjoiU21zQXV0aGVudGljYXRpb24iLCJqdGkiOiI5YTZkMzEyZS1iMjhmLTQ1ZmItYWFmMi05MmI5ZmVhMWFmOTIiLCJhdWQiOiJodHRwczovL215LmJtaS5pciIsImlhdCI6MTY1MDg2Nzc4OCwiZXhwIjoxNjUwOTU0MTg4fQ.gciCUn0_Jx26Q6OBA1i3Hc-EuxXH7VH91gtv9A0yiFSQxP7j0E-dSrDVxZvDLf7u3DP8PeLBvSU_qegoJ9LOoQ", forHTTPHeaderField: "Authorization")
//        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        request.httpMethod = "POST"
//        request.httpBody = postData
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//
//            let res = response as? HTTPURLResponse
//            print(res?.statusCode)
//          guard let data = data else {
//            print(String(describing: error))
//            semaphore.signal()
//            return
//          }
//          print(String(data: data, encoding: .utf8)!)
//          semaphore.signal()
//        }
//
//        task.resume()
//        semaphore.wait()
//    }
}

extension PhotoPreviewViewController {
    func binding() {
        viewModel.isUploadedImage.addEventHandler { [weak self] value in
            guard let self = self else {return}
            guard value.newValue else {
                return
            }
            
            let previewVC = self.storyboard?.instantiateViewController(withIdentifier: "RecordVideoViewController") as? RecordVideoViewController
            self.navigationController?.pushViewController(previewVC!, animated: true)
            
        }
    }
}
