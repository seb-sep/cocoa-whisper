//
//  Controller.swift
//  cocoa-whisper_Example
//
//  Created by Sebastian  Sepulveda on 3/16/24.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import cocoa_whisper

func foo() async {
    let pipe = try? await WhisperKit()
    let transcription = try? await pipe!.transcribe(audioPath: "path/to/your/audio.{wav,mp3,m4a,flac}")?.text
        print(transcription)
//    foo()
}
