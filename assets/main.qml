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

NavigationPane {
    id: navPane
    attachedObjects: [
        SystemProgressToast {
            id: progressDialog
            body: "Read/Write 10'000 Addresses. Can take up to 2 Min"
            button.label: "Please Wait ..."
            button.enabled: true
        }
    ]
    Page {
        id: myPage
        // we start with a high value to let Cascades adjust this via LayoutUpdateHandler
        property int barHeight: 1200
        onBarHeightChanged: {
            // if the available height changes we have to recalculate
            // if there are already values
            if(max > 0){
                calculateBarChart()
            }
        }
        // color - creation is expensive
        // so colors should be re-used 
        property variant colorJSON: Color.DarkGreen
        property variant colorXML: Color.Red
        // store the last values to be able to re-calculate the height of bars if available space changes
        property int max: -1
        property int readJson: 0
        property int writeJson: 0
        property int readXml: 0
        property int writeXml: 0
        titleBar: TitleBar {
            title: "Speed Test JSON vs XML"
            // we want to see the value bars withour scrolling on Q10
            // so we have to set the title bar sticky
            scrollBehavior: TitleBarScrollBehavior.Sticky
        }
        attachedObjects: [
            OrientationHandler {
                onOrientationChanged: {
                    if (orientation == UIOrientation.Portrait){
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
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    progressDialog.body = "See results using Target File System Navigator"
                    progressDialog.show()
                    app.convertXMLtoJSONspeaker()
                    progressDialog.cancel()
                }
            },
            ActionItem {
                title: "Convert Addresses X2J"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    progressDialog.body = "See results using Target File System Navigator"
                    progressDialog.show()
                    app.convertXMLtoJSONAddresses()
                    progressDialog.cancel()
                }
            },
            ActionItem {
                title: "Convert Addresses J2X"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    progressDialog.body = "See results using Target File System Navigator"
                    progressDialog.show()
                    app.convertJSONtoXMLAddresses()
                    progressDialog.cancel()
                }
            },
            ActionItem {
                title: "Measure Addresses"
                imageSource: "asset:///images/stop_watch.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    progressDialog.body = "Read/Write 10'000 Addresses. Can take up to 2 Min"
                	progressDialog.show()
                    app.compareJSONandXML()
                }
            },
            ActionItem {
                title: "Measure Speaker"
                imageSource: "asset:///images/speaker.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    app.compareJSONandXMLspeaker()
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
                    textStyle.color: myPage.colorJSON
                }
                Label {
                    text: "XML"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: myPage.colorXML
                }
                Label {
                    text: "JSON"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: myPage.colorJSON
                }
                Label {
                    text: "XML"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: myPage.colorXML
                }
            } // end labelTopContainer
            Container {
                id: valueContainer
                topPadding: 10
                preferredHeight: myPage.barHeight
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                attachedObjects: [
                    LayoutUpdateHandler {
                        id: valueContainerLayoutHandler
                        onLayoutFrameChanged: {
                            myPage.barHeight = layoutFrame.height
                            console.log("BAR HEIGHT: "+myPage.barHeight)
                        }
                    }
                ]
                Container {
                    id: readJSONValue
                    background: myPage.colorJSON
                    rightMargin: 6
                    preferredHeight: 1
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    verticalAlignment: VerticalAlignment.Bottom
                }
                Container {
                    id: readXMLValue
                    background: myPage.colorXML
                    rightMargin: 6
                    preferredHeight: 1
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    verticalAlignment: VerticalAlignment.Bottom
                }
                Container {
                    id: writeJSONValue
                    background: myPage.colorJSON
                    rightMargin: 6
                    preferredHeight: 1
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    verticalAlignment: VerticalAlignment.Bottom
                }
                Container {
                    id: writeXMLNValue
                    background: myPage.colorXML
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
                    textStyle.color: myPage.colorJSON
                    textStyle.fontSize: FontSize.Small
                }
                Label {
                    id: readXmlValueLabel
                    text: "0"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: myPage.colorXML
                    textStyle.fontSize: FontSize.Small
                }
                Label {
                    id: writeJsonValueLabel
                    text: "0"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: myPage.colorJSON
                    textStyle.fontSize: FontSize.Small
                }
                Label {
                    id: writeXmlValueLabel
                    text: "0"
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                    textStyle.color: myPage.colorXML
                    textStyle.fontSize: FontSize.Small
                }
            } // end labelBottomContainer
        } // outerContainer
        // slot connected to signal from C++
        function compareValues(max, readJson, writeJson, readXml, writeXml) {
            // we store all the values as Page properties
            myPage.max = max
            myPage.readJson = readJson
            myPage.writeJson = writeJson
            myPage.readXml = readXml
            myPage.writeXml = writeXml
            // now calculate the height of the Containers representing a Bar
            calculateBarChart()
            progressDialog.cancel()
        }

        function calculateBarChart(){
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
            app.speedTest.connect(compareValues)
        }
    }    // end page

}// end navPane
