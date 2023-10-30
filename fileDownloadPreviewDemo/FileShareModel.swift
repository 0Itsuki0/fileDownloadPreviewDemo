//
//  FileShareModel.swift
//  fileDownloadPreviewDemo
//
//  Created by Itsuki on 2023/10/30.
//

import Foundation
import UIKit
import LinkPresentation

final class FileShareModel: NSObject, UIActivityItemSource {
    let url: URL
    let data: Data
    let title: String

    init(url: URL, title: String) throws {
        self.url = url
        self.title = title
        self.data = try Data(contentsOf: url)
        super.init()
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        data
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        data
    }

    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.url = url
        metadata.originalURL = url
        metadata.iconProvider = NSItemProvider(contentsOf: url)
        return metadata
    }
}
