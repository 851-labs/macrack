import Darwin
import Foundation
import Logging

final class MacrackAgent {
    private let logger: Logger
    private let sleepPrevention = SleepPrevention()
    private let brightnessController: BrightnessController?
    private let volumeController = VolumeController()
    private let activityMonitor = ActivityMonitor()
    private let startTime = Date()
    private var config = Configuration.default
    private var reloadRequested = true
    private var lastPauseState: Bool?
    private var lastCaffeinatePid: Int32?

    init(logger: Logger) {
        self.logger = logger
        self.brightnessController = BrightnessController()
    }

    func run() -> Never {
        setupSignalHandler()
        logger.info("Agent started")

        if brightnessController == nil {
            logger.warning("Brightness controller unavailable")
        }

        if let caffeinatePid = sleepPrevention.start() {
            lastCaffeinatePid = caffeinatePid
            logger.info("caffeinate started (PID \(caffeinatePid))")
        } else {
            logger.error("Failed to start caffeinate")
        }

        while true {
            if reloadRequested {
                let loaded = Configuration.load()
                config = loaded.config
                reloadRequested = false
                logger.info("Config reloaded")
            }

            let caffeinatePid = sleepPrevention.ensureRunning()
            if let caffeinatePid, caffeinatePid != lastCaffeinatePid {
                lastCaffeinatePid = caffeinatePid
                logger.info("caffeinate started (PID \(caffeinatePid))")
            }

            let idleSeconds = activityMonitor.idleSeconds()
            let idleThreshold = Double(config.autoPauseIdleThresholdSeconds)
            let isPaused = config.autoPauseEnabled && (idleSeconds ?? .greatestFiniteMagnitude) < idleThreshold

            if lastPauseState != isPaused {
                if isPaused {
                    logger.info("User activity detected, pausing enforcement")
                } else if lastPauseState != nil {
                    logger.info("Idle threshold reached, resuming enforcement")
                }
                lastPauseState = isPaused
            }

            var currentBrightness = brightnessController?.currentBrightnessPercent()
            var currentVolume = volumeController.currentVolume()
            var currentMuted = volumeController.isMuted()

            if !isPaused {
                if config.brightnessLockEnabled, let brightnessValue = currentBrightness, brightnessValue > 0.5 {
                    if brightnessController?.setBrightness(percent: 0) == true {
                        logger.info("Brightness set to 0% (was \(Int(brightnessValue)))")
                        currentBrightness = 0
                    }
                }

                if config.volumeLockEnabled {
                    let volumeValue = currentVolume ?? 0
                    let mutedValue = currentMuted ?? false
                    if volumeValue > 0 || !mutedValue {
                        if volumeController.mute() {
                            logger.info("Volume muted (was \(volumeValue))")
                            currentVolume = 0
                            currentMuted = true
                        }
                    }
                }
            }

            let status = AgentStatus(
                updatedAt: Date(),
                startTime: startTime,
                agentPid: getpid(),
                caffeinatePid: caffeinatePid,
                brightnessPercent: currentBrightness,
                volumePercent: currentVolume,
                isMuted: currentMuted,
                isPaused: isPaused,
                idleSeconds: idleSeconds
            )
            StatusCacheStore.save(status)

            Thread.sleep(forTimeInterval: TimeInterval(max(5, config.checkIntervalSeconds)))
        }
    }

    private func setupSignalHandler() {
        signal(SIGHUP, SIG_IGN)
        let hupSource = DispatchSource.makeSignalSource(signal: SIGHUP, queue: .global())
        hupSource.setEventHandler { [weak self] in
            self?.reloadRequested = true
        }
        hupSource.resume()
    }
}
