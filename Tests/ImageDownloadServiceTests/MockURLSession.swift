//
//  File.swift
//  
//
//  Created by 18673799 on 26.12.2021.
//

@testable
import ImageDownloadService
import Foundation
import UIKit

final class URLSessionStub: URLSessionProtocol {

	var stubbedResult: (Data?, URLResponse?, Error?) = (nil, nil, nil)
	lazy var dataTask = MockURLSessionDataTask()
	var duration: DispatchTime = .now()

	func dataTaskWithRequest(request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
		dataTask.onResumeCalled = { [weak self] in
			guard let self = self else { return }
			DispatchQueue.global(qos: .background).asyncAfter(deadline: self.duration) {
				completionHandler(self.stubbedResult.0, self.stubbedResult.1, self.stubbedResult.2)
			}
		}
		return dataTask
	}
}

final class MockURLSessionDataTask: URLSessionDataTaskProtocol {

	var onResumeCalled: (() -> Void)?
	var resumeCalledCount: Int = 0
	
	func resume() {
		onResumeCalled?()
		resumeCalledCount += 1
	}

	func cancel() {
	}
}
