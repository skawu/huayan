import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCharts 2.15

Item {
    id: barChart
    width: 400
    height: 300

    property string title: "Bar Chart"
    property string tagName: ""
    property var tagValue: null
    property var categories: ["Category 1", "Category 2", "Category 3", "Category 4"]
    property var values: [0, 0, 0, 0]
    property color barColor: "#4CAF50"
    property string xAxisTitle: "Category"
    property string yAxisTitle: "Value"
    property real yAxisMin: 0
    property real yAxisMax: 100

    // Update chart data based on tag value
    onTagValueChanged: {
        if (tagName !== "") {
            updateBarValue(Number(tagValue));
        }
    }

    function updateBarValue(value) {
        // Update the last bar value with new data
        if (values.length > 0) {
            values[values.length - 1] = value;
            // Shift values to the left
            for (let i = 0; i < values.length - 1; i++) {
                values[i] = values[i + 1];
            }
            // Set new value to the last position
            values[values.length - 1] = value;
            updateChart();
        }
    }

    function updateChart() {
        // Clear existing series data
        barSeries.clear();

        // Add new data points
        for (let i = 0; i < categories.length; i++) {
            barSeries.append(categories[i], values[i]);
        }
    }

    // Chart view
    ChartView {
        id: chartView
        anchors.fill: parent
        title: barChart.title
        antialiasing: true

        // Bar series
        BarSeries {
            id: barSeries
            name: tagName || "Value"

            // Bar set
            BarSet {
                id: barSet
                label: tagName || "Value"
                color: barColor
            }
        }

        // X axis
        CategoryAxis {
            id: xAxis
            categories: barChart.categories
            titleText: xAxisTitle
        }

        // Y axis
        ValueAxis {
            id: yAxis
            min: yAxisMin
            max: yAxisMax
            titleText: yAxisTitle
        }

        // Configure axes
        configureAxes: {
            barSeries.attachAxis(xAxis, Qt.Horizontal);
            barSeries.attachAxis(yAxis, Qt.Vertical);
        }
    }

    // Clear chart data
    function clearData() {
        values = Array(categories.length).fill(0);
        updateChart();
    }

    // Initialize chart
    Component.onCompleted: {
        // Set up initial chart
        chartView.title = title;
        updateChart();
    }
}
