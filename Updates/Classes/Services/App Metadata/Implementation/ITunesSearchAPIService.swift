//
//  ITunesSearchAPIService.swift
//  Updates
//
//  Created by Ross Butler on 09/04/2020.
//

import Foundation

struct ITunesSearchAPIService: AppMetadataService {

    /// URL for invocation of iTunes Search API.
    private let iTunesSearchAPIURL: URL

    /// Parses iTunes Search API responses.
    private let parsingService = ITunesSearchJSONParsingService()

    init?(bundleIdentifier: String, countryCode: String) {
        let lowercasedCountryCode = countryCode.lowercased()
        let urlString = "http://itunes.apple.com/lookup?bundleId=\(bundleIdentifier)&country=\(lowercasedCountryCode)"
        guard let url = URL(string: urlString) else {
            return nil
        }
        self.iTunesSearchAPIURL = url
    }

    /// Parses data returned by the iTunes Search API.
    private func parseConfiguration(data: Data) -> ParsingServiceResult? {
        switch parsingService.parse(data) {
        case .success(let result):
            return result
        case .failure:
            return nil
        }
    }

    func fetchAppMetadata(_ completion: @escaping (AppMetadataResult) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let apiData = try? Data(contentsOf: self.iTunesSearchAPIURL) else {
                onMainQueue(completion)(.failure(.emptyPayload))
                return
            }
            let parsingResult = self.parsingService.parse(apiData)
            onMainQueue(completion)(parsingResult)
        }
    }
}
