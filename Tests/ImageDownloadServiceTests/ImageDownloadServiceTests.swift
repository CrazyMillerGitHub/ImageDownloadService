import XCTest
@testable import ImageDownloadService

final class ImageDownloadServiceTests: XCTestCase {

	private var session: URLSessionStub!

	override func setUp() {
		super.setUp()
		session = URLSessionStub()
	}

	override func tearDown() {
		session = nil
		super.tearDown()
	}

	func test_dowload_getValidResponse_shouldReturnImage() throws {
		// arrange
		let givenImage = UIImage(data: try XCTUnwrap(UIImage(systemName: "return")?.pngData()))
		let request = URLRequest(url: try XCTUnwrap(URL(string: "google.com")))
		let expectation = XCTestExpectation(description: "expectation")
		let sut = ImageDownloadService(session: session)
		var result: Result<UIImage, ImageDownloadError>?
		session.stubbedResult = (givenImage?.pngData(), nil, nil)

		// act
		_ = sut.download(with: request) { response in
			result = response
			expectation.fulfill()
		}

		// assert
		wait(for: [expectation], timeout: 1)
		guard case .success(let resultImage) = result else {
			XCTFail("Image cannot be nil")
			return
		}
		XCTAssertEqual(resultImage.pngData(), givenImage?.pngData())
	}

	func test_dowload_getInvalidData_shouldReturnFailure() throws {
		// arrange
		let request = URLRequest(url: try XCTUnwrap(URL(string: "google.com")))
		let expectation = XCTestExpectation(description: "expectation")
		let sut = ImageDownloadService(session: session)
		var result: Result<UIImage, ImageDownloadError>?
		session.stubbedResult = (nil, nil, nil)

		// act
		_ = sut.download(with: request) { response in
			result = response
			expectation.fulfill()
		}

		// assert
		wait(for: [expectation], timeout: 1)
		guard case .failure(let error) = result else {
			XCTFail("Image cannot be nil")
			return
		}
		XCTAssertEqual(error, .dataCorrupted)
	}

	func test_dowload_getThreeIdenticalRequest_shouldRaiseOneRequest() throws {
		// arrange
		let request = URLRequest(url: try XCTUnwrap(URL(string: "google.com")))
		let expectation = XCTestExpectation(description: "expectation")
		let sut = ImageDownloadService(session: session)
		var resultCount = 0
		let dispatchGroup = DispatchGroup()
		let lock = NSRecursiveLock()
		session.stubbedResult = (nil, nil, nil)

		// act
		for _ in 0..<3 {
			dispatchGroup.enter()
			_ = sut.download(with: request) { response in
				lock.lock()
				resultCount += 1
				lock.unlock()
				dispatchGroup.leave()
			}
		}
		dispatchGroup.notify(queue: .main) {
			expectation.fulfill()
		}

		// assert
		wait(for: [expectation], timeout: 1.5)
		XCTAssertEqual(session.dataTask.resumeCalledCount, 1)
		XCTAssertEqual(resultCount, 3)
	}
}
