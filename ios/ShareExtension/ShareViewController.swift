//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Yuji Nakayama on 2020/01/28.
//  Copyright © 2020 Yuji Nakayama. All rights reserved.
//

import UIKit
import DashCloudKit
import JGProgressHUD

enum ShareError: Error {
    case pairingRequired
    case serverError
    case unknown
}

class ShareViewController: UIViewController {
    lazy var hud: JGProgressHUD = {
        let hud = JGProgressHUD()

        hud.square = true

        let animation = JGProgressHUDFadeAnimation()
        animation.duration = 0.2
        hud.animation = animation

        return hud
    }()

    let feedbackGenerator = UINotificationFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()

        // On Mac clear background doesn't appear correctly
        #if targetEnvironment(macCatalyst)
        view.backgroundColor = .systemBackground
        #endif

        feedbackGenerator.prepare()

        share()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // We want to show the HUD after the modal transition animation is finished
        // so that the HUD won't appear from bottom and won't move the position strangely by change of the view frame.
        hud.show(in: view, animated: true)
    }

    func share() {
        guard let vehicleID = PairedVehicle.defaultVehicleID else {
            self.cancelRequest(withError: ShareError.pairingRequired, message: "Pairing Required")
            return
        }

        hud.textLabel.text = "Sending"

        cloudClient.share(item, with: vehicleID) { (error) in
            if let error = error {
                self.cancelRequest(withError: error, message: "Failed")
            } else {
                self.completeRequest()
            }
        }
    }

    lazy var cloudClient = DashCloudClient()

    lazy var item: Item = {
        let extensionItems = self.extensionContext!.inputItems as! [NSExtensionItem]
        return Item(extensionItem: extensionItems.first!)
    }()

    func completeRequest() {
        hud.textLabel.text = "Sent"
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.extensionContext!.completeRequest(returningItems: nil)
        }

        feedbackGenerator.notificationOccurred(.success)
    }

    func cancelRequest(withError error: Error, message: String) {
        hud.textLabel.text = message
        hud.indicatorView = JGProgressHUDErrorIndicatorView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.extensionContext!.cancelRequest(withError: error)
        }

        feedbackGenerator.notificationOccurred(.error)
    }
}
