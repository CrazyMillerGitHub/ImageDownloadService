import UIKit

@available(iOS 13.0.0, *)
final public class ImageDownloadService: ImageDownloadServiceProtocol {

	private var pendingRequest: [URLRequest: TaskState] = [:]
	private let cacheService: CacheServiceProtocol?

	public init(cacheService: CacheServiceProtocol) {
		self.cacheService = cacheService
	}

	@available(iOS 13.0, *)
	private enum TaskState {
		case finished(image: UIImage)
		case inProgress(task: Task<UIImage, Error>)
	}

	@available(iOS 15.0, *)
	public func download(with request: URLRequest) async throws -> UIImage {
		if let state = pendingRequest[request] {
			switch state {
			case .inProgress(let task):
				return try await task.value
			case .finished(let image):
				return image
			}
		}
		if let image = cacheService?.image(for: request) {
			pendingRequest[request] = .finished(image: image)
			return image
		}
		let task: Task<UIImage, Error> = Task {
			let (data, _) = try await URLSession.shared.data(for: request)
			guard let image = UIImage(data: data) else {
				throw ImageDownloadError.dataCorrupted
			}
			cacheService?.persist(image: image)
			return image
		}
		pendingRequest[request] = .inProgress(task: task)
		let fetchedImage = try await task.value
		pendingRequest[request] = .finished(image: fetchedImage)

		return fetchedImage
	}
}

