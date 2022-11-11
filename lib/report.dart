import 'dart:typed_data';

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
      body: HorizontalSplitter(
        ratio: 0.5,
        upper: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          tooltipBehavior: TooltipBehavior(enable: true),
          title: ChartTitle(text: data.reportName.isEmpty ? _.pageReportDescription : data.reportName),
          series: onSeries(data),
          legend: onLegend(data),
        ),
        lower: data.reportSeries.isEmpty
          ? Center(child: Text(_.pageReportNoData))
          : ScrollableDataTable<double>(
            series: data.reportSeries,
            rows: data.reportTitles,
            columns: List.generate(40, (index) => '${index + 1}'),
            builder: <T>(data) => Container(alignment: Alignment.centerRight, child: Text('$data'))),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: FloatingActionButton.extended(
        tooltip: _.pageReportLoadFile,
        label: Text(_.pageReportLoadFile),
        icon: const Icon(Icons.description),
        isExtended: data.reportTitles.isEmpty || data.demoReport,
        extendedPadding: const EdgeInsetsDirectional.only(start: 20, end: 20),
        backgroundColor: Colors.blue.shade300.withOpacity(0.75),
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

class ScrollableDataTable<T> extends StatefulWidget {
  final List<List<T>> series;
  final List<String> rows;
  final List<String> columns;
  final Widget Function(T data) builder;
  final double columnWidth;
  final double cellWidth;
  final double cellHeight;
  final double cellMargin;
  final double cellSpacing;

  const ScrollableDataTable({
    required this.series,
    required this.rows,
    required this.columns,
    required this.builder,
    this.columnWidth = 90,
    this.cellHeight = 30,
    this.cellWidth = 60,
    this.cellMargin = 10,
    this.cellSpacing = 8,
    super.key,
  });

  @override
  State<ScrollableDataTable> createState() => ScrollableDataTableState();
}

class ScrollableDataTableState<T> extends State<ScrollableDataTable<T>> {
  final _yController = ScrollController();
  final _xController = ScrollController();
  final _tableYController = ScrollController();
  final _tableXController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tableXController.addListener(() => _xController.jumpTo(_tableXController.position.pixels));
    _tableYController.addListener(() => _yController.jumpTo(_tableYController.position.pixels));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(
          children: <Widget>[
            SingleChildScrollView(
              controller: _yController,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              child: onRows(),
            ),
            Flexible(
              child: Scrollbar(
                controller: _tableXController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _tableXController,
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _tableYController,
                    scrollDirection: Axis.vertical,
                    child: onDataTable(),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            onCorner(),
            Flexible(
              child: SingleChildScrollView(
                controller: _xController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: onColumns(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  onCorner() => Material(
    child: DataTable(
      horizontalMargin: widget.cellMargin,
      columnSpacing: widget.cellSpacing,
      headingRowHeight: widget.cellHeight,
      dataRowHeight: widget.cellHeight,
      columns: [DataColumn(label: SizedBox(width: widget.columnWidth, child: const Text('')))],
      rows: const []),
  );

  onColumns() => Material(
    color: Colors.grey[100],
    child: DataTable(
        horizontalMargin: widget.cellMargin,
        columnSpacing: widget.cellSpacing,
        headingRowHeight: widget.cellHeight,
        dataRowHeight: widget.cellHeight,
        columns: widget.columns
            .map((c) => DataColumn(label: SizedBox(width: widget.cellWidth, child: Container(alignment: Alignment.centerRight, child: Text(c)))))
            .toList(),
        rows: const []),
  );

  onRows() => Material(
    child: DataTable(
      horizontalMargin: widget.cellMargin,
      columnSpacing: widget.cellSpacing,
      headingRowHeight: widget.cellHeight,
      dataRowHeight: widget.cellHeight,
      columns: [
        DataColumn(label: SizedBox(width: widget.columnWidth, child: Center(child: Text(widget.rows.first))))
      ],
      rows: widget.rows
        .sublist(0)
        .map((c) => DataRow(cells: [DataCell(SizedBox(width: widget.columnWidth, child: Center(child: Text(c))))]))
        .toList()),
  );

  onDataTable() => Material(
    child: DataTable(
      horizontalMargin: widget.cellMargin,
      columnSpacing: widget.cellSpacing,
      headingRowHeight: widget.cellHeight,
      dataRowHeight: widget.cellHeight,
      columns: widget.series.first
        .map((c) => DataColumn(label: SizedBox(width: widget.cellWidth, child: Text('$c'))))
        .toList(),
      rows: widget.series
        .sublist(0)
        .map((row) => DataRow(cells: row.map((c) => DataCell(onBuildData(widget.cellWidth, c))).toList()))
        .toList()));

  onBuildData(double width, T data) => SizedBox(
      width: width,
      child: widget.builder.call(data));
}

class HorizontalSplitter extends StatefulWidget {
  final Widget upper;
  final Widget lower;
  final double ratio;

  const HorizontalSplitter({required this.upper, required this.lower, this.ratio = 0.5, super.key});

  @override
  State<HorizontalSplitter> createState() => _HorizontalSplitterState();
}

class _HorizontalSplitterState extends State<HorizontalSplitter> {
  final _dividerHeight = 16.0;
  final _minHeight = 80.0;

  late double _ratio;
  late double _height;

  get _upperHeight => _ratio * _height;
  get _lowerHeight => (1 - _ratio) * _height;

  @override
  void initState() {
    super.initState();
    _ratio = widget.ratio;
    _height = 0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      assert(_ratio <= 1);
      assert(_ratio >= 0);
      if (_height == 0) _height = constraints.maxHeight - _dividerHeight;
      if (_height != constraints.maxHeight) {
        _height = constraints.maxHeight - _dividerHeight;
      }

      return SizedBox(
        height: constraints.maxHeight,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: _upperHeight,
              child: widget.upper,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeUpDown,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: _dividerHeight,
                  child: Divider(
                    indent: 20,
                    endIndent: 20,
                    thickness: 5,
                    height: _dividerHeight,
                    color: Colors.blue,
                  ),
                ),
              ),
              onPanUpdate: (DragUpdateDetails details) {
                if (_upperHeight < _minHeight && details.delta.dy < 0) return;
                if (_lowerHeight < _minHeight && details.delta.dy > 0) return;
                setState(() {
                  _ratio += details.delta.dy / _height;
                  if (_ratio > 1) {
                    _ratio = 1;
                  } else if (_ratio < 0.0) {
                    _ratio = 0.0;
                  }
                });
              },
            ),
            SizedBox(
              height: _lowerHeight,
              child: widget.lower,
            ),
          ],
        ),
      );
    });
  }
}
