//
//  PairingURL.swift
//  Dash
//
//  Created by Yuji Nakayama on 2020/10/31.
//  Copyright © 2020 Yuji Nakayama. All rights reserved.
//

import UIKit

class PairingURLItem: NSObject, UIActivityItemSource {
    let vehicleID: String

    lazy var url: URL = {
        var urlComponents = URLComponents()
        urlComponents.scheme = "dash-remote"
        urlComponents.host = "pair"
        urlComponents.queryItems = [URLQueryItem(name: "vehicleID", value: vehicleID)]
        return urlComponents.url!
    }()

    init(vehicleID: String) {
        self.vehicleID = vehicleID
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return url
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return url
    }
}
