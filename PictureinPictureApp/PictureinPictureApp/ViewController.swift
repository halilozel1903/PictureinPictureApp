//
//  ViewController.swift
//  PictureinPictureApp
//
//  Created by macbookpro on 12.06.2019.
//  Copyright © 2019 halilozel. All rights reserved.
//

import AVFoundation
import AVKit
import UIKit

final class ViewController: UIViewController, AVPlayerViewControllerDelegate {
    private var playerViewController: AVPlayerViewController?
    private var observedPlayerItem: AVPlayerItem?

    deinit {
        removePlayerDidFinishObserver()
    }

    @IBAction private func play(_ sender: Any) {
        guard let videoURL = Bundle.main.url(forResource: "Apple", withExtension: "mp4") else {
            showAlert(title: "Video unavailable", message: "Apple.mp4 could not be found in the app bundle.")
            return
        }

        removePlayerDidFinishObserver()

        let player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.delegate = self
        playerViewController.allowsPictureInPicturePlayback = AVPictureInPictureController.isPictureInPictureSupported()
        playerViewController.canStartPictureInPictureAutomaticallyFromInline = true

        observedPlayerItem = player.currentItem
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFinishPlayingNotification(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )

        self.playerViewController = playerViewController

        present(playerViewController, animated: true) {
            player.play()
        }
    }

    func playerViewController(
        _ playerViewController: AVPlayerViewController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        guard presentedViewController !== playerViewController else {
            completionHandler(true)
            return
        }

        let presenter = navigationController?.visibleViewController ?? self
        presenter.present(playerViewController, animated: true) {
            completionHandler(true)
        }
    }

    @objc private func didFinishPlayingNotification(_ notification: Notification) {
        didFinishPlaying()
    }

    private func didFinishPlaying() {
        removePlayerDidFinishObserver()

        playerViewController?.dismiss(animated: true) { [weak self] in
            self?.showAlert(title: "Finished", message: "Video finished")
        }
        playerViewController = nil
    }

    private func removePlayerDidFinishObserver() {
        guard let observedPlayerItem else { return }

        NotificationCenter.default.removeObserver(
            self,
            name: .AVPlayerItemDidPlayToEndTime,
            object: observedPlayerItem
        )
        self.observedPlayerItem = nil
    }

    private func showAlert(title: String, message: String) {
        guard presentedViewController == nil else { return }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
