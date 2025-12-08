import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

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
            id: marker

            width: parent.width
            anchors.bottom: parent.bottom
            color: parent.workspace.active ? root.colWhite : root.colPurple

            state: (parent.mouseOver || parent.workspace.focused) ? "in" : "out"
            states: [
                State {
                    name: "in"
                    PropertyChanges {
                        target: marker
                        height: 4
                    }
                },
                State {
                    name: "out"
                    PropertyChanges {
                        target: marker
                        height: 0
                    }
                }
            ]

            transitions: [
                Transition {
                    from: "out"
                    to: "in"
                    SequentialAnimation {
                        NumberAnimation {
                            target: marker
                            property: "height"
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                },

                Transition {
                    from: "in"
                    to: "out"
                    SequentialAnimation {
                        NumberAnimation {
                            target: marker
                            property: "height"
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            ]

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
