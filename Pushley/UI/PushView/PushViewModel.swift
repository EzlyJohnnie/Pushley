//
//  PushViewModel.swift
//  Pushley
//
//  Created by Johnnie Cheng on 6/3/20.
//  Copyright © 2020 Johnnie Cheng. All rights reserved.
//

import SwiftUI
import Alamofire
import Combine

protocol PushViewModelProtocol: ObservableObject {
    
    var certificate: Certificate? { get }
    func send()
    
}

class PushViewModel: PushViewModelProtocol {
    
    private let pushNotificationRepository: PushNotificationRepositoryProtocol
    
    init(pushNotificationRepository: PushNotificationRepositoryProtocol) {
        self.pushNotificationRepository = pushNotificationRepository
    }
    
    @Published var certificate: Certificate?
    @Published var environment = Environment.sandbox
    @Published var pushType = PushType.alert
    @Published var notificationTitle = ""
    @Published var notificationBody = ""
    @Published var targetToken = ""
    @Published var log = ""
    
    func showCertificatePicker() {
        let pickerBuilder = FilePickerBuilder.defaultSingleFilePicker()
        pickerBuilder.allowedFileTypes = ["p12"]
        
        if let pickedFileUrl = FilePicker.pick(builder: pickerBuilder)?.first {
            self.log("Loading certificate...from \(pickedFileUrl)")
            if let password = Dialog.getInputText(title: "Password:", needSecure: true) {
                let data = try! Data(contentsOf: pickedFileUrl)
                let certificate = Certificate(data: data, password: password)
                if certificate.isValid {
                    self.certificate = certificate
                    self.pushNotificationRepository.updateCertificate(certificate)
                    self.log("Certificate loaded! -- \(self.certificate?.label ?? "")")
                }
                else {
                    Dialog.showSimpleAlert(title: "Wrong Password")
                    self.log("Failed load certificate!")
                }
            }
            else {
                self.log("Cancel loading certificate")
            }
        }
    }
    
    func send() {
        guard certificate?.isValid ?? false else {
            self.log("Failed to push -- Invalid certificate")
            return
        }
        
        let notification = PushNotification(targetToken: targetToken,
                                            title: notificationTitle,
                                            body: notificationBody,
                                            environment: environment,
                                            type: pushType,
                                            priority: pushType.defaultPriority,
                                            sound: nil,
                                            badge: nil,
                                            contentAvailable: pushType.defaultContentAvailable,
                                            extraData: nil)
        
        pushNotificationRepository.sendNotification(notification: notification) { error in
            let result = error == nil ? "Notification send success!" : error.debugDescription
            self.log(result)
        }
    }
    
    private func log(_ log: String) {
        self.log.append("\(self.log.isEmpty ? "" : "\n")\(Date().timeOnlyString): \(log)")
    }

}

extension PushViewModel: Injectable {
    
    static func inject<T>(container: DIContainer) -> T? {
        let pushNotificationRepository = container.injectPushNotificationRepository()!
        return PushViewModel(pushNotificationRepository: pushNotificationRepository) as? T
    }
    
}
