//
//  URLSession+extension.swift
//  
//
//  Created by Mikhail Borisov on 26.12.2021.
//

import Foundation

extension URLSession: URLSessionProtocol {

	public func dataTaskWithRequest(
		request: URLRequest,
		completionHandler: @escaping DataTaskResult
	) -> URLSessionDataTaskProtocol {
		dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
	}
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
