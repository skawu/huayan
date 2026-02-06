import QtQuick 2.15
import QtQuick.Controls 2.15
import QtCharts 2.15

Item {
    id: trendChart
    width: 400
    height: 300

    property string title: "Trend Chart"
    property string tagName: ""
    property var tagValue: null
    property int maxDataPoints: 100
    property color lineColor: "#2196F3"
    property string xAxisTitle: "Time"
    property string yAxisTitle: "Value"
    property real yAxisMin: 0
    property real yAxisMax: 100

    // Chart data
    property var chartData: []

    // Update chart data based on tag value
    onTagValueChanged: {
        if (tagName !== "") {
            addDataPoint(Number(tagValue));
        }
    }

    function addDataPoint(value) {
        // Add new data point with timestamp
        const timestamp = new Date().toLocaleTimeString();
        chartData.push({ timestamp: timestamp, value: value });

        // Limit data points
        if (chartData.length > maxDataPoints) {
            chartData.shift();
        }

        // Update chart series
        updateChart();
    }

    function updateChart() {
        // Clear existing series data
        lineSeries.clear();

        // Add new data points
        for (let i = 0; i < chartData.length; i++) {
            lineSeries.append(i, chartData[i].value);
        }
    }

    // Chart view
    ChartView {
        id: chartView
        anchors.fill: parent
        title: trendChart.title
        antialiasing: true

        // Line series
        LineSeries {
            id: lineSeries
            name: tagName || "Value"
            color: lineColor
            width: 2

            // Line series points
            pointLabelsVisible: false
        }

        // X axis
        ValueAxis {
            id: xAxis
            min: 0
            max: Math.max(10, chartData.length - 1)
            titleText: xAxisTitle
            labelFormat: "%.0f"
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
            lineSeries.attachAxis(xAxis, Qt.Horizontal);
            lineSeries.attachAxis(yAxis, Qt.Vertical);
        }
    }

    // Clear chart data
    function clearData() {
        chartData = [];
        lineSeries.clear();
    }

    // Initialize chart
    Component.onCompleted: {
        // Set up initial chart
        chartView.title = title;
    }
}
