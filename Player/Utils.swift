
import Foundation

func formatTime(_ length: Int) -> String {
    return String(format: "%02d:%02d", length / 60, length % 60)
}
