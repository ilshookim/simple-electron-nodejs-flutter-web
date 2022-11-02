import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'data.dart';

const csv =
'''
	series 1	series 2	series 3	series 4	series 5	series 6	series 7	series 8	series 9
1	1945	0	23.25	1832	1605	1941	129	141	1541
2	2012	67	90.25	1850	1608	1993	142	144	1544
3	2016	71	94.25	1854	1615	1906	138	139	1539
4	2015	70	93.25	1868	1609	2013	142	129	1529
5	2033	88	111.25	1858	1598	1468	129	142	1542
6	2034	89	112.25	1880	1606	2052	141	138	1538
7	2039	94	117.25	1898	1604	1494	145	142	1542
8	2012	67	90.25	1901	1624	1494	135	129	1529
9	1990	45	68.25	1918	1601	1498	131	141	1541
10	2002	57	80.25	1929	1594	1533	130	145	1545
11	2007	62	85.25	1956	1610	1488	140	135	1535
12	2032	87	110.25	1969	1608	1453	126	131	1531
13	2024	79	102.25	1986	1573	1488	136	130	1530
14	2011	66	89.25	1974	1597	1462	130	140	1540
15	2007	62	85.25	1950	1608	1465	133	126	1526
16	2024	79	102.25	1917	1614	1488	133	136	1536
17	2036	91	114.25	1920	1618	1434	130	130	1530
18	2037	92	115.25	1944	1629	1404	140	133	1533
19	2052	107	130.25	1923	1619	1439	147	133	1533
20	2105	160	183.25	1934	1625	1429	132	130	1530
21	2158	213	236.25	1938	1616	1460	134	140	1540
22	2223	278	301.25	1945	1609	1496	132	147	1547
23	2305	360	383.25	1946	1577	1495	150	132	1532
24	2376	431	454.25	1958	1619	1535	170	134	1534
25	2421	476	499.25	1970	1611	1562	180	132	1532
26	2469	524	547.25	1973	1636	1635	250	150	1541
27	2496	551	574.25	1948	1637	1728	512	170	1532
28	2536	591	614.25	1947	1649	1757	758	180	1549
29	2564	619	642.25	1946	1665	1802	1024	250	1556
30	2575	630	653.25	1925	1686	1825	1355	512	1557
31	2617	672	695.25	1941	1689	1911	1536	758	1577
32	2598	653	676.25	1946	1723	1922	1786	1024	1595
33	2653	708	731.25	1952	1676	1957	2048	1355	1659
34	2654	709	732.25	1952	1672	1933	3566	1536	1743
35	2570	625	648.25	1965	1683	1995	3578	1786	1877
36	2583	638	661.25	1979	1688	2003	4010	2048	2013
37	2606	661	684.25	1993	1692	2050	4022	3566	2162
38	2644	699	722.25	2033	1690	2055	4030	3578	2328
39	2639	694	717.25	2052	1692	2072	4031	4010	2457
40	2659	714	737.25	2080	1701	2079	4033	4022	2571
''';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

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
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 40, bottom: 40),
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            title: ChartTitle(text: _.pageReportDescription),
            legend: Legend(isVisible: data.reportLegend),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: sampleCSV(csv, marker: data.reportMarker, label: data.reportLabel),
          ),
        ),
    );
  }

  List<ChartSeries<double, String>> sampleCSV(csv, {marker = true, label = true}) {
    final List<List<dynamic>> raw = const CsvToListConverter(fieldDelimiter: '\t').convert(csv, eol: '\n');

    final List<String> names = [];
    final List<List<double>> samples = [];
    for (int i=0; i<raw.length; i++) {
      raw[i].removeAt(0);
      if (i == 0) {
        for (final series in raw[i]) {
          names.add(series.trim());
          samples.add([]);
        }
      } else {
        var j = 0;
        for (final value in raw[i]) {
          samples[j++].add(value);
        }
      }
    }

    final List<ChartSeries<double, String>> series = [];
    for (int i=0; i<samples.length; i++) {
      series.add(
        SplineSeries<double, String>(
          splineType: SplineType.natural,
          isVisibleInLegend: samples.isNotEmpty,
          name: names[i],
          dataSource: samples[i],
          xValueMapper: (sample, index) => '${index + 1}',
          yValueMapper: (sample, _) => sample,
          markerSettings: MarkerSettings(isVisible: marker),
          dataLabelSettings: DataLabelSettings(isVisible: label),
        ),
      );
    }
    return series;
  }
}
