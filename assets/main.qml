/*
 * Copyright (c) 2011-2013 BlackBerry Limited.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 * http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import bb.cascades 1.2
import bb.system 1.2
import my.library 1.0

NavigationPane {
    id: navPane
    // color - creation is expensive
    // so colors should be re-used
    property variant colorJSON: Color.DarkGreen
    property variant colorJSONc: Color.Magenta
    property variant colorXML: Color.Red
    property bool running: false
    attachedObjects: [
        SystemToast {
            id: infoToast
            icon: "asset:///images/stop_watch.png"
            body: "Read/Write 10'000 Addresses: up to 2 Min"
            button.label: "Please Wait ..."
            button.enabled: true
        },
        ComponentDefinition {
            id: measureSpeakerPageComponent
            source: "MeasureSpeakerPage.qml"
        },
        QTimer {
            id: myTimer
            property int usecase
            interval: 100
            singleShot: true
            onTimeout: {
                switch (myTimer.usecase) {
                    case 0:
                        app.compareJSONandXMLaddresses()
                        return
                    case 1:
                        app.compareJSONandXMLspeaker()
                        return
                    case 2:
                        app.convertXMLtoJSONspeaker()
                        return
                    case 3:
                        app.convertXMLtoJSONAddresses()
                        return
                    case 4:
                        app.convertJSONtoXMLAddresses()
                        return
                    default:
                        return
                }
            }
        }
    ]
    Page {
        id: measureAddressesPage
        // we start with a high value to let Cascades adjust this via LayoutUpdateHandler
        property int barHeight: 1200
        onBarHeightChanged: {
            // if the available height changes we have to recalculate
            // if there are already values
            if (max > 0) {
                calculateBarChart()
            }
        }
        // store the last values to be able to re-calculate the height of bars if available space changes
        property int max: -1
        property int readJson: 0
        property int writeJson: 0
        property int readXml: 0
        property int writeXml: 0
        titleBar: TitleBar {
            title: "Speed Test JSON vs XML (Addresses)"
            // we want to see the value bars withour scrolling on Q10
            // so we have to set the title bar sticky
            scrollBehavior: TitleBarScrollBehavior.Sticky
        }
        attachedObjects: [
            OrientationHandler {
                onOrientationChanged: {
                    if (orientation == UIOrientation.Portrait) {
                        // setting the preffered height to a high number
                        // will cause the LayoutUpdateHandler to change the height
                        // if coming from Landscape
                        // setting prefferedHeight to a high volume means
                        // Cascades will try to assign this value or less if it doesn't fit into the visible area
                        valueContainer.preferredHeight = 1200
                    }
                }
            }
        ]
        actions: [
            ActionItem {
                title: "Convert Speaker"
                enabled: ! navPane.running
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    navPane.running = true
                    infoToast.body = "See results using Target File System Navigator"
                    infoToast.show()
                    myTimer.usecase = 2
                    activityIndicator.start()
                    myTimer.start()
                }
            },
            ActionItem {
                title: "Convert Addresses X2J"
                enabled: ! navPane.running
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    navPane.running = true
                    infoToast.body = "See results using Target File System Navigator"
                    infoToast.show()
                    myTimer.usecase = 3
                    activityIndicator.start()
                    myTimer.start()
                }
            },
            ActionItem {
                title: "Convert Addresses J2X"
                enabled: ! navPane.running
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    navPane.running = true
                    infoToast.body = "See results using Target File System Navigator"
                    infoToast.show()
                    myTimer.usecase = 4
                    activityIndicator.start()
                    myTimer.start()
                }
            },
            ActionItem {
                id: me
                title: "Measure Addresses"
                enabled: ! navPane.running
                imageSource: "asset:///images/stop_watch.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    navPane.running = true
                    infoToast.body = "Read/Write 10'000 Addresses: up to 2 Min"
                    infoToast.show()
                    myTimer.usecase = 0
                    activityIndicator.start()
                    myTimer.start()
                }
            },
            ActionItem {
                title: "Measure Speaker"
                enabled: ! navPane.running
                imageSource: "asset:///images/speaker.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    navPane.running = true
                    var page = measureSpeakerPageComponent.createObject(navPane)
                    navPane.push(page)
                    infoToast.body = "Read/Write/Convert 119 Speakers"
                    infoToast.show()
                    myTimer.usecase = 1
                    activityIndicator.start()
                    myTimer.start()
                }
            }
        ] // end actions
        Container {
            id: outerContainer
            leftPadding: 40
            rightPadding: 34
            layout: StackLayout {
                orientation: LayoutOrientation.TopToBottom
            }
            ActivityIndicator {
                id: activityIndicator
            }
            attachedObjects: [
                LayoutUpdateHandler {
                    id: outerContainerLayoutHandler
                    onLayoutFrameChanged: {
                        // this will trigger the valueContainerLayoutHandler
                        // to get all available space
                        // per ex. after stopping the ActivityIndicator 
                        valueContainer.preferredHeight = 1200
                    }
                }
            ]
            Container {
                id: labelHeaderContainer
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    // in a real world application all Strings should be translated
                    text: "Read"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    horizontalAlignment: HorizontalAlignment.Center
                    textStyle.fontWeight: FontWeight.Bold
                }
                Label {
                    text: "Write"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    horizontalAlignment: HorizontalAlignment.Center
                    textStyle.fontWeight: FontWeight.Bold
                }
            } // end labelHeaderContainer
            Container {
                id: labelTopContainer
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    text: "JSON"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: navPane.colorJSON
                }
                Label {
                    text: "XML"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: navPane.colorXML
                }
                Label {
                    text: "JSON"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: navPane.colorJSON
                }
                Label {
                    text: "XML"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: navPane.colorXML
                }
            } // end labelTopContainer
            Container {
                id: valueContainer
                topPadding: 10
                preferredHeight: measureAddressesPage.barHeight
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                attachedObjects: [
                    LayoutUpdateHandler {
                        id: valueContainerLayoutHandler
                        onLayoutFrameChanged: {
                            measureAddressesPage.barHeight = layoutFrame.height
                            console.log("BAR HEIGHT: " + measureAddressesPage.barHeight)
                        }
                    }
                ]
                Container {
                    id: readJSONValue
                    background: navPane.colorJSON
                    rightMargin: 6
                    preferredHeight: 1
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    verticalAlignment: VerticalAlignment.Bottom
                }
                Container {
                    id: readXMLValue
                    background: navPane.colorXML
                    rightMargin: 6
                    preferredHeight: 1
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    verticalAlignment: VerticalAlignment.Bottom
                }
                Container {
                    id: writeJSONValue
                    background: navPane.colorJSON
                    rightMargin: 6
                    preferredHeight: 1
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    verticalAlignment: VerticalAlignment.Bottom
                }
                Container {
                    id: writeXMLNValue
                    background: navPane.colorXML
                    rightMargin: 6
                    preferredHeight: 1
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    verticalAlignment: VerticalAlignment.Bottom
                }
            } // end valueContainer
            Container {
                id: labelBottomContainer
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                bottomPadding: 10
                Label {
                    id: readJsonValueLabel
                    text: "0"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: navPane.colorJSON
                    textStyle.fontSize: FontSize.Small
                }
                Label {
                    id: readXmlValueLabel
                    text: "0"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: navPane.colorXML
                    textStyle.fontSize: FontSize.Small
                }
                Label {
                    id: writeJsonValueLabel
                    text: "0"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: navPane.colorJSON
                    textStyle.fontSize: FontSize.Small
                }
                Label {
                    id: writeXmlValueLabel
                    text: "0"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: navPane.colorXML
                    textStyle.fontSize: FontSize.Small
                }
            } // end labelBottomContainer
        } // outerContainer
        // slot connected to signal from C++
        function compareValues(max, readJson, writeJson, readXml, writeXml) {
            // we store all the values as Page properties
            measureAddressesPage.max = max
            measureAddressesPage.readJson = readJson
            measureAddressesPage.writeJson = writeJson
            measureAddressesPage.readXml = readXml
            measureAddressesPage.writeXml = writeXml
            // now calculate the height of the Containers representing a Bar
            calculateBarChart()
            navPane.processFinished()
        }
        function calculateBarChart() {
            readJSONValue.preferredHeight = barHeight / max * readJson
            writeJSONValue.preferredHeight = barHeight / max * writeJson
            readXMLValue.preferredHeight = barHeight / max * readXml
            writeXMLNValue.preferredHeight = barHeight / max * writeXml
            readJsonValueLabel.text = readJson + " ms"
            writeJsonValueLabel.text = writeJson + " ms"
            readXmlValueLabel.text = readXml + " ms"
            writeXmlValueLabel.text = writeXml + " ms"
        }
        onCreationCompleted: {
            // connect the signal from C++ with the QML function
            app.speedTestAddresses.connect(compareValues)
        }
    } // end page
    // cancels the progress, also called from pushed Page
    function processFinished() {
        infoToast.cancel()
        activityIndicator.stop()
        navPane.running = false
        switch (myTimer.usecase) {
            case 0:
                // nothing to do - we have the bars
                return
            case 1:
                // nothing to do - we have the bars
                return
            case 2:
                // app.convertXMLtoJSONspeaker()
                return
            case 3:
                // app.convertXMLtoJSONAddresses()
                return
            case 4:
                // app.convertJSONtoXMLAddresses()
                return
            default:
                return
        }
    }
    onPopTransitionEnded: {
        page.destroy()
    }
    onCreationCompleted: {
        app.conversionDone.connect(processFinished)
    }
}// end navPane
