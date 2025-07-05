import Foundation
import FirebaseFunctions

// This service class handles all interactions with the Firebase Cloud Functions.
// It is a singleton to ensure a single point of interaction.
class FirebaseAPIService {
    static let shared = FirebaseAPIService()
    private lazy var functions = Functions.functions()

    private init() {}

    // Main public function to identify a rock from image data.
    // It calls the `identifyRock` Firebase Function.
    func identifyRock(imageData: Data, completion: @escaping (Result<RockIdentificationResult, Error>) -> Void) {
        // 1. Convert image data to a base64 encoded string, as required by the function.
        let base64EncodedImage = imageData.base64EncodedString()

        // 2. Call the `identifyRock` Cloud Function
        functions.httpsCallable("identifyRock").call(["image": base64EncodedImage]) { result, error in
            // 3. Handle the response
            if let error = error {
                print("FirebaseAPIService: Error calling identifyRock function: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            // 4. Process the successful result
            guard let data = result?.data else {
                print("FirebaseAPIService: Function returned successfully, but with no data.")
                completion(.failure(NSError(domain: "FirebaseAPIServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned from function."])))
                return
            }
            
            // The new function returns the result directly. We can decode it without looking for a nested object.
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let decoder = JSONDecoder()
                let identificationResult = try decoder.decode(RockIdentificationResult.self, from: jsonData)
                
                // Success!
                completion(.success(identificationResult))
                
            } catch {
                print("FirebaseAPIService: Failed to decode response data: \(error)")
                completion(.failure(error))
            }
        }
    }
}
