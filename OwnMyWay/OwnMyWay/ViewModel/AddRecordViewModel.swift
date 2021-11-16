//
//  AddRecordViewModel.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import Foundation

protocol AddRecordViewModel {
    func didEnterTitle(text: String?)
    // TODO: Photo 들어왔을 때 처리 함수 추가
}

protocol AddRecordCoordinatingDelegate: AnyObject {
    func dismissToParent(with record: Record)
}

class DefaultAddRecordViewModel: AddRecordViewModel {

    private var record: Record?
    private let usecase: AddRecordUsecase
    private weak var coordinatingDelegate: AddRecordCoordinatingDelegate?

    @Published private var validateResult: Bool?

    private var recordTitle: String?
    private var recordDate: Date?
    private var recordCoordinate: (Double, Double)?
    private var recordPlace: String?
    private var recordContent: String?
    private var recordPhotos: [URL] = []
    private var isValidTitle: Bool = false {
        didSet {
            self.checkValidation()
        }
    }
    private var isValidDate: Bool = false {
        didSet {
            self.checkValidation()
        }
    }
    private var isValidCoordinate: Bool = false {
        didSet {
            self.checkValidation()
        }
    }
    private var isValidPlace: Bool = false {
        didSet {
            self.checkValidation()
        }
    }
    private var isValidPhotos: Bool = false {
        didSet {
            self.checkValidation()
        }
    }

    init(
        record: Record?,
        usecase: AddRecordUsecase,
        coordinatingDelegate: AddRecordCoordinatingDelegate
    ) {
        self.record = record
        self.usecase = usecase
        self.coordinatingDelegate = coordinatingDelegate
    }

    func didEnterTitle(text: String?) {
        // TODO: 1~20자 사이일 경우 vaild
    }

    private func checkValidation() {
        validateResult
        = isValidTitle && isValidDate && isValidCoordinate && isValidPlace && isValidPhotos
    }
}
