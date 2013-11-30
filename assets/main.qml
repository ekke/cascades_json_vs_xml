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
NavigationPane {
    id: navPane
    Page {
        id: myPage
        property int barHeight: 1200
        onBarHeightChanged: {
            if(max > 0){
                calculateBarChart()
            }
        }
        property variant colorJSON: Color.DarkGreen
        property variant colorXML: Color.Red
        property int max: -1
        property int readJson: 0
        property int writeJson: 0
        property int readXml: 0
        property int writeXml: 0
        titleBar: TitleBar {
            title: "Speed Test JSON vs XML"
            scrollBehavior: TitleBarScrollBehavior.Sticky
        }
        attachedObjects: [
            OrientationHandler {
                onOrientationChanged: {
                    if (orientation == UIOrientation.Portrait){
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
                    app.convertXMLtoJSONspeaker()
                }
            },
            ActionItem {
                title: "Convert Addresses X2J"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    app.convertXMLtoJSONAddresses()
                }
            },
            ActionItem {
                title: "Convert Addresses J2X"
                ActionBar.placement: ActionBarPlacement.InOverflow
                onTriggered: {
                    app.convertJSONtoXMLAddresses()
                }
            },
            ActionItem {
                title: "Compare J vs X"
                imageSource: "asset:///images/stop_watch.png"
                ActionBar.placement: ActionBarPlacement.OnBar
                onTriggered: {
                    app.compareJSONandXML()
                }
            },
            ActionItem {
                title: "Compare Speaker"
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
        function compareValues(max, readJson, writeJson, readXml, writeXml) {
            myPage.max = max
            myPage.readJson = readJson
            myPage.writeJson = writeJson
            myPage.readXml = readXml
            myPage.writeXml = writeXml
            calculateBarChart()
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
            app.speedTest.connect(compareValues)
        }
    }    // end page
}// end navPane
