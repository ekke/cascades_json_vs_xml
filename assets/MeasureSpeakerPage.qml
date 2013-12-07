import bb.cascades 1.2

Page {
    id: measureSpeakerPage
    // we start with a high value to let Cascades adjust this via LayoutUpdateHandler
    property int barHeight: 1200
    onBarHeightChanged: {
        // if the available height changes we have to recalculate
        // if there are already values
        if(max > 0){
            calculateBarChart()
        }
    }
    // store the last values to be able to re-calculate the height of bars if available space changes
    property int max: -1
    property int readJson: 0
    property int readXml: 0
    property int readConvertedJson: 0
    titleBar: TitleBar {
        title: "Speed Test JSON vs XML (Speaker)"
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
            title: "Speaker SQL"
            enabled: ! navPane.running
            imageSource: "asset:///images/server.png"
            ActionBar.placement: ActionBarPlacement.OnBar
            onTriggered: {
                navPane.pushSpeakerSQL()
            }
        }
    ]
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
        } // end labelHeaderContainer
        Container {
            id: labelTopContainer
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
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
                text: "JSON v2"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: navPane.colorJSONc
            }
        } // end labelTopContainer
        Container {
            id: valueContainer
            topPadding: 10
            preferredHeight: measureSpeakerPage.barHeight
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            attachedObjects: [
                LayoutUpdateHandler {
                    id: valueContainerLayoutHandler
                    onLayoutFrameChanged: {
                        measureSpeakerPage.barHeight = layoutFrame.height
                        console.log("BAR HEIGHT: "+measureSpeakerPage.barHeight)
                    }
                }
            ]
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
                id: readJSONconvertedValue
                background: navPane.colorJSONc
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
                id: readXmlValueLabel
                text: "0"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: navPane.colorXML
                textStyle.fontSize: FontSize.Small
            }
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
                id: readJsonConvertedValueLabel
                text: "0"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: navPane.colorJSONc
                textStyle.fontSize: FontSize.Small
            }
        } // end labelBottomContainer
    } // outerContainer
    // slot connected to signal from C++
    function compareValues(max, readXML, readJson, readConvertedJson) {
        // we store all the values as Page properties
        measureSpeakerPage.max = max
        measureSpeakerPage.readJson = readJson
        measureSpeakerPage.readXml = readXML
        measureSpeakerPage.readConvertedJson = readConvertedJson
        // now calculate the height of the Containers representing a Bar
        calculateBarChart()
        navPane.processFinished()
    }
    
    function calculateBarChart(){
        readJSONValue.preferredHeight = barHeight / max * readJson
        readXMLValue.preferredHeight = barHeight / max * readXml
        readJSONconvertedValue.preferredHeight = barHeight / max * readConvertedJson
        readJsonValueLabel.text = readJson + " ms"
        readXmlValueLabel.text = readXml + " ms"
        readJsonConvertedValueLabel.text = readConvertedJson + " ms"
    }
    // called from NavigationPane onPopTransitionEnded
    function cleanup(){
        // disconnect the signal from C++ with the QML function
        app.speedTestSpeaker.disconnect(compareValues)
    }
    onCreationCompleted: {
        // connect the signal from C++ with the QML function
        app.speedTestSpeaker.connect(compareValues)
    }

}
