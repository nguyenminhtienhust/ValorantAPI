import XCTest
import HandyOperators
import ArrayBuilder

/// Verifies that the given block causes requests in the given order. Make sure that all communication runs via ``verifyingURLSession``.
func testCommunication<T>(
	running block: () async throws -> T,
	@ArrayBuilder<ExpectedRequest> expecting order: () throws -> [ExpectedRequest]
) async rethrows -> T {
	verifier = .init(expecting: try order())
	defer { verifier.finalize() }
	
	return try await block()
}

/// A URLSession tht uses a request verifier to verify incoming requests and provide mock responses.
let verifyingURLSession = URLSession(
	configuration: .ephemeral <- {
		$0.protocolClasses!.insert(VerifyingProtocol.self, at: 0)
	}
)

private var verifier: RequestVerifier!

private final class RequestVerifier {
	var expectedOrder: [ExpectedRequest]
	var currentPosition = 0
	
	init(expecting expectedOrder: [ExpectedRequest]) {
		self.expectedOrder = expectedOrder
	}
	
	func next() -> ExpectedRequest {
		defer { currentPosition += 1 }
		XCTAssert(currentPosition < expectedOrder.endIndex, "Too many requests sent!")
		return expectedOrder[currentPosition < expectedOrder.endIndex ? currentPosition : 0]
	}
	
	func finalize() {
		XCTAssertEqual(
			currentPosition, expectedOrder.endIndex,
			"Not all expected requests were executed!"
		)
	}
}

private final class VerifyingProtocol: URLProtocol {
	override class func canInit(with request: URLRequest) -> Bool { true }
	
	override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
	
	let expected = verifier.next()
	
	override func startLoading() {
		print("\texpecting \(expected)")
		
		XCTAssertEqual(request.url!, expected.url)
		XCTAssertEqual(request.httpMethod!, expected.method)
		
		if let expectedBody = expected.requestBody {
			let actualBody = request.httpBody ?? Data(reading: request.httpBodyStream!)
			XCTAssertEqual(actualBody.utf8String(), expectedBody.utf8String())
		}
		
		let response = HTTPURLResponse(
			url: expected.url,
			statusCode: expected.responseCode,
			httpVersion: nil,
			headerFields: nil
		)!
		
		client!.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
		if let body = expected.responseBody {
			client!.urlProtocol(self, didLoad: body)
		}
		client!.urlProtocolDidFinishLoading(self)
	}
	
	override func stopLoading() {}
}

private extension Data {
	func utf8String() -> String {
		String(bytes: self, encoding: .utf8)!
	}
	
	// why this isn't included is beyond me
	init(reading stream: InputStream) {
		self.init()
		
		stream.open()
		defer { stream.close() }
		
		let bufferSize = 1024
		let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
		defer { buffer.deallocate() }
		
		while stream.hasBytesAvailable {
			let bytesRead = stream.read(buffer, maxLength: bufferSize)
			append(buffer, count: bytesRead)
		}
	}
}
