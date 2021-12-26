//
//  ImageDownloadError.swift
//  
//
//  Created by Mikhail Borisov on 26.12.2021.
//

import Foundation

public enum ImageDownloadError: Error, LocalizedError {

	case dataCorrupted
	case badRequest

	public var errorDescription: String? {
		switch self {
		case .dataCorrupted:
			return "Invalid cast data to UIImage"
		case .badRequest:
			return "Invalid URLRequest"
		}
	}
}
