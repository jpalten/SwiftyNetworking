//
//  Networking.swift
//  SwitchConfig
//
//  Created by Jelle Alten on 05-07-18.
//  Copyright © 2018 Alt-N. All rights reserved.
//

import Foundation

public class Networking {

    // Return IP address of WiFi interface (en0) as a String, or `nil`
    public class func getWiFiAddress() -> (String?, String?) {
        var address: String?
        var subnet: String?

        // Get list of all interfaces on the local machine:
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return (nil, nil) }
        guard let firstAddr = ifaddr else { return (nil, nil) }

        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee

            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {

                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {

                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)

//                    let bla = inet_ntoa(<#T##in_addr#>)
//                    netmask = @(inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr));

                    if (getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                    &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        if let ipAddress = String.init(validatingUTF8: hostname) {

                            address = ipAddress

                            var netmaskName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                            getnameinfo(interface.ifa_netmask, socklen_t(interface.ifa_netmask.pointee.sa_len), &netmaskName, socklen_t(netmaskName.count),
                                        nil, socklen_t(0), NI_NUMERICHOST)// == 0
                            if let netmask = String.init(validatingUTF8: netmaskName) {
                                subnet = netmask
                            }
                        }
                    }

//                    address = String(cString: hostname)
//                    subnet = String(cString: netmask)
                    print("address \(String(describing: address)), subnet \(String(describing: subnet))")
                }

            }
        }
        freeifaddrs(ifaddr)

        return (address, subnet)
    }

    public class func getGateway() -> String? {

        return getDefaultGatewayIp()
    }

    public class var ipAddress: String? {
        
        let (ipAddress, _ ) = Networking.getWiFiAddress()
        return ipAddress
    }
}
