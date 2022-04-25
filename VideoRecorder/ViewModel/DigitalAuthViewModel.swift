//
//  DigitalAuthViewModel.swift
//  VideoRecorder
//
//  Created by Morteza on 4/25/22.
//

import Foundation
import UIKit

class DigitalAuthViewModel {
    
    public var isUploadedImage:       Observable<Bool> = Observable(false)
    
    func uploadedImage(photoPath: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else {return}
            self.isUploadedImage.value = true
        }
    }
}
