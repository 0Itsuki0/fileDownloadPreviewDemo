//
//  ViewController.swift
//  fileDownloadPreviewDemo
//
//  Created by Itsuki on 2023/10/30.
//

import UIKit

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate {
    let urlString: String = "https://www.pngall.com/wp-content/uploads/5/Pokemon-Pikachu-PNG-Free-Download.png"

    var documentController:UIDocumentInteractionController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        documentController = nil
    }

    @IBAction func onDownloadButtonPressed(_ sender: UIButton) {
        // downloadTask: completion handler
//        downloadFileCompletionHandler(urlstring: urlString) {(destinationUrl, error) in
//            if let url = destinationUrl {
//                print(url)
//            } else {
//                print(error!)
//            }
//            
//        }
        
        // downloadTask: Async
//        Task {
//            let url = await downloadFileDownloadTaskAsync(urlstring: urlString)
//            if let url = url {
//                print(url)
//            }
//        }
        
        // downloadFileDataTask
        Task {
            let url = await downloadFileDataTask(urlstring: urlString)
            if let url = url {
                print(url)
                // presenting using UIDocumentInteractionController
//                DispatchQueue.main.async {
//                    documentController = UIDocumentInteractionController(url: url)
//                    documentController.delegate = self
//                    documentController.presentPreview(animated: true)
//                }

                
                // presenting using webview
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    guard let filePreviewController = storyboard.instantiateViewController(withIdentifier: FilePreviewController.controllerIdentifier) as? FilePreviewController
                    else {return}
                    filePreviewController.url = url
                    filePreviewController.modalPresentationStyle = .fullScreen
                    self.present(filePreviewController, animated: true)

                }
            }
        }
    }
    
}


extension ViewController {
    
    private func downloadFileDataTask(urlstring: String) async -> URL? {

        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
       
        let (data, response)  = try! await URLSession.shared.data(for: request)
        
        if let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                print("download finished")
                let documentsUrl =  try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
                print(destinationUrl)
                if FileManager().fileExists(atPath: destinationUrl.path) {
                    print("File already exists [\(destinationUrl.path)]")
        //            try! FileManager().removeItem(at: destinationUrl)
                    return destinationUrl
                }
                try! data.write(to: destinationUrl)
                return destinationUrl
            }
        }
        return nil
    }
    
    
    
    
    private func downloadFileDownloadTaskCompletionHandler(urlstring: String, completion: @escaping (URL?, Error?) -> Void) {

        let url = URL(string: urlstring)!
        let documentsUrl =  try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        print(destinationUrl)

        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
//            try! FileManager().removeItem(at: destinationUrl)
            completion(destinationUrl, nil)
            return
        }
        
        let request = URLRequest(url: url)

        let task = URLSession.shared.downloadTask(with: request) { tempFileUrl, response, error in
//            print(tempFileUrl, response, error)
            if error != nil {
                completion(nil, error)
                return
            }

            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let tempFileUrl = tempFileUrl {
                        print("download finished")
                        try! FileManager.default.moveItem(at: tempFileUrl, to: destinationUrl)
                        completion(destinationUrl, error)
                    } else {
                        completion(nil, error)
                    }

                }
            }

        }
        task.resume()
    }
    
    private func downloadFileDownloadTaskAsync(urlstring: String) async -> URL? {
        
        let url = URL(string: urlstring)!

        let documentsUrl =  try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        print(destinationUrl)

        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
//            try! FileManager().removeItem(at: destinationUrl)
            return destinationUrl
        }
        
        let request = URLRequest(url: url)
        let (tempFileUrl, response, error)  = await downloadTaskAsync(request: request)
        if error != nil {
            return nil
        }
            
        if let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                if let tempFileUrl = tempFileUrl {
                    print("download finished")
                    try! FileManager.default.moveItem(at: tempFileUrl, to: destinationUrl)
                    return destinationUrl
                } else {
                    return nil
                }
            
            }
        }
        
        return nil
    }
    
    
    
    
    private func downloadTaskAsync(request: URLRequest) async  -> (URL?, URLResponse?, Error?) {
            
        return await withCheckedContinuation{ continuation in
            URLSession.shared.downloadTask(with: request) { tempFileUrl, response, error in
                continuation.resume(returning: (tempFileUrl, response, error))
            }.resume()
        }
        
    }

    
    
    
    
    
}

