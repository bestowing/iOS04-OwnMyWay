//
//  SearchLandmarkViewModel.swift
//  OwnMyWay
//
//  Created by 김우재 on 2021/11/03.
//

import Combine
import Foundation

protocol SearchLandmarkViewModelType {
    var landmarks: [Landmark] { get }
    var landmarksPublisher: Published<[Landmark]>.Publisher { get }
    var searchText: String { get set }
    func configure()
    func didEnterSearchText(text: String)
    func landmarkCardDidTouched(index: Int)
}

protocol SearchLandmarkCoordinatingDelegate: AnyObject {
    func dismissToAddLandmark(landmark: Landmark)
}

class SearchLandmarkViewModel: SearchLandmarkViewModelType, ObservableObject {
    @Published var landmarks: [Landmark]
    @Published var searchText: String
    var landmarksPublisher: Published<[Landmark]>.Publisher { $landmarks }
    var cancellable: AnyCancellable?

    private let searchLandmarkUsecase: SearchLandmarkUsecase
    private weak var coordinator: SearchLandmarkCoordinatingDelegate?

    init(
        searchLandmarkUsecase: SearchLandmarkUsecase,
        coordinator: SearchLandmarkCoordinatingDelegate
    ) {
        self.coordinator = coordinator
        self.landmarks = []
        self.searchLandmarkUsecase = searchLandmarkUsecase
        self.searchText = ""
        self.cancellable = self.$searchText
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .sink { [weak self] searchText in
                self?.didEnterSearchText(text: searchText)
            }
    }

    func configure() {
        searchLandmarkUsecase.executeFetch { [weak self] landmarks in
            self?.landmarks = landmarks
        }
    }

    func didEnterSearchText(text: String) {
        if text == "" {
            configure()
        } else {
            searchLandmarkUsecase.executeSearch(searchText: text) { [weak self] searchResult in
                self?.landmarks = searchResult
            }
        }
    }

    func landmarkCardDidTouched(index: Int) {
        guard landmarks.startIndex..<landmarks.endIndex ~= index else { return }
        self.coordinator?.dismissToAddLandmark(landmark: landmarks[index])
    }
}
