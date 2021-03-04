//
//  Reachability.swift
//  TCPCommunication
//
//  Created by boreum yoon on 2021/03/04.
//

import UIKit
import SystemConfiguration

class Reachability: NSObject {
    public func isConnectedToNetwork() -> Bool {
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)

            guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else {
                return false
            }

            var flags: SCNetworkReachabilityFlags = []
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                return false
            }
            if flags.isEmpty {
                return false
            }
        let isReachable = flags.contains(.reachable)
                let needsConnection = flags.contains(.connectionRequired)

                return (isReachable && !needsConnection)
            }
        }


