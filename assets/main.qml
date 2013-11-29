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

Page {
    property int barHeight: 900
    property variant colorJSON: Color.Green
    property variant colorXML: Color.Red
    actions: [
        ActionItem {
            title: "Convert Speaker"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                app.convertXMLtoJSONspeaker()
            }
        },
        ActionItem {
            title: "Convert Addresses X2J"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                app.convertXMLtoJSONAddresses()
            }
        },
        ActionItem {
            title: "Convert Addresses J2X"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                app.convertJSONtoXMLAddresses()
            }
        },
        ActionItem {
            title: "Compare J and X"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                app.compareJSONandXML()
            }
        },
        ActionItem {
            title: "Compare Speaker"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                app.compareJSONandXMLspeaker()
            }
        }
    ] // end actions
    Container {
        id: outerContainer
        leftPadding: 40
        rightPadding: 40
        
        layout: StackLayout {
            orientation: LayoutOrientation.TopToBottom
        }
        Label {
            text: qsTr("Speed test") + Retranslate.onLocaleOrLanguageChanged
            textStyle.base: SystemDefaults.TextStyles.BigText
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
                textStyle.color: colorJSON
            }
            Label {
                text: "XML"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: colorXML
            }
            Label {
                text: "JSON"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: colorJSON
            }
            Label {
                text: "XML"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: colorXML
            }
        } // end labelTopContainer
        Container {
            id: valueContainer
            topPadding: 20
            preferredHeight: barHeight
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            Container {
                id: readJSONValue
                background: colorJSON
                preferredHeight: 1
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                verticalAlignment: VerticalAlignment.Bottom
            }
            Container {
                id: readXMLValue
                background: colorXML
                preferredHeight: 1
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                verticalAlignment: VerticalAlignment.Bottom
            }
            Container {
                id: writeJSONValue
                background: colorJSON
                preferredHeight: 1
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                verticalAlignment: VerticalAlignment.Bottom
            }
            Container {
                id: writeXMLNValue
                background: colorXML
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
            Label {
                id: readJsonValueLabel
                text: "0"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: colorJSON
            }
            Label {
                id: readXmlValueLabel
                text: "0"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: colorXML
            }
            Label {
                id: writeJsonValueLabel
                text: "0"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: colorJSON
            }
            Label {
                id: writeXmlValueLabel
                text: "0"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: colorXML
            }
        } // end labelBottomContainer
    } // outerContainer
    function compareValues(max, readJson, writeJson, readXml, writeXml){
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
} // end page