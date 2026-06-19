import 'track_models.dart';

class SectorCatalog {
  static const List<SectorDef> all = [
    SectorDef('EDYY', 'Europe', 'Maastricht Upper Area', [
      SectorFix('RKN', -0.7, -0.6),
      SectorFix('NVO', 0.55, -0.7),
      SectorFix('SONEB', 0.7, 0.4),
      SectorFix('LUKOR', -0.5, 0.65),
      SectorFix('DENUT', 0.0, 0.0),
    ]),
    SectorDef('LFEE', 'Europe', 'Reims Control', [
      SectorFix('MOROK', -0.6, -0.5),
      SectorFix('OLINO', 0.6, -0.5),
      SectorFix('VEDUS', 0.5, 0.6),
      SectorFix('TINIL', -0.65, 0.5),
      SectorFix('EPL', 0.05, 0.1),
    ]),
    SectorDef('KZNY', 'US East', 'New York Center', [
      SectorFix('MERIT', -0.7, -0.4),
      SectorFix('GREKI', 0.5, -0.65),
      SectorFix('BETTE', 0.7, 0.5),
      SectorFix('ROBER', -0.45, 0.6),
      SectorFix('DPK', 0.0, -0.05),
    ]),
    SectorDef('KZLA', 'US West', 'Los Angeles Center', [
      SectorFix('SLI', -0.6, -0.55),
      SectorFix('VTU', 0.5, -0.6),
      SectorFix('TRM', 0.65, 0.45),
      SectorFix('GFS', -0.5, 0.6),
      SectorFix('LAX', 0.0, 0.0),
    ]),
  ];

  static const List<String> typePool = [
    'A320',
    'A321',
    'A359',
    'B738',
    'B38M',
    'B77W',
    'B789',
    'E190',
    'CRJ9',
    'AT76',
  ];

  static const List<String> carriers = [
    'DLH',
    'BAW',
    'AFR',
    'KLM',
    'UAL',
    'AAL',
    'DAL',
    'SWR',
    'RYR',
    'EZY',
  ];
}
