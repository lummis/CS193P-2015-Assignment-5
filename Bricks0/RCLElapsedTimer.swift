//
//  RCLElapsedTimer.swift
//  Bricks0
//
//  Created by Robert Lummis on 6/16/15.
//  Copyright (c) 2015 ElectricTurkeySoftware. All rights reserved.
//
//  adapted from an earlier Objective-C method

import Foundation

protocol RCLElapsedTimerDelegate {
    var sessionTime: Float { get set }
}

class RCLElapsedTimer: NSObject {
    
    static let sharedTimer = RCLElapsedTimer()  // singleton
    
    enum State {
        case NotStarted
        case Running
        case Paused
        case Stopped
    }
        
    var seconds: Float {
        didSet {
            delegate.sessionTime = seconds
        }
    }
    var resolution: NSTimeInterval
    var delegate: RCLElapsedTimerDelegate!
    var timerState: State
    private var timer: NSTimer!
    private var timeWhenPaused: Float

    override init() {
        seconds = 0             //
        timeWhenPaused = 0
        resolution = 1
        timerState = .NotStarted
        super.init()
    }
    
    // if now .Running does nothing
    func start() {
        if timerState != .Running {
            seconds = 0
            timer = NSTimer.scheduledTimerWithTimeInterval(resolution, target: self, selector: "tick", userInfo: nil, repeats: true)
            timer.tolerance = 0.02
            timerState = .Running
        }
    }
    
    // if not .Running does nothing
    func pause() {
        if timerState == .Running {
            timeWhenPaused = seconds
            timer.invalidate()
            timerState = .Paused
        }
    }
    
    // if not .Paused does nothing
    func resume() {
        if timerState == .Paused {
            seconds = timeWhenPaused
            timer = NSTimer.scheduledTimerWithTimeInterval(resolution, target: self, selector: "tick", userInfo: nil, repeats: true)
            timer.tolerance = 0.02
            timerState = .Running
        }
    }
    
    func tick() {
        if timerState == .Running {
            seconds += Float(resolution)
        }
    }
    
    // does nothing if .NotStarted
    func stop() {
        if timerState != .NotStarted {
            timer.invalidate()
            timerState = .Stopped
        }
    }
}