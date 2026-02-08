import Foundation

extension Notification.Name {
    static let scoreboardDidUpdate = Notification.Name("scoreboardDidUpdate")
}

final class WebSocketManager: NSObject, URLSessionWebSocketDelegate {
    static let shared = WebSocketManager()

    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession!
    private var currentQuestId: String?
    private var isConnected = false
    private var reconnectWorkItem: DispatchWorkItem?

    private override init() {
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }

    func connect(questId: String) {
        disconnect()
        currentQuestId = questId

        guard let token = UserDefaults.standard.string(forKey: "cherries_access_token") else {
            print("[WebSocket] No access token available")
            return
        }

        let urlString = "\(Constants.API.wsBaseURL)/ws/quests/\(questId)?token=\(token)"
        guard let url = URL(string: urlString) else { return }

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        receiveMessage()
    }

    func disconnect() {
        reconnectWorkItem?.cancel()
        reconnectWorkItem = nil
        isConnected = false
        currentQuestId = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
    }

    // MARK: - Private

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handleMessage(message)
                self?.receiveMessage()
            case .failure(let error):
                print("[WebSocket] Receive error: \(error)")
                self?.scheduleReconnect()
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let text):
            guard let data = text.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let type = json["type"] as? String else { return }

            if type == "scoreboard_update", let questId = json["quest_id"] as? String {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .scoreboardDidUpdate,
                        object: nil,
                        userInfo: ["quest_id": questId]
                    )
                }
            }
        case .data:
            break
        @unknown default:
            break
        }
    }

    private func scheduleReconnect() {
        guard isConnected, let questId = currentQuestId else { return }
        isConnected = false

        let workItem = DispatchWorkItem { [weak self] in
            self?.connect(questId: questId)
        }
        reconnectWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
    }

    // MARK: - URLSessionWebSocketDelegate

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("[WebSocket] Connected")
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("[WebSocket] Disconnected: \(closeCode)")
        scheduleReconnect()
    }
}
