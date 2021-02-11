//
//  RearviewWidgetViewController.swift
//  Dash
//
//  Created by Yuji Nakayama on 2020/11/21.
//  Copyright © 2020 Yuji Nakayama. All rights reserved.
//

import UIKit
import RearviewKit

class RearviewWidgetViewController: UIViewController {
    var rearviewViewController: RearviewViewController?

    var configuration: RearviewConfiguration {
        return RearviewConfiguration(
            raspberryPiAddress: RearviewDefaults.shared.raspberryPiAddress,
            digitalGainForLowLightMode: RearviewDefaults.shared.digitalGainForLowLightMode,
            digitalGainForUltraLowLightMode: RearviewDefaults.shared.digitalGainForUltraLowLightMode
        )
    }

    var isVisible = false

    lazy var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureRecognizerDidRecognizeDoubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        return gestureRecognizer
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRearviewViewController()
    }

    func setUpRearviewViewController() {
        let rearviewViewController = RearviewViewController(configuration: configuration, cameraSensitivityMode: RearviewDefaults.shared.cameraSensitivityMode)
        rearviewViewController.delegate = self
        rearviewViewController.videoGravity = .resizeAspectFill

        addChild(rearviewViewController)
        rearviewViewController.view.frame = view.bounds
        view.addSubview(rearviewViewController.view)
        rearviewViewController.didMove(toParent: self)

        rearviewViewController.view.addGestureRecognizer(doubleTapGestureRecognizer)
        rearviewViewController.tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)

        self.rearviewViewController = rearviewViewController

        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        NotificationCenter.default.addObserver(rearviewViewController, selector: #selector(RearviewViewController.stop), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isVisible = false
    }

    @objc func applicationWillEnterForeground() {
        guard isVisible, let rearviewViewController = rearviewViewController else { return }

        rearviewViewController.configuration = configuration
        rearviewViewController.cameraSensitivityMode = RearviewDefaults.shared.cameraSensitivityMode
        rearviewViewController.start()
    }

    @objc func gestureRecognizerDidRecognizeDoubleTap() {
        openRearviewApp()
    }

    func openRearviewApp() {
        var urlComponents = URLComponents()
        urlComponents.scheme = "rearview"
        let url = urlComponents.url!
        UIApplication.shared.open(url, options: [:])
    }
}

extension RearviewWidgetViewController: RearviewViewControllerDelegate {
    func rearviewViewController(didChangeCameraSensitivityMode cameraSensitivityMode: CameraSensitivityMode) {
        RearviewDefaults.shared.cameraSensitivityMode = cameraSensitivityMode
    }
}
