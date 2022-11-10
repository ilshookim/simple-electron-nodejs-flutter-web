import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'data.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with AutomaticKeepAliveClientMixin {
  bool visibility = true;
  num? visibleSeriesIndex;

  @override
  bool get wantKeepAlive => true;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    final _ = AppLocalizations.of(context)!;
    final data = Provider.of<Data>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_.pageReportTitle),
        actions: [
          Tooltip(
            message: _.pageReportShowHide,
            child: Checkbox(
              value: data.reportLabel,
              onChanged: (value) {
                if (value != null) data.reportLabel = value;
              },
            ),
          ),
          Center(child: Text(_.pageReportLabel)),
          const VerticalDivider(),
          Tooltip(
            message: _.pageReportShowHide,
            child: Checkbox(
              value: data.reportMarker,
              onChanged: (value) {
                if (value != null) data.reportMarker = value;
              },
            ),
          ),
          Center(child: Text(_.pageReportMarker)),
          const VerticalDivider(),
          Tooltip(
            message: _.pageReportShowHide,
            child: Checkbox(
              value: data.reportLegend,
              onChanged: (value) {
                if (value != null) data.reportLegend = value;
              },
            ),
          ),
          Center(child: Text(_.pageReportLegend)),
          const VerticalDivider(),
          const VerticalDivider(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 40),
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          tooltipBehavior: TooltipBehavior(enable: true),
          title: ChartTitle(text: data.reportName.isEmpty ? _.pageReportDescription : data.reportName),
          series: onSeries(data),
          legend: onLegend(data),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: _.pageReportOpenCSV,
        label: Text(_.pageReportOpenCSV),
        icon: const Icon(Icons.description),
        isExtended: data.reportTitles.isEmpty || data.demoReport,
        extendedPadding: const EdgeInsetsDirectional.only(start: 20, end: 20),
        onPressed: () async {
          FilePickerResult? picked = await FilePicker.platform.pickFiles();
          if (picked != null) {
            Uint8List? fileBytes = picked.files.first.bytes;
            String fileName = picked.files.first.name;
            if (fileBytes != null) {
              data.importReportFromBytes(fileBytes, fileName);
            }
          }
        },
      ),
    );
  }

  List<ChartSeries<double, String>> onSeries(data) {
    final List<ChartSeries<double, String>> series = [];
    for (int i=0; i<data.reportSeries.length; i++) {
      series.add(
        SplineSeries<double, String>(
          splineType: SplineType.natural,
          isVisibleInLegend: data.reportSeries[i].isNotEmpty,
          name: data.reportTitles[i],
          dataSource: data.reportSeries[i],
          xValueMapper: (sample, index) => '${index + 1}',
          yValueMapper: (sample, _) => sample,
          markerSettings: MarkerSettings(isVisible: data.reportMarker, width: 4, height: 4),
          dataLabelSettings: DataLabelSettings(isVisible: data.reportLabel),
          isVisible: visibleSeriesIndex == null || visibleSeriesIndex == i ? true : visibility,
        ),
      );
    }
    return series;
  }

  onLegend(data) {
    return Legend(
      isVisible: data.reportLegend,
      toggleSeriesVisibility: true,
    );
  }
}
