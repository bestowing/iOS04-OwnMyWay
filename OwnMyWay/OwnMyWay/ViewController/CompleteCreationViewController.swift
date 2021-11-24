//
//  CompleteCreationViewController.swift
//  OwnMyWay
//
//  Created by 이청수 on 2021/11/09.
//

import Combine
import UIKit

class CompleteCreationViewController: UIViewController, Instantiable {

    @IBOutlet private weak var nextButtonHeightConstraint: NSLayoutConstraint!

    private var viewModel: CompleteCreationViewModel?
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCancellables()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.configureButtonConstraint()
    }

    func bind(viewModel: CompleteCreationViewModel) {
        self.viewModel = viewModel
    }

    private func configureCancellables() {
        self.viewModel?.errorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] optionalError in
                guard let error = optionalError else { return }
                ErrorManager.showAlert(with: error, to: self)
            }
            .store(in: &self.cancellables)
    }

    private func configureButtonConstraint() {
        let bottomPadding = self.view.safeAreaInsets.bottom
        self.nextButtonHeightConstraint.constant = 60 + bottomPadding
    }

    @IBAction func didTouchCompleteButton(_ sender: UIButton) {
        self.viewModel?.didTouchCompleteButton()
    }

}
