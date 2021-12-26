//
//  ImageDownloadServiceProtocol.swift
//  
//
//  Created by Mikhail Boriosv on 26.12.2021.
//

import UIKit

public protocol ImageDownloadServiceProtocol {

	@available(iOS 15.0, *)
	func download(with request: URLRequest) async throws -> UIImage
}
