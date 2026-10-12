import QtQuick

Item {
    id: logoRoot

    property string logoSource: (typeof config !== "undefined" && config.logo) ? config.logo : "assets/logos/origin_logo.png"
    property real logoScale: (typeof config !== "undefined" && config.logoScale !== undefined) ? parseFloat(config.logoScale) : 1.0
    property int baseWidth: (typeof config !== "undefined" && config.logoWidth !== undefined) ? parseInt(config.logoWidth) : 230
    property bool showLogo: (typeof config !== "undefined" && config.showLogo === "false") ? false : true

    function resolveLogoUrl(path) {
        if (!path || path === "") return Qt.resolvedUrl("../assets/logos/origin_logo.png");
        var p = ("" + path).trim();
        if (p.startsWith("file://") || p.startsWith("qrc:/")) return p;
        if (p.startsWith("/")) return "file://" + p;
        if (p.startsWith("assets/")) return Qt.resolvedUrl("../" + p);
        if (p.indexOf("/") === -1) return Qt.resolvedUrl("../assets/logos/" + p);
        return Qt.resolvedUrl(p);
    }

    visible: showLogo
    width: baseWidth * logoScale
    height: (logoImage.implicitHeight > 0 && logoImage.implicitWidth > 0) ? width * (logoImage.implicitHeight / logoImage.implicitWidth) : width * 0.43

    // Entrance and subtle breathing glow
    opacity: 0.0
    transform: Scale {
        id: logoScaleAnim
        origin.x: logoRoot.width / 2
        origin.y: logoRoot.height / 2
        xScale: 0.94
        yScale: 0.94
    }

    Component.onCompleted: {
        entranceAnim.start();
    }

    ParallelAnimation {
        id: entranceAnim
        NumberAnimation {
            target: logoRoot
            property: "opacity"
            to: 1.0
            duration: 500
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: logoScaleAnim
            properties: "xScale,yScale"
            to: 1.0
            duration: 600
            easing.type: Easing.OutBack
        }
    }

    Image {
        id: logoImage
        anchors.fill: parent
        source: logoRoot.resolveLogoUrl(logoRoot.logoSource)
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
        mipmap: true
    }

    // Subtle gentle hovering glow effect
    Rectangle {
        id: ambientGlow
        anchors.centerIn: parent
        width: parent.width * 0.9
        height: parent.height * 0.6
        radius: height / 2
        color: Qt.rgba(0.22, 0.50, 0.95, 0.12)
        z: -1

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.25; duration: 2400; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.08; duration: 2400; easing.type: Easing.InOutSine }
        }
    }
}

