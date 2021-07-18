import XCTest
import Combine

@testable import VolonbolonKit

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            XCTFail("Received unexpected request with no handler set")
            return
        }
        do {
            let (response, data) = try handler(request)
            guard 200...299 ~= response.statusCode else {
                let error = URLError(URLError.Code(rawValue: response.statusCode))
                client?.urlProtocol(self, didFailWithError: error)
                return
            }
            client?.urlProtocol(self,
                                didReceive: response,
                                cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

final class VolonbolonKitTests: XCTestCase {
    var subscriptions = [AnyCancellable]()
    var url: URL!
    var session: URLSession!
    
    override func setUp() {
        self.url = URLBuilder()
            .set(scheme: "https")
            .set(host: "localhost")
            .set(path: "path")
            .build()!
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        self.session = URLSession(configuration: configuration)
    }
    
    func testData() {
        let expectation = XCTestExpectation(description: "Expect loading data")

        let msg = "Hello World"
        MockURLProtocol.requestHandler = { request in
            let mockData = "{\"msg\": \"\(msg)\"}".data(using: .utf8)!
            let respose = HTTPURLResponse(url: request.url!,
                                          statusCode: 200,
                                          httpVersion: "HTTP/1.1",
                                          headerFields: ["Content-type": "application/json"])!
            return (respose, mockData)
        }
                
        session.get(from: url)
            .sink(receiveCompletion: { _ in expectation.fulfill() },
                  receiveValue: { data in
                    do {
                        let payload = try JSONDecoder().decode([String: String].self, from: data)
                        XCTAssertEqual(payload["msg"], msg, "\(msg) should be equal to 'Hello World'")
                    } catch {
                        XCTFail("Unable to parse response")
                        return
                    }
                  })
            .store(in: &subscriptions)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testError() {
        let expectation = XCTestExpectation(description: "Expect loading Error")
        
        MockURLProtocol.requestHandler = { request in
            let mockData = Data()
            let respose = HTTPURLResponse(url: request.url!,
                                          statusCode: 403,
                                          httpVersion: "HTTP/1.1",
                                          headerFields: ["Content-type": "application/json"])!
            return (respose, mockData)
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

        wait(for: [expectation], timeout: 1)
    }

    static var allTests = [
        ("testData", testData),
        ("testError", testError),
    ]
}
