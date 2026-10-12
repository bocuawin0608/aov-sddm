import QtQuick
import QtQuick.Controls

Item {
    id: termsRoot

    signal closeRequested()

    ThemeStyles { id: styles }

    // Backdrop
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Qt.rgba(0.02, 0.04, 0.10, 0.65)
        opacity: termsRoot.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: termsRoot.closeRequested()
        }
    }

    Rectangle {
        id: card
        width: Math.min(500, parent.width * 0.92)
        height: Math.min(480, parent.height * 0.85)
        anchors.centerIn: parent
        radius: 12
        color: styles.surfaceCard
        border.width: 1.5
        border.color: styles.borderCyan
        clip: true

        scale: termsRoot.visible ? 1.0 : 0.92
        opacity: termsRoot.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        // Header
        Rectangle {
            id: headerBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 52
            color: Qt.rgba(0.05, 0.09, 0.20, 0.95)
            border.width: 0.8
            border.color: styles.borderGlass

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Image {
                    width: 20
                    height: 20
                    source: "assets/icons/check.svg"
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "ĐIỀU KHOẢN & HƯỚNG DẪN HỆ THỐNG"
                    font.family: (typeof config !== "undefined" && config.fontFamily) ? config.fontFamily : "sans-serif"
                    font.bold: true
                    font.pixelSize: 13
                    color: "#f8fafc"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: 32
                height: 32
                radius: 16
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                color: closeArea.containsMouse ? Qt.rgba(0.9, 0.2, 0.2, 0.5) : "transparent"

                Image {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: "assets/icons/close.svg"
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: termsRoot.closeRequested()
                }
            }
        }

        ScrollView {
            anchors.top: headerBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 16
            clip: true

            Column {
                width: card.width - 32
                spacing: 12

                Text {
                    text: "1. Bảo mật & Xác thực cục bộ (Local Authentication)"
                    font.pixelSize: 13
                    font.bold: true
                    color: styles.textGold
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    lineHeight: 1.3
                    color: "#cbd5e1"
                    text: "Giao diện đăng nhập này sử dụng giao diện PAM tiêu chuẩn của SDDM trên hệ điều hành Linux (Arch Linux / EndeavourOS). Mật khẩu chỉ được chuyển giao trực tiếp cho cơ chế xác thực nội bộ của hệ thống và không bao giờ được ghi lại, lưu trữ hoặc truyền qua mạng dưới bất kỳ hình thức nào."
                }

                Text {
                    text: "2. Phím tắt thao tác nhanh (Keyboard Navigation)"
                    font.pixelSize: 13
                    font.bold: true
                    color: styles.textGold
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    lineHeight: 1.3
                    color: "#cbd5e1"
                    text: "• Phím Tab / Shift+Tab: Di chuyển tiêu điểm giữa các trường và nút bấm.\n• Phím Enter: Gửi thông tin đăng nhập hoặc kích hoạt nút đang chọn.\n• Phím Esc: Đóng nhanh các hộp thoại lựa chọn đang mở.\n• Phím Mũi tên Lên / Xuống: Di chuyển lựa chọn trong danh sách môi trường đồ họa."
                }

                Text {
                    text: "3. Lưu trữ tên người dùng gần nhất (Persistence)"
                    font.pixelSize: 13
                    font.bold: true
                    color: styles.textGold
                }
                Text {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 12
                    lineHeight: 1.3
                    color: "#cbd5e1"
                    text: "Tên tài khoản người dùng đã đăng nhập gần nhất được lưu trữ cục bộ trong cơ sở dữ liệu SQLite an toàn của SDDM để hỗ trợ đăng nhập nhanh. Mật khẩu không bao giờ được lưu. Bạn có thể xóa danh sách tài khoản đã nhớ bất cứ lúc nào trong mục 'Sửa nhanh' hoặc tại danh sách tài khoản."
                }
            }
        }
    }

    Keys.onEscapePressed: termsRoot.closeRequested()
}

