//
//  NetworkStatus.swift
//
//
//  Created by Mihajlo Saric on 7.10.24..
//

import Foundation
import Network

@Observable public class NetworkStatusMonitor {
  private var monitor: NWPathMonitor
  private var queue: DispatchQueue
  private let notificationCenter: NotificationCenter

  public var isConnected: Bool = true {
    didSet {
      notificationCenter.post(
        name: .networkStatusMonitorStatusChanged,
        object: nil,
        userInfo: ["isConnected": isConnected]
      )
    }
  }

  public init(notificationCenter: NotificationCenter = .default) {
    self.notificationCenter = notificationCenter
    monitor = NWPathMonitor()
    queue = DispatchQueue.global(qos: .background)
    monitor.pathUpdateHandler = { [weak self] path in
      DispatchQueue.main.async {
        self?.isConnected = path.status == .satisfied
      }
    }
    monitor.start(queue: queue)
  }

  deinit {
    monitor.cancel()
  }
}

extension Notification.Name {
  public static let networkStatusMonitorStatusChanged = Self(
    "Notification.Name.networkStatusMonitorStatusChanged")
}

