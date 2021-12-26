//
//  File.swift
//  
//
//  Created by 18673799 on 26.12.2021.
//

import Foundation
import UIKit

struct Subscriber {
	let uuid: UUID
	let handler: ((Result<UIImage, ImageDownloadError>) -> Void)?
	var dataTask: URLSessionDataTaskProtocol?
}

final class Observer {

	private let threadSafeQueue = DispatchQueue(label: "com.ObserverQueue", attributes: .concurrent)
	private(set) var handlers: [UUID: Subscriber] = [:]

	func subscribe(subscriber: Subscriber) {
		threadSafeQueue.async(flags: .barrier) { [unowned self] in
			self.handlers[subscriber.uuid] = subscriber
		}
	}

	func unsubscribe(uuid: UUID) {
		threadSafeQueue.sync {
			handlers[uuid]?.dataTask?.cancel()
		}
		threadSafeQueue.async(flags: .barrier) { [unowned self] in
			handlers.removeValue(forKey: uuid)
		}
	}

	func notify(_ result: Result<UIImage, ImageDownloadError>) {
		threadSafeQueue.sync {
			handlers.values.forEach { subscriber in subscriber.handler?(result) }
		}
	}
}
