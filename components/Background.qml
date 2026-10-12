import QtQuick
import QtMultimedia
import QtQuick.Effects

Item {
    id: backgroundRoot

    anchors.fill: parent

    property string imageSource: (typeof config !== "undefined" && config.background) ? config.background : "assets/backgrounds/default.png"
    property string videoSource: (typeof config !== "undefined" && config.videoBackground) ? config.videoBackground : "assets/backgrounds/sddm_theme.mp4"
    property string backgroundType: (typeof config !== "undefined" && config.backgroundType) ? config.backgroundType : "video"
    property real dimOpacity: (typeof config !== "undefined" && config.dimOverlay !== undefined) ? parseFloat(config.dimOverlay) : 0.18
    property bool enableParallax: (typeof config !== "undefined" && config.enableParallax === "false") ? false : true
    property bool reducedMotion: (typeof config !== "undefined" && config.reducedMotion === "true") ? true : false

    property real mouseXRatio: 0.5
    property real mouseYRatio: 0.5

    property bool videoFailed: false
    readonly property bool isPlayingVideo: (backgroundType === "video" && !videoFailed && videoSource !== "")

    function resolveMediaUrl(path) {
        if (!path || path === "") return "";
        var p = ("" + path).trim();
        if (p.startsWith("file://") || p.startsWith("qrc:/") || p.startsWith("http://") || p.startsWith("https://")) {
            return p;
        }
        if (p.startsWith("/")) {
            return "file://" + p;
        }
        if (p.startsWith("assets/")) {
            return Qt.resolvedUrl("../" + p);
        }
        if (p.indexOf("/") === -1) {
            return Qt.resolvedUrl("../assets/backgrounds/" + p);
        }
        return Qt.resolvedUrl(p);
    }

    // Mouse tracker for subtle game parallax
    MouseArea {
        id: parallaxArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // Pass clicks through
        onPositionChanged: function(mouse) {
            if (backgroundRoot.enableParallax && !backgroundRoot.reducedMotion && width > 0 && height > 0) {
                backgroundRoot.mouseXRatio = Math.max(0.0, Math.min(1.0, mouse.x / width));
                backgroundRoot.mouseYRatio = Math.max(0.0, Math.min(1.0, mouse.y / height));
            }
        }
    }

    Item {
        id: mediaContainer
        // Slightly oversized for subtle parallax without exposing borders
        width: parent.width * 1.04
        height: parent.height * 1.04
        x: backgroundRoot.enableParallax && !backgroundRoot.reducedMotion ? -(parent.width * 0.02) - (backgroundRoot.mouseXRatio - 0.5) * 16 : -(parent.width * 0.02)
        y: backgroundRoot.enableParallax && !backgroundRoot.reducedMotion ? -(parent.height * 0.02) - (backgroundRoot.mouseYRatio - 0.5) * 12 : -(parent.height * 0.02)

        Behavior on x {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
        Behavior on y {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }

        // 1. Static fallback image (always loaded)
        Image {
            id: fallbackImage
            anchors.fill: parent
            source: backgroundRoot.resolveMediaUrl(backgroundRoot.imageSource)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: true
            smooth: true
        }

        // 2. Optional Video Player (loaded only when backgroundType === "video")
        Loader {
            id: videoLoader
            anchors.fill: parent
            active: (backgroundRoot.backgroundType === "video" && !backgroundRoot.videoFailed && backgroundRoot.videoSource !== "")
            sourceComponent: Component {
                Item {
                    anchors.fill: parent

                    MediaPlayer {
                        id: player
                        source: backgroundRoot.resolveMediaUrl(backgroundRoot.videoSource)
                        audioOutput: null
                        loops: MediaPlayer.Infinite
                        videoOutput: videoOut

                        onErrorOccurred: function(error, errorString) {
                            console.log("AoV SDDM Background Video Error:", error, errorString);
                            backgroundRoot.videoFailed = true;
                        }

                        onPlaybackStateChanged: function(state) {
                            if (state === MediaPlayer.StoppedState && !backgroundRoot.videoFailed) {
                                player.play();
                            }
                        }

                        Component.onCompleted: player.play()
                    }

                    VideoOutput {
                        id: videoOut
                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectCrop
                    }
                }
            }
        }
    }

    // 3. Subtle ambient cosmic vignette and lighting
    Rectangle {
        id: dimOverlayRect
        anchors.fill: parent
        color: "#070919"
        opacity: backgroundRoot.dimOpacity
    }

    // 4. Subtle bottom gradient for login buttons readability
    Rectangle {
        id: bottomGradient
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Math.max(160, parent.height * 0.35)
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: Qt.rgba(0.04, 0.06, 0.14, 0.40) }
            GradientStop { position: 1.0; color: Qt.rgba(0.04, 0.06, 0.14, 0.85) }
        }
    }

    // 5. Subtle top-left gradient for maintenance / info controls readability
    Rectangle {
        id: topLeftGradient
        anchors.left: parent.left
        anchors.top: parent.top
        width: Math.min(320, parent.width * 0.3)
        height: Math.min(320, parent.height * 0.35)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(0.04, 0.06, 0.14, 0.45) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
}
