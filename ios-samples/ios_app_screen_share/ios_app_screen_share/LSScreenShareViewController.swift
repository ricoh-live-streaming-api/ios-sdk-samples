/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import UIKit
import client_sdk
import WebRTC
import ReplayKit

class LSScreenShareViewController: UIViewController {

    @IBOutlet weak var localTestView: UIView!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var remoteScrollView: UIScrollView!
    @IBOutlet weak var apiMenuButton: UIButton!
    
    @IBOutlet weak var audioSegmentedControl: UISegmentedControl!
    @IBOutlet weak var videoSegmentedControl: UISegmentedControl!
    
    private let logger = AppLogger.shared
    
    private var client: Client?
    private var localLSTracks: [LSTrack] = []
    private var videoCapturer: PixelBufferCapturer?
    
    private var remoteTracks: [Dictionary<String, RTCVideoTrack?>] = []
    private var remoteViewList: [UIView] = []
    
    private var statsTimer: Timer?
    
    private enum UIStateMode {
        case Init
        case Connected
        case Disconnected
    }
    
    var videoTrack: RTCVideoTrack?
    
    private var broadcastPickerView: RPSystemBroadcastPickerView = RPSystemBroadcastPickerView()
    private let fileManager = MappedFileManager()
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupApiMenuButton()
        changeUiState(state: .Init)
        
        self.broadcastPickerView.preferredExtension = "com.ricoh.livestreaming.app.ios-app-screen-share.ios-app-screen-share-extension"
        self.broadcastPickerView.showsMicrophoneButton = false
        self.view.addSubview(self.broadcastPickerView)
    }

    @IBAction func tapConncectButton(_ sender: Any) {
        do {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let baseDirPath = paths.first
            let logsDirectory = baseDirPath?.appending("/logs")
            let clientLogOption = ClientLogOption(logDirPath: logsDirectory!, filePrefix: "client", maxFileSizeMb: 1, maxFileCount: 5, logLevel: .Debug)
            client = Client(clientLogOption: clientLogOption)
            client?.delegate = self
            
            let pathsLibwebrtc = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let baseDirPathLibwebrtc = pathsLibwebrtc.first
            let logsDirectoryLibwebrtc = baseDirPathLibwebrtc?.appending("/libwebrtc")
            
            saveLog(prefix: "webrtc", path: logsDirectoryLibwebrtc!)
            saveLog(prefix: "client", path: logsDirectory!)
            saveLog(prefix: "app", path: logger.getLogDir())
            
            try client?.setLibWebrtcLogOption(option: LibWebrtcLogOption(path: logsDirectoryLibwebrtc!, maxTotalFileSize: 4, logLevel: .VERBOSE))
            
            
            videoCapturer = PixelBufferCapturer()
            let constraints = MediaStreamConstraints(videoCapturer: videoCapturer, audio: true)
            let stream = try client?.getUserMedia(constraints: constraints)
            for audioTrack in stream!.audioTracks {
                let trackOption = LSTrackOption(meta: ["track_metadata": "audio"], mute: MuteType.UNMUTE)
                localLSTracks.append(LSTrack(mediaStreamTrack: audioTrack, stream: stream!, option: trackOption))
            }
            for videoTrack in stream!.videoTracks {
                let trackOption = LSTrackOption(meta: ["track_metadata": "video"], mute: MuteType.UNMUTE)
                localLSTracks.append(LSTrack(mediaStreamTrack: videoTrack, stream: stream!, option: trackOption))
            }
            
            let sendingVideoOption = SendingVideoOption(codec: VideoCodecType.VP8, priority: SendingPriority.HIGH, maxBitrateKbps: VIDEO_BITRATE, muteType: VideoOptionMuteType.UNMUTE)
            let sendingOption = SendingOption(video: sendingVideoOption, enabled: true)
            
            let receivingOption = ReceivingOption(enabled: true)
            
            let option = Option(signalingURL: nil, localLSTracks: localLSTracks, meta: ["connect_meta": "iOS"], sending: sendingOption, receiving: receivingOption, iceServersProtocol: IceServersProtocol.ALL)
            
            try client?.connect(clientId: CLIENT_ID, accessToken: AccessToken().getAccessToken(), option: option)
        } catch {
            print ("[App] Failed to connect.")
        }
    }
    
    @IBAction func tapDisconnectButton(_ sender: Any) {
        for v in self.broadcastPickerView.subviews {
            if v.isKind(of: UIButton.self) {
                let v = v as! UIButton
                v.sendActions(for: .touchUpInside)
                break;
            }
        }
        if let timer = timer {
            if timer.isValid {
                timer.invalidate()
            }
        }
        client?.disconnect()
        self.localLSTracks.removeAll()
        remoteTracks.removeAll()
        clearRemoteVideos()
        remoteViewList.removeAll()
        changeUiState(state: .Disconnected)
    }
    
    @IBAction func tapShareButton(_ sender: Any) {
        for v in self.broadcastPickerView.subviews {
            if v.isKind(of: UIButton.self) {
                let v = v as! UIButton
                v.sendActions(for: .touchUpInside)
                timer = Timer.scheduledTimer(timeInterval: 1/30.0, target: self, selector: #selector(self.capture), userInfo: nil, repeats: true)
                timer?.fire()
                break;
            }
        }
    }
    
    @IBAction func tapAudioMuteStateSegmentedControl(_ sender: Any) {
        guard let track = getLocalAudioLsTrack() else {
            return
        }
        let ctrl = sender as! UISegmentedControl
        do {
            switch ctrl.selectedSegmentIndex {
            case 0:
                try client?.changeMute(lsTrack: track, nextMuteType: MuteType.UNMUTE)
            case 1:
                try client?.changeMute(lsTrack: track, nextMuteType: MuteType.SOFT_MUTE)
            case 2:
                try client?.changeMute(lsTrack: track, nextMuteType: MuteType.HARD_MUTE)
            default:
                break
            }
        } catch {
            print ("[App] Failed to change audio mute.")
        }
    }
    
    @IBAction func tapVideoMuteStateSegmentedControl(_ sender: Any) {
        guard let track = getLocalVideoLsTrack() else {
            return
        }
        let ctrl = sender as! UISegmentedControl
        do {
            switch ctrl.selectedSegmentIndex {
            case 0:
                try client?.changeMute(lsTrack: track, nextMuteType: MuteType.UNMUTE)
            case 1:
                try client?.changeMute(lsTrack: track, nextMuteType: MuteType.SOFT_MUTE)
            case 2:
                try client?.changeMute(lsTrack: track, nextMuteType: MuteType.HARD_MUTE)
            default:
                break
            }
        } catch {
            print ("[App] Failed to change video mute.")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let client = self.client else {
            return
        }
        if client.getState() == .OPEN {
            self.tapDisconnectButton(self)
        }
    }
    
    private func setupApiMenuButton() {
        let rootMenu = UIMenu(title: "APIs", children: [
            UIAction(title: "updateMeta", handler: { _ in
                do {
                    try self.client?.updateMeta(meta: ["connect_meta": "new_connect_meta"])
                } catch {
                    print ("[App] Failed to update meta.")
                }
            }),
            UIAction(title: "updateTrackMeta", handler: { [self] _ in
                do {
                    try self.client?.updateTrackMeta(lsTrack: getLocalVideoLsTrack()!, meta: ["track_metadata": "new_track_metadata"])
                } catch {
                    print ("[App] Failed to update track meta.")
                }
            }),
            UIMenu(title: "changeVideoSendBitrate", children: [
                UIAction(title: "500kbps", handler: { [self] _ in
                    do {
                        try client?.changeVideoSendBitrate(maxBitrateKbps: 500)
                    } catch {
                        print ("[App] Failed to change video send bitrate to 500kps.")
                    }
                }),
                UIAction(title: "1000kbps", handler: { [self] _ in
                    do {
                        try client?.changeVideoSendBitrate(maxBitrateKbps: 1000)
                    } catch {
                        print ("[App] Failed to change video send bitrate to 1000kps.")
                    }
                }),
                UIAction(title: "2000kbps", handler: { [self] _ in
                    do {
                        try client?.changeVideoSendBitrate(maxBitrateKbps: 2000)
                    } catch {
                        print ("[App] Failed to change video send bitrate to 2000kps.")
                    }
                }),
            ]),
        ])
        apiMenuButton.menu = rootMenu
        apiMenuButton.showsMenuAsPrimaryAction = true
    }
    
    @objc private func capture() {
        guard let pixelBuffer = self.fileManager.getFrame().pixelBuffer,
              let orientation = self.fileManager.getFrame().orientation,
              let videoCapturer = self.videoCapturer else {
            return
        }
        videoCapturer.start(pixelBuffer: pixelBuffer, orientation: orientation)
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        containerView.layoutIfNeeded()
    }
    
    private func showAlertDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    private func changeUiState(state: UIStateMode) {
        switch state {
        case .Init:
            connectButton.isEnabled = true
            disconnectButton.isEnabled = false
            shareButton.isEnabled = false
            apiMenuButton.isEnabled = false
            audioSegmentedControl.isEnabled = false
            videoSegmentedControl.isEnabled = false
            audioSegmentedControl.selectedSegmentIndex = 0
            videoSegmentedControl.selectedSegmentIndex = 0
        case .Connected:
            connectButton.isEnabled = false
            disconnectButton.isEnabled = true
            shareButton.isEnabled = true
            apiMenuButton.isEnabled = true
            audioSegmentedControl.isEnabled = true
            videoSegmentedControl.isEnabled = true
        case .Disconnected:
            connectButton.isEnabled = true
            disconnectButton.isEnabled = false
            shareButton.isEnabled = false
            apiMenuButton.isEnabled = false
            audioSegmentedControl.isEnabled = false
            videoSegmentedControl.isEnabled = false
            audioSegmentedControl.selectedSegmentIndex = 0
            videoSegmentedControl.selectedSegmentIndex = 0
        }
    }
    
    private func getLocalVideoLsTrack() -> LSTrack? {
        for track in localLSTracks {
            if track.mediaStreamTrack.kind == "video" {
                return track
            }
        }
        return nil
    }
    
    private func getLocalAudioLsTrack() -> LSTrack? {
        for track in localLSTracks {
            if track.mediaStreamTrack.kind == "audio" {
                return track
            }
        }
        return nil
    }
    
    private func saveLog(prefix: String, path: String) {
        let fileManager = FileManager.default
        let directoryURL = URL(fileURLWithPath: path)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [.contentModificationDateKey], options: .skipsHiddenFiles)
            
            for fileURL in fileURLs {
                let fileName = fileURL.lastPathComponent
                if fileName.hasPrefix(prefix) {
                    let modificationDate = try fileURL.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
                    let newFileName = dateFormatter.string(from: modificationDate!) + "_" + fileName
                    let newFileURL = directoryURL.appendingPathComponent(newFileName)
                    try fileManager.moveItem(at: fileURL, to: newFileURL)
                }
            }
        } catch (let error) {
            print("[App] Filed to rename webrtc log file.")
        }
    }
    
    private func showRemoteVideos() {
        clearRemoteVideos()
        
        let width = Int(remoteScrollView.bounds.width / 2)
        let height = Int(remoteScrollView.bounds.height - 50)
        let xMargin = 10
        
        var i = 0
        var scrollSizeX = 0
        
        for remoteTrack in remoteTracks {
            let view = UIView()
            let remoteRenderer = RTCMTLVideoView(frame: view.frame)
            let x = i * (width + xMargin)
            for entry in remoteTrack {
                remoteRenderer.videoContentMode = .scaleAspectFit
                entry.value?.add(remoteRenderer)
                embedView(remoteRenderer, into: view)
                view.frame = CGRect(x: x, y: 0, width: width, height: height)
                remoteScrollView.addSubview(view)
                remoteViewList.append(view)
                scrollSizeX = x + width + xMargin
            }
            i += 1
        }
        remoteScrollView.contentSize = CGSize(width: scrollSizeX, height: Int(remoteScrollView.bounds.height))
    }
    
    private func clearRemoteVideos() {
        for remoteView in remoteViewList {
            remoteView.removeFromSuperview()
        }
    }
    
}

extension LSScreenShareViewController: ClientDelegate {
    
    func onClosing() {
        print("[App] event: onClosing")
        statsTimer?.invalidate()
    }
    
    func onClosed() {
        print("[App] event: onClosed")
    }
    
    func onConnecting() {
        print("[App] event: onConnecting")
    }
    
    func onAddLocalTrack(event: LSAddLocalTrackEvent) {
        print ("[App] event: onAddLocalTrack", event)
    }
    
    func onOpen(event: LSOpenEvent) {
        print("[App] event: onOpen", event)
        changeUiState(state: .Connected)
        showAlertDialog(title: "情報", message: "入室しました。")
        
        statsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {[weak self] (timer) in
            if let self = self {
                if let stats = client?.getStats(mediaStreamTrack: nil) {
                    for (_, value) in stats {
                        logger.info(message: value.timestamp_us)
                        let values = value.statistics
                        logger.info(message: values)
                    }
                }
            }
        })
    }
    
    func onAddRemoteConnection(event: LSAddRemoteConnectionEvent) {
        print("[App] event: onAddRemoteConnection", event)
    }
    
    func onRemoveRemoteConnection(event: LSRemoveRemoteConnectionEvent) {
        print("[App] event: onRemoveRemoteConnection", event)
        for (index, value) in remoteTracks.enumerated() {
            if value[event.connectionId] != nil {
                remoteTracks.remove(at: index)
            }
        }
        showRemoteVideos()
    }
    
    func onAddRemoteTrack(event: LSAddRemoteTrackEvent) {
        print ("[App] event: onAddRemoteTrack", event.meta)
        if event.mediaStreamTrack.kind == "video" {
            remoteTracks.append([event.connectionId: event.mediaStreamTrack as? RTCVideoTrack])
            showRemoteVideos()
        }
    }
    
    func onError(event: SDKErrorEvent) {
        print("[App] event: onError", event.detail, event.toReportString())
    }
    
}
