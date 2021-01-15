import XCTest
import Combine

@testable import VolonbolonKit

class NetworkSessionMock: NetworkSession {
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    func get(from url: URL) -> AnyPublisher<Data, URLError> {
        return Just(data)
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
    
    func post(with request: URLRequest) -> AnyPublisher<Data, URLError> {
        return Empty<Data, URLError>()
            .eraseToAnyPublisher()
    }
}

class NetworkSessionMockError: NetworkSession {
    let error: URLError
    
    init(error: URLError) {
        self.error = error
    }
    
    func get(from url: URL) -> AnyPublisher<Data, URLError> {
        return Fail<Data, URLError>(error: error)
            .eraseToAnyPublisher()
    }
    
    func post(with request: URLRequest) -> AnyPublisher<Data, URLError> {
        return Empty<Data, URLError>()
            .eraseToAnyPublisher()
    }
}

final class VolonbolonKitTests: XCTestCase {
    var subscriptions = [AnyCancellable]()
    
    func testData() {
        let expectation = XCTestExpectation(description: "Expect loading data")
        let msg = "Hello"
        guard let url = URL(string: "http://localhost/"),
              let data = msg.data(using: .utf8) else {
            fatalError("Unable to get a URL")
        }
        
        let session = NetworkSessionMock(data: data)
        
        session.get(from: url)
            .sink(receiveCompletion: { _ in expectation.fulfill() },
                  receiveValue: { data in
                    guard let str = String(data: data, encoding: .utf8) else {
                        fatalError("Unable to retreive a string from data")
                    }
                    XCTAssertEqual(str, msg, "\(str) should be equal to \(msg)")
                  })
            .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 30)
    }
    
    func testError() {
        let expectation = XCTestExpectation(description: "Expect loading Error")
        let error = URLError(URLError.Code(rawValue: 403))
        let session = NetworkSessionMockError(error: error)
        
        guard let url = URL(string: "http://localhost/") else {
            fatalError("Unable to get a URL")
        }
        
        session.get(from: url)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error.errorCode, 403, "Error code \(error.errorCode) should be 403")
                default:
                    XCTFail("An error should be triggered")
                }
                expectation.fulfill()
            },
                  receiveValue: { print($0) })
            .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 30)
    }

    static var allTests = [
        ("testData", testData),
        ("testError", testError),
    ]
}
