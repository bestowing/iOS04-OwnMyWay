//
//  DetailRecordUsecase.swift
//  OwnMyWay
//
//  Created by 유한준 on 2021/11/10.
//

import Foundation

protocol DetailRecordUsecase {

}

struct DefaultDetailRecordUsecase: DetailRecordUsecase {

    private let repository: TravelRepository

    init(repository: TravelRepository) {
        self.repository = repository
    }

}