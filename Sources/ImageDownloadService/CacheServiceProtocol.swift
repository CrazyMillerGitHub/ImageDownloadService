//
//  File.swift
//  
//
//  Created by Mikhail Borisov on 26.12.2021.
//

import UIKit

public protocol CacheServiceProtocol {

	/// Get Image base on request that you have
	/// - Returns: Optional: Image if you have
	func image(for request: URLRequest) -> UIImage?

	/// Add image to local storage
	func persist(image: UIImage)
}
