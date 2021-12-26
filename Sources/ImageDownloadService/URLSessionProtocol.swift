//
//  URLSessionProtocol.swift
//  
//
//  Created by Mikhail Borisov on 26.12.2021.
//

import Foundation

public protocol URLSessionProtocol {
	typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
	func dataTaskWithRequest(request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}
