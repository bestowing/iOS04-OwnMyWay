//
//  AddRecordViewController.swift
//  OwnMyWay
//
//  Created by 강현준 on 2021/11/10.
//

import Combine
import UIKit
import PhotosUI

let supportedPhotoExtensions = [
    UTType.rawImage.identifier,
    UTType.tiff.identifier,
    UTType.bmp.identifier,
    UTType.png.identifier,
    UTType.heif.identifier,
    UTType.heic.identifier,
    UTType.jpeg.identifier,
    UTType.webP.identifier,
    UTType.gif.identifier
]

class AddRecordViewController: UIViewController, Instantiable {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var photoCollectionView: UICollectionView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var contentTextField: UITextField!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var locationButton: UIButton!

    private var viewModel: AddRecordViewModel?
    private var dataSource: [URL] = []
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureGestureRecognizer()
        self.configureNotifications()
        self.configureNibs()
        self.configurePhotoCollectionView()
        self.configureNavigation()
        self.configureCancellable()
        self.configureModelValue()
    }

    func bind(viewModel: AddRecordViewModel) {
        self.viewModel = viewModel
    }

    private func configureNibs() {
        self.photoCollectionView.register(
            UINib(nibName: PhotoCell.identifier, bundle: nil),
            forCellWithReuseIdentifier: PhotoCell.identifier
        )
    }

    private func configurePhotoCollectionView() {
        self.photoCollectionView.delegate = self
        self.photoCollectionView.dataSource = self
    }

    private func configureNavigation() {
        self.navigationItem.title = "게시물 작성"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "완료",
            style: .plain,
            target: self,
            action: #selector(submitButtonAction)
        )
    }

    private func configureCancellable() {
        self.viewModel?.validatePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                self?.navigationItem.rightBarButtonItem?.isEnabled = isValid ?? false
            }
            .store(in: &cancellables)

        self.viewModel?.photoPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] photos in
                self?.dataSource = photos
                self?.photoCollectionView.reloadData()
            }
            .store(in: &cancellables)

        self.viewModel?.placePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] place in
                self?.locationButton.setTitle(place, for: .normal)
            }
            .store(in: &cancellables)

        self.viewModel?.datePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] date in
                if let date = date {
                    self?.datePicker.date = date
                }
            }
            .store(in: &cancellables)
    }

    private func configureModelValue() {
        self.viewModel?.viewDidLoad { [weak self] record in
            self?.titleTextField.text = record.title
            self?.datePicker.date = record.date ?? Date()
            self?.contentTextField.text = record.content
            self?.locationButton.setTitle(record.placeDescription, for: .normal)
        }
    }

    @objc private func submitButtonAction() {
        self.viewModel?.didTouchSubmitButton()
    }

    @IBAction func didChangeTitle(_ sender: UITextField) {
        self.viewModel?.didEnterTitle(with: sender.text)
    }

    @IBAction func didChangeContent(_ sender: UITextField) {
        self.viewModel?.didEnterContent(with: sender.text)
    }

    @IBAction func didChangeDate(_ sender: UIDatePicker) {
        self.viewModel?.didEnterTime(with: sender.date)
    }
}

extension AddRecordViewController {
    private func configureGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }

    private func configureNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowAction(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHideAction(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func deleteNotifications() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func tapAction(_ gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    @objc private func keyboardWillShowAction(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        self.scrollView.contentInset.bottom = keyboardFrame.size.height
        let firstResponder = self.view.firstResponder
        if let textView = firstResponder as? UITextField {
            self.scrollView.scrollRectToVisible(textView.frame, animated: true)
        }
    }

    @objc private func keyboardWillHideAction(_ notification: Notification) {
        let zeroInset = UIEdgeInsets.zero
        self.scrollView.contentInset = zeroInset
        self.scrollView.scrollIndicatorInsets = zeroInset
    }
}

extension AddRecordViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView, numberOfItemsInSection section: Int
    ) -> Int {
        return self.dataSource.count
    }

    func collectionView(
        _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCell.identifier, for: indexPath
        ) as? PhotoCell
        else { return UICollectionViewCell() }
        cell.configure(url: self.dataSource[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            self.openPicker()
        }
    }

}

extension AddRecordViewController: PHPickerViewControllerDelegate {

    func openPicker() {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selectionLimit = 0
        config.filter = PHPickerFilter.images

        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        self.present(pickerViewController, animated: true, completion: nil)
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty else {
          dismiss(animated: true, completion: nil)
          return
        }
        results.forEach { [weak self] result in
            guard let assetId = result.assetIdentifier else { return }
            let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
            let date = assetResults.firstObject?.creationDate ?? Date()
            self?.viewModel?.didEnterTime(with: date)
            self?.viewModel?.didEnterCoordinate(
                latitude: assetResults.firstObject?.location?.coordinate.latitude.magnitude,
                longitude: assetResults.firstObject?.location?.coordinate.longitude.magnitude
            )
            for type in supportedPhotoExtensions {
                if result.itemProvider.hasRepresentationConforming(toTypeIdentifier: type, fileOptions: .init()) {
                    result.itemProvider.loadFileRepresentation(forTypeIdentifier: type) { url, error in
                        guard error == nil,
                              let url = url else { return }
                        self?.viewModel?.didEnterPhotoURL(with: url)
                    }
                    break
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }

}

// MARK: - fileprivate extension for UIView

fileprivate extension UIView {
    var firstResponder: UIView? {
        guard !self.isFirstResponder else { return self }
        for subview in subviews {
            if let firstResponder = subview.firstResponder { return firstResponder }
        }
        return nil
    }
}
