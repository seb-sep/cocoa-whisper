import XCTest
import cocoa_whisper

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testWhisperKit() async {
        let path = Bundle.main.path(forResource: "test", ofType: "mp3")!
        do {
            let pipe = try await WhisperKit()
            XCTAssertNotNil(pipe)
            let transcription = try await pipe.transcribe(audioPath: path)
            XCTAssertNotNil(transcription)
            let val = transcription!.text
            XCTAssertEqual(val, "Hello world")
        } catch {
            print(error)
        }
    }
    
    
}
