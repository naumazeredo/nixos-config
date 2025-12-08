import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    // Theme colors
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#444b6a"
    property color colWhite: "#ffffff"
    property color colBlue: "#7aa2f7"
    property color colYellow: "#e0af68"
    property color colCyan: "#0db9d7"
    property color colPurple: "#ad8ee6"

    // Font
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    // System data
    property int cpuUsage: 0
    property int memUsage: 0
    property int volumeLevel: 0
    property bool volumeMuted: false
    property string debug: ""
    property string activeWindow: "Window"

    // CPU tracking
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar

            required property var modelData

            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: 30
            color: colBg

            RowLayout {
                anchors.fill: parent
                anchors.margins: 0
                //anchors.topMargin: 5
                //anchors.bottomMargin: 5
                spacing: 0

                Item { width: 4 }

                Repeater {
                    id: workspaceList
                    property var workspaces: Hyprland.workspaces.values.filter(ws => ws.monitor.name === bar.screen.name)
                    model: workspaces.length

                    Rectangle {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: parent.height
                        color: "transparent"

                        property var id: workspaceList.workspaces[index].id
                        property var workspace: Hyprland.workspaces.values.find(w => w.id === id) ?? null
                        property bool hasWindows: workspace !== null

                        property bool mouseOver: false

                        Rectangle {
                            width: parent.width
                            height: 4
                            anchors.bottom: parent.bottom
                            color: parent.workspace.focused ? root.colWhite : (parent.mouseOver ? root.colPurple : "transparent")

                            // Full border
                            //height: parent.height + 4
                            //color: "transparent"
                            //radius: 4
                            //border {
                            //    width: 1
                            //    color: parent.workspace.focused ? root.colWhite : (parent.mouseOver ? root.colPurple : "transparent")
                            //    pixelAligned: false
                            //}
                            //anchors.centerIn: parent
                        }

                        Text {
                            text: parent.workspace.name
                            color: parent.workspace.active ? root.colWhite: (hasWindows ? root.colBlue : root.colMuted)
                            anchors.centerIn: parent

                            font {
                                pixelSize: root.fontSize;
                                family: root.fontFamily
                                bold: parent.workspace.active || parent.mouseOver
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Hyprland.dispatch("workspace " + id)
                            onEntered: parent.mouseOver = true
                            onExited: parent.mouseOver = false
                        }
                    }
                }

                Rectangle {
                    color: root.colMuted
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 16
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                Text {
                    text: activeWindow
                    color: root.colPurple
                    font {
                        pixelSize: root.fontSize
                        family: root.fontFamily
                        bold: true
                    }
                    Layout.fillWidth: true
                    Layout.leftMargin: 4
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    text: "CPU " + cpuUsage + "%"
                    color: root.colYellow
                    font {
                        pixelSize: root.fontSize
                        family: root.fontFamily
                        bold: true
                    }
                }

                Rectangle {
                    color: root.colMuted
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 16
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                Text {
                    text: "Mem " + memUsage + " MBi"
                    color: root.colCyan
                    font {
                        pixelSize: root.fontSize
                        family: root.fontFamily
                        bold: true
                    }
                }

                Rectangle {
                    color: root.colMuted
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 16
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                Text {
                    text: volumeMuted ? "---  " : (volumeLevel + "% " + (volumeLevel < 50 ? " " : " "))
                    color: root.colPurple
                    font {
                        pixelSize: root.fontSize
                        family: root.fontFamily
                        bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        //onWheel: 
                    }

                    //"scroll-step": 1,
                    //"on-click": "pavucontrol"
                }


                Rectangle {
                    color: root.colMuted
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 16
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                Text {
                    property string format: "yyyy-MM-dd ddd HH:mm:ss"

                    id: clockText
                    text: Qt.formatDateTime(new Date(), format)
                    color: root.colCyan
                    font {
                        pixelSize: root.fontSize
                        family: root.fontFamily
                        bold: true
                    }

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clockText.text = Qt.formatDateTime(new Date(), parent.format)
                    }
                }

                Item { width: 4 }
            }
        }
    }

    // Active window title
    Process {
        id: windowProc
        command: ["sh", "-c", "hyprctl activewindow -j | grep '\"title\":'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var match = data.match(/"title":\s+"(.+)"/)
                if (match) {
                    activeWindow = match[1].trim()
                }
            }
        }
        Component.onCompleted: running = true
    }

    // CPU usage
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var user = parseInt(parts[1]) || 0
                var nice = parseInt(parts[2]) || 0
                var system = parseInt(parts[3]) || 0
                var idle = parseInt(parts[4]) || 0
                var iowait = parseInt(parts[5]) || 0
                var irq = parseInt(parts[6]) || 0
                var softirq = parseInt(parts[7]) || 0

                var total = user + nice + system + idle + iowait + irq + softirq
                var idleTime = idle + iowait

                if (lastCpuTotal > 0) {
                    var totalDiff = total - lastCpuTotal
                    var idleDiff = idleTime - lastCpuIdle
                    if (totalDiff > 0) {
                        cpuUsage = Math.round(100 * (totalDiff - idleDiff) / totalDiff)
                    }
                }
                lastCpuTotal = total
                lastCpuIdle = idleTime
            }
        }
        Component.onCompleted: running = true
    }

    // Memory usage
    Process {
        id: memProc
        command: ["sh", "-c", "free -m | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var parts = data.trim().split(/\s+/)
                var total = parseInt(parts[1]) || 1
                var used = parseInt(parts[2]) || 0
                memUsage = used
            }
        }
        Component.onCompleted: running = true
    }

    // Volume level
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                volumeMuted = data.indexOf("MUTED") !== -1
                var match = data.match(/Volume:\s*([\d.]+)(\s+[MUTED])?/)
                if (match) {
                    volumeLevel = Math.round(parseFloat(match[1]) * 100)
                }
            }
        }
    }

    // Timer for system stats
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
        }
    }

    // Timer for volume stats
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            volProc.running = true
        }
    }

    // Event-based updates for window/layout (instant)
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            windowProc.running = true
        }
    }

    // Backup timer for window/layout
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            windowProc.running = true
        }
    }
}
