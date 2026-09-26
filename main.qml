import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    visible: true
    width: 700
    height: 800
    title: "Pro Calculator - Cross-Platform"
    color: "#e6e6eb"

    function getBtnColor(txt) {
        if (txt === "=" || txt === "+" || txt === "-" || txt === "*" || txt === "/") return "#E6FF9500";
        if (txt === "C") return "#CC969696";
        return "#D81E1E23";
    }

    // Animated Topographic Background
    Canvas {
        id: bgCanvas
        anchors.fill: parent
        property real time: 0

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.strokeStyle = "#4082828c"; 
            ctx.lineWidth = 1.5;

            var peaks = [ {x: width * 0.1, y: height * 0.1}, {x: width * 0.85, y: height * 0.85}, {x: width * 0.5, y: height * 1.4} ];
            var maxRadius = Math.sqrt(width * width + height * height) + 200;

            for (var p = 0; p < peaks.length; p++) {
                for (var r = 20; r < maxRadius; r += 45) {
                    ctx.beginPath();
                    var points = 80;
                    for (var i = 0; i <= points; i++) {
                        var angle = (i * 2 * Math.PI) / points;
                        var wobble1 = Math.sin(angle * 3 + time + p) * 15.0;
                        var wobble2 = Math.cos(angle * 5 - time * 0.8 + p * 2) * 10.0;
                        var actualR = r + wobble1 + wobble2;
                        var x = peaks[p].x + actualR * Math.cos(angle);
                        var y = peaks[p].y + actualR * Math.sin(angle);
                        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                    }
                    ctx.closePath();
                    ctx.stroke();
                }
            }
        }
        Timer { interval: 16; running: true; repeat: true; onTriggered: { bgCanvas.time += 0.015; bgCanvas.requestPaint(); } }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TabBar {
            id: bar
            Layout.fillWidth: true
            background: Rectangle { color: "#B3FFFFFF" }

            TabButton { text: "Standard" }
            TabButton { text: "Resistance" }
            TabButton { text: "Mesh KVL" }
            TabButton { text: "Matrices" }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: bar.currentIndex

            // ==========================================
            // TAB 1: Standard Calculator
            // ==========================================
            Item {
                ColumnLayout {
                    anchors.centerIn: parent
                    width: Math.min(parent.width * 0.9, 450)
                    height: Math.min(parent.height * 0.9, 600)
                    spacing: 15

                    TextField {
                        id: calcDisplay
                        Layout.fillWidth: true
                        Layout.preferredHeight: 90
                        text: "0"
                        font.pixelSize: 50
                        font.weight: Font.Light
                        horizontalAlignment: TextInput.AlignRight
                        readOnly: true
                        color: "#1c1c1e"
                        background: Rectangle { color: "#99FFFFFF"; border.color: "#66FFFFFF"; radius: 12 }
                    }

                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 4; rows: 4; rowSpacing: 10; columnSpacing: 10

                        Repeater {
                            model: ["7","8","9","/","4","5","6","*","1","2","3","-","C","0","=","+"]
                            delegate: Button {
                                required property string modelData
                                Layout.fillWidth: true; Layout.fillHeight: true
                                background: Rectangle { color: getBtnColor(modelData); radius: 15 }
                                contentItem: Text {
                                    text: modelData; color: "white"; font.pixelSize: 28; font.bold: true
                                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVerticalCenter
                                }
                                onClicked: {
                                    if (modelData === "C") calcDisplay.text = "0";
                                    else if (modelData >= "0" && modelData <= "9") calcDisplay.text = (calcDisplay.text === "0") ? modelData : calcDisplay.text + modelData;
                                    else calcDisplay.text += " " + modelData + " ";
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // TAB 2: Resistance Calculator
            // ==========================================
            ScrollView {
                contentWidth: availableWidth
                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: Math.max(20, (parent.height - implicitHeight) / 2)
                    width: Math.min(parent.width * 0.9, 600)
                    spacing: 25

                    Text { Layout.alignment: Qt.AlignHCenter; text: "Resistor Network Calculator"; color: "#1c1c1e"; font.pixelSize: 28; font.bold: true }
                    Text { Layout.alignment: Qt.AlignHCenter; text: "Enter up to 6 resistor values (leave unused blank):"; color: "#444"; font.pixelSize: 16 }

                    ComboBox {
                        id: resMode
                        Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 300; Layout.preferredHeight: 50
                        model: ["Series", "Parallel"]
                        contentItem: Text { text: parent.currentText; color: "white"; font.pixelSize: 18; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        background: Rectangle { color: "#D81E1E23"; radius: 10 }
                    }

                    GridLayout {
                        Layout.alignment: Qt.AlignHCenter
                        columns: 2; rowSpacing: 15; columnSpacing: 15

                        Repeater {
                            id: resRepeater
                            model: 6
                            TextField {
                                Layout.preferredWidth: 140; Layout.preferredHeight: 55
                                placeholderText: "R" + (index + 1) + " (Ω)"
                                color: "white"; font.pixelSize: 18; horizontalAlignment: TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter
                                background: Rectangle { color: "#D81E1E23"; radius: 10 }
                            }
                        }
                    }

                    Button {
                        Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 300; Layout.preferredHeight: 55
                        contentItem: Text { text: "Calculate Req"; color: "white"; font.pixelSize: 20; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        background: Rectangle { color: "#007aff"; radius: 10 }
                        onClicked: {
                            var vals = [];
                            for(var i=0; i<6; i++) { if (resRepeater.itemAt(i).text.trim() !== "") vals.push(resRepeater.itemAt(i).text); }
                            resResult.text = backend.calculateResistance(resMode.currentText, vals.join(","));
                        }
                    }

                    Text { id: resResult; Layout.alignment: Qt.AlignHCenter; text: "Req: 0 Ω"; color: "#007aff"; font.pixelSize: 26; font.bold: true }
                }
            }

            // ==========================================
            // TAB 3: Mesh KVL Solver
            // ==========================================
            ScrollView {
                contentWidth: availableWidth
                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: Math.max(20, (parent.height - implicitHeight) / 2)
                    width: Math.min(parent.width * 0.9, 600)
                    spacing: 25

                    Text { Layout.alignment: Qt.AlignHCenter; text: "3x3 Mesh Circuit Solver"; color: "#1c1c1e"; font.pixelSize: 28; font.bold: true }

                    Repeater {
                        id: meshRepeater
                        model: 3
                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            property int rowIdx: index
                            property alias r1: m0.text; property alias r2: m1.text; property alias r3: m2.text; property alias v: vBox.text
                            spacing: 10
                            
                            TextField { id: m0; Layout.preferredWidth: 80; Layout.preferredHeight: 50; placeholderText: "R" + (rowIdx+1) + "1"; font.pixelSize: 18; color: "white"; horizontalAlignment: TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { color: "#D81E1E23"; radius: 8 } }
                            TextField { id: m1; Layout.preferredWidth: 80; Layout.preferredHeight: 50; placeholderText: "R" + (rowIdx+1) + "2"; font.pixelSize: 18; color: "white"; horizontalAlignment: TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { color: "#D81E1E23"; radius: 8 } }
                            TextField { id: m2; Layout.preferredWidth: 80; Layout.preferredHeight: 50; placeholderText: "R" + (rowIdx+1) + "3"; font.pixelSize: 18; color: "white"; horizontalAlignment: TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { color: "#D81E1E23"; radius: 8 } }
                            Text { text: "="; color: "#1c1c1e"; font.pixelSize: 24; font.bold: true }
                            TextField { id: vBox; Layout.preferredWidth: 80; Layout.preferredHeight: 50; placeholderText: "V" + (rowIdx+1); font.pixelSize: 18; color: "white"; horizontalAlignment: TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter; background: Rectangle { color: "#D81E1E23"; radius: 8 } }
                        }
                    }

                    Button {
                        Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 350; Layout.preferredHeight: 55
                        contentItem: Text { text: "Solve Currents"; color: "white"; font.pixelSize: 20; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        background: Rectangle { color: "#007aff"; radius: 10 }
                        onClicked: {
                            var rMat = []; var vVec = [];
                            for(var i=0; i<3; i++) {
                                var row = meshRepeater.itemAt(i);
                                rMat.push([parseFloat(row.r1)||0, parseFloat(row.r2)||0, parseFloat(row.r3)||0]);
                                vVec.push(parseFloat(row.v)||0);
                            }
                            meshResult.text = backend.calculateMesh(rMat, vVec);
                        }
                    }

                    Text { id: meshResult; Layout.alignment: Qt.AlignHCenter; text: "Currents will appear here..."; color: "#007aff"; font.pixelSize: 22; font.bold: true }
                }
            }

            // ==========================================
            // TAB 4: Matrices
            // ==========================================
            ScrollView {
                contentWidth: availableWidth
                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: Math.max(20, (parent.height - implicitHeight) / 2)
                    width: Math.min(parent.width * 0.95, 700)
                    spacing: 25

                    Text { Layout.alignment: Qt.AlignHCenter; text: "Matrix Operations"; color: "#1c1c1e"; font.pixelSize: 28; font.bold: true }

                    Flow {
                        Layout.fillWidth: true; Layout.alignment: Qt.AlignHCenter
                        spacing: 40
                        
                        ColumnLayout {
                            spacing: 15
                            Text { Layout.alignment: Qt.AlignHCenter; text: "Matrix A (3x3)"; color: "#1c1c1e"; font.pixelSize: 18; font.bold: true }
                            GridLayout {
                                columns: 3; rowSpacing: 10; columnSpacing: 10
                                Repeater {
                                    id: repA
                                    model: 9
                                    TextField {
                                        Layout.preferredWidth: 80; Layout.preferredHeight: 55
                                        placeholderText: "a" + (Math.floor(index/3)+1) + ((index%3)+1)
                                        color: "white"; font.pixelSize: 18; horizontalAlignment: TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter
                                        background: Rectangle { color: "#D81E1E23"; radius: 8 }
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            spacing: 15
                            Text { Layout.alignment: Qt.AlignHCenter; text: "Matrix B (3x3)"; color: "#1c1c1e"; font.pixelSize: 18; font.bold: true }
                            GridLayout {
                                columns: 3; rowSpacing: 10; columnSpacing: 10
                                Repeater {
                                    id: repB
                                    model: 9
                                    TextField {
                                        Layout.preferredWidth: 80; Layout.preferredHeight: 55
                                        placeholderText: "b" + (Math.floor(index/3)+1) + ((index%3)+1)
                                        color: "white"; font.pixelSize: 18; horizontalAlignment: TextInput.AlignHCenter; verticalAlignment: TextInput.AlignVCenter
                                        background: Rectangle { color: "#D81E1E23"; radius: 8 }
                                    }
                                }
                            }
                        }
                    }

                    ComboBox {
                        id: matOp
                        Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 400; Layout.preferredHeight: 50
                        model: ["Add (A + B)", "Subtract (A - B)", "Multiply (A * B)", "Determinant of Matrix A", "Determinant of Matrix B"]
                        contentItem: Text { text: parent.currentText; color: "white"; font.pixelSize: 18; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        background: Rectangle { color: "#D81E1E23"; radius: 10 }
                    }

                    Button {
                        Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 400; Layout.preferredHeight: 55
                        contentItem: Text { text: "Compute Matrix"; color: "white"; font.pixelSize: 20; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        background: Rectangle { color: "#007aff"; radius: 10 }
                        onClicked: {
                            var matA = [[0,0,0],[0,0,0],[0,0,0]]; var matB = [[0,0,0],[0,0,0],[0,0,0]];
                            for(var i=0; i<9; i++) {
                                var r = Math.floor(i/3); var c = i%3;
                                matA[r][c] = parseFloat(repA.itemAt(i).text) || 0;
                                matB[r][c] = parseFloat(repB.itemAt(i).text) || 0;
                            }
                            matrixResult.text = backend.calculateMatrix(matA, matB, matOp.currentIndex);
                        }
                    }

                    Text { id: matrixResult; Layout.alignment: Qt.AlignHCenter; text: "Result:"; color: "#007aff"; font.pixelSize: 22; font.family: "Monospace"; font.bold: true }
                }
            }
        }
    }
}
