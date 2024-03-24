//
//  Controller.swift
//  cocoa-whisper_Example
//
//  Created by Sebastian  Sepulveda on 3/16/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import cocoa_whisper

func foo() async -> String {
    let pipe = try? await WhisperKit()
    let transcription = try? await pipe!.transcribe(audioPath: "test.mp3")?.text
    return transcription!!
}

func fetchStringAsync(completion: @escaping (String) -> Void) async {
    // Simulate an asynchronous task, e.g., network request
    let fetchedString = await foo()
    DispatchQueue.global(qos: .background).async {
        // Simulate a delay
        completion(fetchedString)
    }
}
