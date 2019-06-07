//
//  MasterViewController.swift
//  ETC
//
//  Created by Yuji Nakayama on 2019/05/28.
//  Copyright © 2019 Yuji Nakayama. All rights reserved.
//

import UIKit
import Differ

class MasterViewController: UITableViewController, ETCDeviceManagerDelegate, ETCDeviceClientDelegate {
    var detailViewController: DetailViewController? = nil

    var deviceManager: ETCDeviceManager?
    var deviceClient: ETCDeviceClient?
    var observations: [NSKeyValueObservation] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        deviceManager = ETCDeviceManager(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - ETCDeviceManagerDelegate

    func deviceManager(_ deviceManager: ETCDeviceManager, didUpdateAvailability available: Bool) {
        if available {
            deviceManager.startDiscovering()
        }
    }

    func deviceManager(_ deviceManager: ETCDeviceManager, didConnectToDevice deviceClient: ETCDeviceClient) {
        self.deviceClient = deviceClient
        deviceClient.delegate = self
        startObservingDeviceAttributes(deviceClient.deviceAttributes)
        deviceClient.startPreparation()
    }

    func deviceClientDidFinishPreparation(_ device: ETCDeviceClient, error: Error?) {
        print(#function)
        try? device.send(ETCMessageFromClient.initialUsageRecordRequest)
    }

    func deviceClient(_ deviceClient: ETCDeviceClient, didReceiveMessage message: ETCMessageFromDeviceProtocol) {
        switch message {
        case is ETCMessageFromDevice.GateEntranceNotification:
            UserNotificationManager.shared.deliverNotification(title: "Entered ETC gate")
        case is ETCMessageFromDevice.GateExitNotification:
            UserNotificationManager.shared.deliverNotification(title: "Exited ETC gate")
        case let paymentNotification as ETCMessageFromDevice.PaymentNotification:
            UserNotificationManager.shared.deliverNotification(title: "ETC Payment: ¥\(paymentNotification.fee as Int?)")
        default:
            break
        }
    }

    func startObservingDeviceAttributes(_ attributes: ETCDeviceAttributes) {
        let observation = attributes.observe(\.usages, options: [.old, .new]) { [unowned self] (attributes, change) in
            self.tableView.animateRowChanges(oldData: change.oldValue!, newData: change.newValue!, deletionAnimation: .fade, insertionAnimation: .left)
        }
        observations.append(observation)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let usage = deviceClient!.deviceAttributes.usages[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = usage
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceClient?.deviceAttributes.usages.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ETCUsageTableViewCell

        let usage = deviceClient!.deviceAttributes.usages[indexPath.row]
        cell.usage = usage
        return cell
    }
}
