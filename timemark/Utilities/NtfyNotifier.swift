import Foundation

enum NtfyNotifier {
    private static let topicURL = URL(string: "https://ntfy.sh/tallydays-jejwb71825")!

    static func sendNewUser() {
        var request = URLRequest(url: topicURL)
        request.httpMethod = "POST"
        request.setValue("New User", forHTTPHeaderField: "Title")
        request.setValue("tada", forHTTPHeaderField: "Tags")
        request.httpBody = "Someone just opened TallyDays for the first time!".data(using: .utf8)

        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }
}
