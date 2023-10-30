//
//  FilePreviewController.swift
//  fileDownloadPreviewDemo
//
//  Created by Itsuki on 2023/10/30.
//

import UIKit
import WebKit

class FilePreviewController: UIViewController, UIDocumentInteractionControllerDelegate, WKUIDelegate {
    static let controllerIdentifier = String(describing: FilePreviewController.self)

    @IBOutlet weak var navigationBar: UINavigationBar!
    var documentController:UIDocumentInteractionController!
    var activityController: UIActivityViewController!
    var url: URL!
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var webView: WKWebView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.scrollView.isScrollEnabled = true
        webView.contentMode = .center
        

        let request = URLRequest(url: url)
        webView.load(request)

        documentController = UIDocumentInteractionController(url: url)
        documentController.delegate = self

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationBarTitle.title = url.lastPathComponent
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("removing file")
        try! FileManager().removeItem(at: url)
        activityController = nil
    }

    
    @IBAction func onCloseButtonPressed(_ sender: UIBarButtonItem) {
        print("dismissing")
        self.dismiss(animated: true)
    }
    
    @IBAction func onMoreOptionButtonPressed(_ sender: UIBarButtonItem) {
        print("more options")
//        documentController.presentOptionsMenu(from: sender, animated: true)
//                activityController = UIActivityViewController(activityItems: [url as Any], applicationActivities: nil)
//        
//        let data = try! Data(contentsOf: url)

        let fileShareModel = try! FileShareModel(url: url, title: url.lastPathComponent)
        
        activityController = UIActivityViewController(activityItems: [fileShareModel], applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = self.view
        self.present(activityController, animated: true, completion: nil)
    }

    


}
