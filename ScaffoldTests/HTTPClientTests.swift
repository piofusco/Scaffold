//
//  ScaffoldTests.swift
//  ScaffoldTests
//
//  Created by Michael Pace on 4/23/23.
//

import XCTest

@testable import Scaffold

final class HTTPClientTests: XCTestCase {
    var subject: DefaultHTTPClient!

    var mockURLSession: MockURLSession!
    var mockJSONDecoder: MockJSONDecoder<GiphySearchResultImage>!
    var mockJSONEncoder: MockJSONEncoder<EncodableExample>!

    override func setUp() {
        super.setUp()

        mockURLSession = MockURLSession()
        mockJSONDecoder = MockJSONDecoder()
        mockJSONEncoder = MockJSONEncoder()

        subject = DefaultHTTPClient(
            urlSession: mockURLSession,
            decoder: mockJSONDecoder,
            encoder: mockJSONEncoder
        )
    }

    func test_get_badURL_failure() async throws {
        var lastError: Error?
        let result: Result<GiphySearchResultImage, Error> = await subject.get("i am not a url pls no")

        switch result {
        case .success(_): XCTFail("Should not fail")
        case .failure(let error): lastError = error
        }
        guard let lastError = lastError as? NetworkError else {
            XCTFail("Error not set.")
            return
        }
        XCTAssertEqual(lastError, NetworkError.badURL)
        XCTAssertTrue(mockURLSession.lastURLRequests.isEmpty)
        XCTAssertEqual(mockJSONDecoder.decodeInvocations, 0)
    }

    func test_get_400_failure() async throws {
        mockURLSession.nextResults = [("some data".data(using: .utf16)!, url400Response)]
        var lastError: Error?

        let result: Result<GiphySearchResultImage, Error> = await subject.get(GiphyURL.search.urlString)

        switch result {
        case .success(_): XCTFail("Should not succeed")
        case .failure(let error): lastError = error
        }
        guard let lastError = lastError as? NetworkError else {
            XCTFail("Error not set.")
            return
        }
        XCTAssertEqual(lastError, NetworkError.badRequest)
        let lastURLRequest = mockURLSession.lastURLRequests[0]
        XCTAssertEqual(lastURLRequest.url?.path, "/v1/gifs/search")
        XCTAssertEqual(lastURLRequest.httpMethod, "GET")
        XCTAssertEqual(mockJSONDecoder.decodeInvocations, 0)
    }

    func test_get_500_failure() async throws {
        mockURLSession.nextResults = [("some data".data(using: .utf16)!, url500Response)]
        var lastError: Error?

        let result: Result<GiphySearchResultImage, Error> = await subject.get(GiphyURL.search.urlString)

        switch result {
        case .success(_): XCTFail("Should not succeed")
        case .failure(let error): lastError = error
        }
        guard let lastError = lastError as? NetworkError else {
            XCTFail("Error not set.")
            return
        }
        XCTAssertEqual(lastError, NetworkError.internalServerError)
        let lastURLRequest = mockURLSession.lastURLRequests[0]
        XCTAssertEqual(lastURLRequest.url?.path, "/v1/gifs/search")
        XCTAssertEqual(lastURLRequest.httpMethod, "GET")
        XCTAssertEqual(mockJSONDecoder.decodeInvocations, 0)
    }

    func test_get_200_decodingFails_failure() async throws {
        mockURLSession.nextResults = [(invalidJSON, url200Response)]
        var lastError: Error?

        let result: Result<GiphySearchResultImage, Error> = await subject.get(GiphyURL.search.urlString)

        switch result {
        case .success(_): XCTFail("Should not succeed")
        case .failure(let error): lastError = error
        }
        guard let lastError = lastError as? NetworkError else {
            XCTFail("Error not set.")
            return
        }
        XCTAssertEqual(lastError, NetworkError.invalidJSON)
        let lastURLRequest = mockURLSession.lastURLRequests[0]
        XCTAssertEqual(lastURLRequest.url?.path, "/v1/gifs/search")
        XCTAssertEqual(lastURLRequest.httpMethod, "GET")
        XCTAssertEqual(mockJSONDecoder.decodeInvocations, 1)
    }

    func test_get_200_returnsDecodable_success() async throws {
        mockURLSession.nextResults = [("".data(using: .utf16)!, url200Response)]
        mockJSONDecoder.nextDecodable = GiphySearchResultImage(url: URL(string: "www.whatever.com")!)

        let result: Result<GiphySearchResultImage, Error> = await subject.get(
            GiphyURL.search.urlString,
            ["flooring": "marble"]
        )

        switch result {
        case .success(let decoded): XCTAssertNotNil(decoded)
        case .failure(_): XCTFail("Should not fail")
        }
        let lastURLRequest = mockURLSession.lastURLRequests[0]
        XCTAssertEqual(lastURLRequest.url?.path, "/v1/gifs/search")
        guard let query = lastURLRequest.url?.query else {
            XCTFail("Query parameters were not added")
            return
        }
        XCTAssertTrue(query.contains("flooring=marble"))
        XCTAssertEqual(lastURLRequest.httpMethod, "GET")
        XCTAssertEqual(mockJSONDecoder.decodeInvocations, 1)
    }

    func test_post_badURL_failure() async throws {
        var lastError: Error?
        let result: Result<GiphySearchResultImage, Error> = await subject.post("i am not a url pls no")

        switch result {
        case .success(_): XCTFail("Should not succeed")
        case .failure(let error): lastError = error
        }
        XCTAssertNotNil(lastError)
        XCTAssertTrue(mockURLSession.lastURLRequests.isEmpty)
        XCTAssertEqual(mockJSONEncoder.encodeInvocations, 0)
    }

    func test_post_nilBody_failure() async throws {
        var lastError: Error?
        let result: Result<GiphySearchResultImage, Error> = await subject.post(
            "i am not a url pls no",
            [:],
            nil
        )

        switch result {
        case .success(_): XCTFail("Should not succeed")
        case .failure(let error): lastError = error
        }
        XCTAssertNotNil(lastError)
        XCTAssertTrue(mockURLSession.lastURLRequests.isEmpty)
        XCTAssertEqual(mockJSONEncoder.encodeInvocations, 0)
    }

    func test_post_encodingFails_failure() async throws {
        mockJSONEncoder.nextData = nil
        var lastError: Error?

        let result: Result<GiphySearchResultImage, Error> = await subject.post(
            GiphyURL.search.urlString,
            [:],
            EncodableExample(name: "billy bob")
        )

        switch result {
        case .success(_): XCTFail("Should not succeed")
        case .failure(let error): lastError = error
        }
        XCTAssertNotNil(lastError)
        XCTAssertEqual(mockJSONEncoder.encodeInvocations, 1)
        XCTAssertTrue(mockURLSession.lastURLRequests.isEmpty)
    }

    func test_post_400_failure() async throws {
        mockJSONEncoder.nextData = validJSON
        mockURLSession.nextResults = [("".data(using: .utf16)!, url400Response)]
        var lastError: Error?

        let result: Result<GiphySearchResultImage, Error> = await subject.post(
            GiphyURL.search.urlString,
            [:],
            EncodableExample(name: "billy bob")
        )

        switch result {
        case .success(_): XCTFail("Should not succeed")
        case .failure(let error): lastError = error
        }
        guard let lastError = lastError as? NetworkError else {
            XCTFail("Error not set.")
            return
        }
        XCTAssertEqual(lastError, NetworkError.badRequest)
        XCTAssertEqual(mockJSONEncoder.encodeInvocations, 1)
        let lastURLRequest = mockURLSession.lastURLRequests[0]
        XCTAssertEqual(lastURLRequest.url?.path, "/v1/gifs/search")
        XCTAssertEqual(lastURLRequest.httpMethod, "POST")
    }

    func test_post_500_failure() async throws {
        mockJSONEncoder.nextData = validJSON
        mockURLSession.nextResults = [("".data(using: .utf16)!, url500Response)]
        var lastError: Error?

        let result: Result<GiphySearchResultImage, Error> = await subject.post(
            GiphyURL.search.urlString,
            [:],
            EncodableExample(name: "billy bob")
        )

        switch result {
        case .success(_): XCTFail("Should not succeed")
        case .failure(let error): lastError = error
        }
        guard let lastError = lastError as? NetworkError else {
            XCTFail("Error not set.")
            return
        }
        XCTAssertEqual(lastError, NetworkError.internalServerError)
        XCTAssertEqual(mockJSONEncoder.encodeInvocations, 1)
        let lastURLRequest = mockURLSession.lastURLRequests[0]
        XCTAssertEqual(lastURLRequest.url?.path, "/v1/gifs/search")
        XCTAssertEqual(lastURLRequest.httpMethod, "POST")
    }

    func test_post_200_returnsDecodable_success() async throws {
        mockJSONEncoder.nextData = validJSON
        mockURLSession.nextResults = [("".data(using: .utf16)!, url200Response)]
        mockJSONDecoder.nextDecodable = GiphySearchResultImage(url: URL(string: "www.whatever.com")!)

        let result: Result<GiphySearchResultImage, Error> = await subject.post(
            GiphyURL.search.urlString,
            ["flooring":"marble"],
            EncodableExample(name: "billy bob")
        )

        switch result {
        case .success(let decoded): XCTAssertNotNil(decoded)
        case .failure(_): XCTFail("Should not fail")
        }
        XCTAssertEqual(mockJSONEncoder.encodeInvocations, 1)
        let lastURLRequest = mockURLSession.lastURLRequests[0]
        XCTAssertEqual(lastURLRequest.url?.path, "/v1/gifs/search")
        guard let query = lastURLRequest.url?.query else {
            XCTFail("Query parameters were not added")
            return
        }
        XCTAssertTrue(query.contains("flooring=marble"))
        XCTAssertEqual(lastURLRequest.httpMethod, "POST")
        XCTAssertEqual(lastURLRequest.httpBody, validJSON)
        XCTAssertEqual(mockJSONDecoder.decodeInvocations, 1)
    }
}

struct EncodableExample: Encodable {
    let name: String
}

fileprivate let validJSON = "{}".data(using: .utf8)!
fileprivate let invalidJSON = "lol good lucky{".data(using: .utf8)!
fileprivate let url200Response: URLResponse = HTTPURLResponse(
    url: URL(string: "www.not.matter")!,
    statusCode: 200,
    httpVersion: nil,
    headerFields: [:]
)!

fileprivate let url400Response: URLResponse = HTTPURLResponse(
    url: URL(string: "www.not.matter")!,
    statusCode: 400,
    httpVersion: nil,
    headerFields: [:]
)!

fileprivate let url500Response: URLResponse = HTTPURLResponse(
    url: URL(string: "www.not.matter")!,
    statusCode: 500,
    httpVersion: nil,
    headerFields: [:]
)!
