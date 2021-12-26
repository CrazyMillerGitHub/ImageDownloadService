import UIKit

@available(iOS 13.0.0, *)
final public class ImageDownloadService: ImageDownloadServiceProtocol {

	private var pendingRequest: [URLRequest: TaskState] = [:]
	private var internalPendingRequests: [URLRequest: RequestState] = [:]
	private var pendingRequests: [URLRequest: RequestState] {
		set {
			defer { lock.unlock() }
			lock.lock()
			guard let request = newValue.keys.first, let state = newValue.values.first else { return }
			internalPendingRequests[request] = state
		}
		get {
			return internalPendingRequests
		}
	}

	private let session: URLSessionProtocol
	private let cacheService: CacheServiceProtocol?
	private let lock = NSRecursiveLock()

	private enum RequestState {
		case finished(image: UIImage)
		case inProgress(observer: Observer)
	}

	public init(session: URLSessionProtocol = URLSession.shared, cacheService: CacheServiceProtocol? = nil) {
		self.session = session
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

	public func download(with request: URLRequest, completion: @escaping Handler) -> UUID {
		let uuid = UUID()
		if let state = pendingRequests[request] {
			switch state {
			case .finished(let image):
				completion(.success(image))
				return uuid
			case .inProgress(let observer):
				let subscriber = Subscriber(uuid: uuid, handler: completion)
				observer.subscribe(subscriber: subscriber)
				return uuid
			}
		}
		if let cacheService = cacheService, let image = cacheService.image(for: request) {
			pendingRequests[request] = .finished(image: image)
			return uuid
		}
		let observer = Observer()
		pendingRequests[request] = .inProgress(observer: observer)
		let dataTask = session.dataTaskWithRequest(request: request) { [weak self] data, _, _ in
			guard let data = data, let image = UIImage(data: data) else {
				observer.notify(.failure(.dataCorrupted))
				return
			}
			observer.notify(.success(image))
			self?.pendingRequests[request] = .finished(image: image)
		}
		let subscriber = Subscriber(uuid: uuid, handler: completion, dataTask: dataTask)
		observer.subscribe(subscriber: subscriber)
		dataTask.resume()
		return uuid
	}

	public func removeTask(with uuid: UUID) {
		for pendingRequest in pendingRequests.values {
			guard
				case .inProgress(let observer) = pendingRequest, observer.handlers[uuid] != nil
			else { continue }
			observer.unsubscribe(uuid: uuid)
			break
		}
	}
}

