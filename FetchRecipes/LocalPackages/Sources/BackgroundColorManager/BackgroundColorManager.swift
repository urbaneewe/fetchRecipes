//
//  BackgroundColorManager.swift
//  
//
//  Created by Mihajlo Saric on 7.10.24..
//

import Combine
import Extensions
import Observation
import SwiftUI

@Observable
public class BackgroundColorManager {
    public var backgroundColor: Color = .clear
    private var colorCache = [String: Color]()
    private var cancellables = Set<AnyCancellable>()

    public init() {}

    public func updateBackgroundColor(for imageUrl: String?, geometry: GeometryProxy) {
        let screenHeight = UIScreen.main.bounds.height
        let imagePosition = geometry.frame(in: .global).midY

        guard let urlString = imageUrl,
            let url = URL(string: urlString)
        else { return }

        // Check if the image is centered
        if abs(imagePosition - screenHeight / 2) < 100 {
            if let cachedColor = colorCache[urlString] {
                backgroundColor = cachedColor
                return
            }

            URLSession.shared.dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data)?.findAverageColor(algorithm: .simple) }
                .compactMap { $0 }
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("Error fetching image: \(error)")
                    }
                } receiveValue: { [weak self] dominantUIColor in
                    let color = Color(dominantUIColor)
                    self?.colorCache[urlString] = color
                    self?.backgroundColor = color
                }
                .store(in: &cancellables)
        }
    }
}
