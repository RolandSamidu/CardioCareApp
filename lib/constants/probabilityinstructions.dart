import 'dart:ui';

class ProbabilityInstructions {
  static const probabilityRange = [
    {'range': 'lower than 5%', 'color':0xFFbdc3c7, 'instruction': [
      'Counsel on diet, physical activities, smoking cessation, and avoiding harmful use of Alcohol.',
      'Level of risk can be considered as low.'
      'Follow up for CVD risk in 12 months.',
      'Irrespective of the risk level, if BP larger then or equal to 140/90mmHg, manage according to national guidelines on Management of Hypertension for primary health care'
    ]},
    {'range': 'between 5 and 10%', 'color':0xFF2ecc71, 'instruction': [
      'Counsel on diet, physical activities, smoking cessation, and avoiding harmful use of Alcohol.',
      'CVD risk follows up every 9 months.',
      'Irrespective of the risk level, if BP repeatedly larger then or equal to 140/90mmHg, manage according to national guidelines on Management of Hypertension for primary health care'
    ]},
    {'range': 'between 10 and 20%', 'color':0xFFf39c12, 'instruction': [
      'Counsel on diet, physical activities, smoking cessation, and avoiding harmful use of Alcohol.',
      'CVD risk follow up every 6 months.',
      'If BP persistently larger than 140/90mmHg, manage according to guidelines on Hypertension for primary health care'
    ]},
    {'range': 'between 20 and 30%', 'color':0xFFe67e22, 'instruction': [
      'Counsel on diet, physical activities, smoking cessation, and avoiding harmful use of Alcohol.',
      'CVD risk follow up every 3 months.',
      'Give a statin to modify CVD risk',
      'If BP persistently larger than 140/90mmHg, manage according to guidelines on management of Hypertension and primary health care.',
      'If there is no reduction in CV risk after 6 month follow up, refer to next level of healthcare.'
    ]},
    {'range': 'equal or more than 30%', 'color':0xFFe74c3c, 'instruction': [
    'Counsel on diet, physical activities, smoking cessation, and avoiding harmful use of Alcohol.',
    'CVD risk follow up every 3 months.',
    'Give a statin to modify CVD risk',
    'If BP persistently larger than 140/90mmHg, manage according to guidelines on management of Hypertension and primary health care.',
    'If there is no reduction in CV risk after 6 month follow up, refer to next level of healthcare.'
    ]},
  ];



}