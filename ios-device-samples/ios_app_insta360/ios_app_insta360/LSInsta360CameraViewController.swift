/// Copyright (c) 2024 RICOH Company, Ltd. All rights reserved.

import UIKit
import client_sdk
import WebRTC
import INSCameraSDK

class LSInsta360CameraViewController: UIViewController {

    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var connectInsta360Button: UIButton!
    @IBOutlet weak var captureInsta360Button: UIButton!
    @IBOutlet weak var localTestView: UIView!
    @IBOutlet weak var insta360StatusLabel: UILabel!
    @IBOutlet weak var selectedResolutionLabel: UILabel!
    @IBOutlet weak var remoteScrollView: UIScrollView!
    
    @IBOutlet weak var audioSegmentedControl: UISegmentedControl!
    @IBOutlet weak var videoSegmentedControl: UISegmentedControl!
    
    private let logger = AppLogger.shared
    
    private var client: Client?
    private var localLSTracks: [LSTrack] = []
    private var videoCapturer: PixelBufferCapturer?
    
    private var remoteTracks: [Dictionary<String, RTCVideoTrack?>] = []
    private var remoteViewList: [UIView] = []
    
    private var localRenderer: RTCMTLVideoView?
    private var remoteRenderer: RTCMTLVideoView?
    private var localVideoTrack: RTCVideoTrack?
    private var videoTrack: RTCVideoTrack?
    
    private var isConnectedInsta360 = false
    private var cameraType: String?
    private var resolution = INSVideoResolution1440x2880x30
    private var mediaSession: INSCameraMediaSession?
    private var renderView: INSRenderView?
    private var previewPlayer: INSCameraPreviewPlayer?
    private var flatPanoOutput: INSCameraFlatPanoOutput?
    
    private var statsTimer: Timer?
    
    private let insta360OscManager = Insta360OSCManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        INSCameraManager.socket().addObserver(self, forKeyPath: "cameraState", options: NSKeyValueObservingOptions.new, context: nil)
        
        disconnectButton.isEnabled = false
        connectInsta360Button.isEnabled = false
        captureInsta360Button.isEnabled = false
        audioSegmentedControl.isEnabled = false
        videoSegmentedControl.isEnabled = false
        audioSegmentedControl.selectedSegmentIndex = 0
        videoSegmentedControl.selectedSegmentIndex = 0
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
                let trackOption = LSTrackOption(meta: ["track_metadata": "video", "isTheta": true], mute: MuteType.UNMUTE)
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
        client?.disconnect()
        self.localLSTracks.removeAll()
        disconnectInsta360()
        connectInsta360Button.setTitle("connect", for: .normal)
        connectInsta360Button.isEnabled = false
        disconnectButton.isEnabled = false
        connectButton.isEnabled = true
        audioSegmentedControl.isEnabled = false
        videoSegmentedControl.isEnabled = false
        audioSegmentedControl.selectedSegmentIndex = 0
        videoSegmentedControl.selectedSegmentIndex = 0
        remoteTracks.removeAll()
        clearRemoteVideos()
        remoteViewList.removeAll()
    }
    
    @IBAction func tapConnectInsta360(_ sender: Any) {
        if !isConnectedInsta360 {
            INSCameraManager.socket().setup()
        } else {
            INSCameraManager.socket().shutdown()
            isConnectedInsta360 = false
            connectInsta360Button.setTitle("connect", for: .normal)
            disconnectInsta360()
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
            print ("[App] Error has occured.")
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
            print ("[App] Error has occured.")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let state: UInt = change![NSKeyValueChangeKey.newKey]! as! UInt
        var status: String = ""
        switch state {
        case INSCameraState.found.rawValue:
            status = "Found"
        case INSCameraState.synchronized.rawValue:
            status = "Synchronized"
        case INSCameraState.connected.rawValue:
            status = "Connected"
            self.cameraType = INSCameraManager.shared().currentCamera?.cameraType
            self.initResolutionMenu(cameraType: self.cameraType!)
            self.startHeartBeat()
            self.connectInsta360Button.setTitle("disconnect", for: .normal)
            self.captureInsta360Button.isEnabled = true
            self.isConnectedInsta360 = true
            
        case INSCameraState.connectFailed.rawValue:
            status = "Connect failed"
        default:
            status = "Not connect"
        }
        
        DispatchQueue.main.async {
            self.insta360StatusLabel.text = status
        }
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
    
    private func setup() {
        self.mediaSession = INSCameraMediaSession()
        self.mediaSession!.expectedAudioSampleRate = INSAudioSampleRate.rate48000Hz
        self.mediaSession!.expectedVideoResolution = resolution
        let renderView = INSRenderView(frame: self.localTestView.bounds, renderType: INSRenderType.sphericalPanoRender)
        self.localTestView.insertSubview(renderView, at: 0)
        self.renderView = renderView
        self.previewPlayer = INSCameraPreviewPlayer(renderView: renderView)
        self.mediaSession?.plug(self.previewPlayer!)
        self.selectedResolutionLabel.text = makeResolutionStr(resolution: self.resolution)
        self.captureInsta360Button.isEnabled = false
    }
    
    private func startHeartBeat() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { timer in
            INSCameraManager.socket().commandManager.sendHeartbeats(with: nil)
        })
    }
    
    private func updateMediaSession() {
        guard let mediaSession = self.mediaSession else {
            print("ERROR")
            return
        }
        if mediaSession.running {
            mediaSession.commitChanges(completion: { error in
                if error != nil {
                    print("ERROR:::", error)
                }
            })
        } else {
            mediaSession.startRunning(completion: { error in
                if error != nil {
                    print("ERROR:::", error)
                }
            })
        }
    }

    private func setupFlatPanoOutput() {
        self.flatPanoOutput = INSCameraFlatPanoOutput(outputWidth: resolution.width, outputHeight: resolution.height)
        self.flatPanoOutput?.setDelegate(self, onDispatchQueue: nil)
        self.flatPanoOutput?.outputPixelFormat = kCVPixelFormatType_32BGRA
        self.mediaSession?.plug(self.flatPanoOutput!)
    }
    
    private func initResolutionMenu(cameraType: String) {
        var actions = [UIMenuElement]()
        if let insta360Resolution = Insta360CameraResolutionFactory.create(cameraType: cameraType) {
            actions = insta360Resolution.getResolutions(closure: { (resolution) in
                if self.isSingleLens() {
                    self.showAlertDialog(title: "エラー", message: "シングルレンズモードになっています。カメラの設定から360°モードに変更してください。")
                    return
                }
                self.resolution = resolution
                self.setup()
                self.setupFlatPanoOutput()
                self.updateMediaSession()
            })
        }

        self.captureInsta360Button.menu = UIMenu(title: "", options: .displayInline, children: actions)
        self.captureInsta360Button.showsMenuAsPrimaryAction = true
    }
    
    private func makeResolutionStr(resolution: INSVideoResolution) -> String {
        return String(format: "%ldx%ld %ldFPS", resolution.width, resolution.height, resolution.fps)
    }
    
    private func disconnectInsta360() {
        self.mediaSession?.unplugAll()
        self.renderView?.removeFromSuperview()
        INSCameraManager.socket().shutdown()
        self.connectInsta360Button.isEnabled = true
        self.connectInsta360Button.isEnabled = true
        self.captureInsta360Button.isEnabled = false
        self.selectedResolutionLabel.text = ""
    }
    
    private func showAlertDialog(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func isSingleLens() -> Bool {
        guard let lensType = insta360OscManager.getSensorModuleType() else {
            return false
        }
        if lensType.contains("Selfie") {
            return true
        }
        return false
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

extension LSInsta360CameraViewController: ClientDelegate {
    
    func onError(event: SDKErrorEvent) {
        print("[App] event: onError")
    }
    
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
        disconnectButton.isEnabled = true
        connectButton.isEnabled = false
        audioSegmentedControl.isEnabled = true
        videoSegmentedControl.isEnabled = true
        connectInsta360Button.isEnabled = true
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
    
    func onError(event: ErrorDetail) {
        print("[App] event: onError", event.code)
    }
    
}

extension LSInsta360CameraViewController: INSCameraAVOutputDelegate {
    
    func avOutput(_ avOutput: INSCameraAVOutput, didOutputVideoFrame videoFrame: INSCameraVideoFrame) {
        guard let videoCapturer = self.videoCapturer else {
            return
        }
        DispatchQueue.main.async {
            videoCapturer.start(pixelBuffer: videoFrame.pixelBuffer, orientation: .up)
        }
    }

}

