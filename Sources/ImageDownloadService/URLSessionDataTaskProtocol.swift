//
//  URLSessionDataTaskProtocol.swift
//  
//
//  Created by Mikhail Borisov on 26.12.2021.
//

public protocol URLSessionDataTaskProtocol: AnyObject {

	func resume()

	func cancel()
}
