import bb.cascades 1.2

Page {
    id: speakerSQLPage
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
    property int readSQL: 0
    property int writeSQL:0
    titleBar: TitleBar {
        title: "Speed Test JSON | SQL (Speaker)"
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
                text: "Read (ms)"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                horizontalAlignment: HorizontalAlignment.Center
                textStyle.fontWeight: FontWeight.Bold
            }
            Label {
                text: "Write (ms)"
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
                text: "SQL"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: navPane.colorSQL
            }
            Label {
                text: "JSON"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: navPane.colorJSON
            }
            Label {
                text: "SQL"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: navPane.colorSQL
            }
        } // end labelTopContainer
        Container {
            id: valueContainer
            topPadding: 10
            preferredHeight: speakerSQLPage.barHeight
            layout: StackLayout {
                orientation: LayoutOrientation.LeftToRight
            }
            attachedObjects: [
                LayoutUpdateHandler {
                    id: valueContainerLayoutHandler
                    onLayoutFrameChanged: {
                        speakerSQLPage.barHeight = layoutFrame.height
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
                id: readSQLValue
                background: navPane.colorSQL
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
                id: writeSQLValue
                background: navPane.colorSQL
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
                textStyle.fontSize: FontSize.XSmall
            }
            Label {
                id: readSQLValueLabel
                text: "0"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: navPane.colorSQL
                textStyle.fontSize: FontSize.XSmall
            }
            Label {
                id: writeJsonValueLabel
                text: "0"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: navPane.colorJSON
                textStyle.fontSize: FontSize.XSmall
            }
            Label {
                id: writeSQLValueLabel
                text: "0"
                layoutProperties: StackLayoutProperties {
                    spaceQuota: 1
                }
                textStyle.color: navPane.colorSQL
                textStyle.fontSize: FontSize.XSmall
            }
        } // end labelBottomContainer
    } // outerContainer
    // slot connected to signal from C++
    function compareValues(max, readJson, writeJson, readSQL, writeSQL) {
        // we store all the values as Page properties
        speakerSQLPage.max = max
        speakerSQLPage.readJson = readJson
        speakerSQLPage.writeJson = writeJson
        speakerSQLPage.readSQL = readSQL
        speakerSQLPage.writeSQL = writeSQL
        // now calculate the height of the Containers representing a Bar
        calculateBarChart()
        navPane.processFinished()
    }
    function calculateBarChart() {
        readJSONValue.preferredHeight = barHeight / max * readJson
        writeJSONValue.preferredHeight = barHeight / max * writeJson
        readSQLValue.preferredHeight = barHeight / max * readSQL
        writeSQLValue.preferredHeight = barHeight / max * writeSQL     
        readJsonValueLabel.text = readJson
        writeJsonValueLabel.text = writeJson
        readSQLValueLabel.text = readSQL
        writeSQLValueLabel.text = writeSQL
    }
    // called from NavigationPane onPopTransitionEnded
    function cleanup(){
        // disconnect the signal from C++ with the QML function
        app.speedTestSpeakerSQL.disconnect(compareValues)
    }
    onCreationCompleted: {
        // connect the signal from C++ with the QML function
        app.speedTestSpeakerSQL.connect(compareValues)
    }
}
