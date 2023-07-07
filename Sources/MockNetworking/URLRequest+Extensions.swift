import Foundation

extension URLRequest {
    public func bodySteamAsJSON() -> Any? {
        guard let bodyStream = self.httpBodyStream else { return nil }
        
        bodyStream.open()
        
        let bufferSize: Int = 16
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        
        var data = Data()
        
        while bodyStream.hasBytesAvailable {
            let readData = bodyStream.read(buffer, maxLength: bufferSize)
            data.append(buffer, count: readData)
        }
        
        buffer.deallocate()
        bodyStream.close()
        
        do {
            return try JSONSerialization.jsonObject(with: data,
                                                    options: JSONSerialization.ReadingOptions.allowFragments)
            
        } catch {
            #if DEBUG
            print(error.localizedDescription)
            #endif
            return nil
        }
    }
}
