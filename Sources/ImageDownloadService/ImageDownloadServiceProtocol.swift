//
//  ImageDownloadServiceProtocol.swift
//  
//
//  Created by Mikhail Borisov on 26.12.2021.
//

import UIKit

public protocol ImageDownloadServiceProtocol {

	typealias Handler = (Result<UIImage, ImageDownloadError>) -> Void

	@available(iOS 15.0, *)
	func download(with request: URLRequest) async throws -> UIImage

	func download(with request: URLRequest, completion: @escaping Handler) -> UUID
}
