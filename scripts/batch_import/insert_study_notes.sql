-- postgres script to insert study notes into the database

do $$
begin
  create temporary table temp_study_notes (
    case_name varchar(50),
    study_name varchar(50),
    notes text
  ) on commit drop;
  
  -- [
  --   {
  --     "case": "bavcta003",
  --     "study": "scan3",
  --     "notes": "54 year old female with mild to moderate eccentric aortic regurgitation, ascending aortic aneurysm \n AV Morphology: Surgically confirmed R/N fusion with prolapse \nSurgery: Ascending aortic aneurysm repair with graft; primary prolapsed leaflet repair (plication and small cleft repair)"
  --   },
  --   {
  --     "case": "bavcta003",
  --     "study": "scan4",
  --     "notes": "54 year old female with mild to moderate eccentric aortic regurgitation, ascending aortic aneurysm \n AV Morphology: Surgically confirmed R/N fusion with prolapse \nSurgery: Ascending aortic aneurysm repair with graft; primary prolapsed leaflet repair (plication and small cleft repair)"
  --   },
  --   {
  --     "case": "bavcta005",
  --     "study": "scan2",
  --     "notes": "65 year old female with moderate aortic regurgitation, ascending aortic dilatation \nAV Morphology: Suspected dysmorphism (potentially quadricuspid) on CT \nPatient is being longitudinally monitored"
  --   },
  --   {
  --     "case": "bavcta007",
  --     "study": "baseline",
  --     "notes": "41 year old male with moderate aortic regurgitation, ascending aortic dilatation \nAV Morphology: Suspected to be unicuspid on CT (raphes at L/R and R/N commissures) \nPatient is being longitudinally monitored"
  --   },
  --   {
  --     "case": "bavcta008",
  --     "study": "baseline",
  --     "notes": "59 year old male with variable interpretations of AV morphology on TTE, moderate central aortic regurgitation, mild to moderate aortic stenosis, aortic root and ascending aortic aneurysm \nAV Morphology: Surgically confirmed trileaflet AV with calcification of each leaflet, asymmetric root aneurysm \nSurgery: Transverse aortic arch graft; #27mm Bentall BioRoot Conduit graft using a #30/38 ValSalva graft prosthesis"
  --   },
  --   {
  --     "case": "bavcta010",
  --     "study": "baseline",
  --     "notes": "56 year old female with mild aortic regurgitation, dilated ascending aorta \nAV Morphology: Suspected to be L/R fusion on CT \nPatient is being longitudinally monitored"
  --   },
  --   {
  --     "case": "bavcta013",
  --     "study": "baseline",
  --     "notes": "34 year old male with moderate to severe aortic regurgitation, dilated aortic root \nAV Morphology: Surgically confirmed BAV with L/R fusion and cleft in conjoint leaflet \nSurgery: Aortic root re-implantation (David V) BAV sparing procedure with complex leaflet repair (bi-leaflet plication and cleft repair)"
  --   },
  --   {
  --     "case": "bavcta015",
  --     "study": "baseline",
  --     "notes": "41 year old female with mild to moderate aortic regurgitation, mild enlargement of ascending aorta \nAV Morphology: Suspected BAV with R/N fusion \nPatient is being longitudinally monitored"
  --   },
  --   {
  --     "case": "bavcta016",
  --     "study": "baseline",
  --     "notes": "34 year old male with mild aortic regurgitation, ascending aortic dilatation \nAV Morphology: Suspected L/R fusion \nPatient is being longitudinally monitored"
  --   },
  --   {
  --     "case": "bav44",
  --     "study": "pre-op-TEE",
  --     "notes": "47 year old male with ascending aortic aneurysm, no aortic regurgitation \nAV Morphology: Surgically confirmed Sievers Type 0 A-P with commissural calcification, giving the appearance of unicuspid dynamics \nSurgery: Transverse aortic arch graft; ascending aortic aneurysm repair with graft; aortic valve resuspension/repair with normalization of the STJ to annular ratio"
  --   },
  --   {
  --     "case": "bav38",
  --     "study": "pre-op-TEE",
  --     "notes": "59 year old male with severe eccentric aortic regurgitation \nAV Morphology: Surgically confirmed quadricuspid valve with vestigial cusp between the left and non-coronary cusps \nSurgery: Aortic valve replacement with a bioprosthetic valve (non-coronary leaflet surface area was insufficient for tricuspidization repair)"
  --   },
  --   {
  --     "case": "bav16",
  --     "study": "pre-op-TEE",
  --     "notes": "56 year old male with severe eccentric aortic regurgitation \nAV morphology: Surgically confirmed BAV with L/R fusion and somewhat hypoplastic aortic sinus and ascending aorta \nSurgery: Aortic valve replacement with bioprosthetic valve; aortic root and ascending aortic enlargement with pericardial patch"
  --   },
  --   {
  --     "case": "bav20",
  --     "study": "pre-op-TEE",
  --     "notes": "43 year old male with severe aortic regurgitation, moderate enlargement of aortic root and ascending aorta. \nAV morphology: Surgically confirmed BAV with L/R fusion \nSurgery: Transverse aortic arch graft, ascending aortic aneurysm repair with Dacron graft; bicuspid aortic valve repair with cleft closure, L/N commissural stitch, and sub-commissural annuloplasty"
  --   },
  --   {
  --     "case": "bav32",
  --     "study": "pre-op-TEE",
  --     "notes": "29 year old male with mitral valve endocarditis, moderate to severe mitral regurgitation. Patient has a BAV, mild to moderate aortic regurgitation, status post remote balloon valvuloplasty \nAV morphology: Surgically confirmed BAV with R/N fusion \nSurgery: Patient preferred to undergo mitral surgery only: mitral valve edge-to-edge repair, removal of leaflet vegetation, closure of patent foramen ovale"
  --   },
  --   {
  --     "case": "bav24",
  --     "study": "pre-op-TEE",
  --     "notes": "72 year old female with mild to moderate aortic regurgitation, and ascending aortic aneurysm \nAV morphology: Surgically confirmed BAV with L/R fusion \nSurgery: Transverse aortic arch graft; ascending aortic aneurysm repair with Dacron graft and resuspension/repair of the aortic valve with normalization of the STJ to annular ratio"
  --   },
  --   {
  --     "case": "bav17",
  --     "study": "pre-op-TEE",
  --     "notes": "22 year old male with severe eccentric aortic regurgitation \nAV morphology: Surgically confirmed BAV with L/R fusion \nSurgery: Aortic valve repair (El-Khoury technique) with sub-commissural annuloplasty, bi-leaflet plication"
  --   }
  -- ]
 
  insert into temp_study_notes (case_name, study_name, notes)
  values
    -- ('bavcta003', 'scan3', '54 year old female with mild to moderate eccentric aortic regurgitation, ascending aortic aneurysm \n AV Morphology: Surgically confirmed R/N fusion with prolapse \nSurgery: Ascending aortic aneurysm repair with graft; primary prolapsed leaflet repair (plication and small cleft repair)'),
    -- ('bavcta003', 'scan4', '54 year old female with mild to moderate eccentric aortic regurgitation, ascending aortic aneurysm \n AV Morphology: Surgically confirmed R/N fusion with prolapse \nSurgery: Ascending aortic aneurysm repair with graft; primary prolapsed leaflet repair (plication and small cleft repair)'),
    ('bavcta005', 'scan2', '65 year old female with moderate aortic regurgitation, ascending aortic dilatation \nAV Morphology: Suspected dysmorphism (potentially quadricuspid) on CT \nPatient is being longitudinally monitored');
    -- ('bavcta007', 'baseline', '41 year old male with moderate aortic regurgitation, ascending aortic dilatation \nAV Morphology: Suspected to be unicuspid on CT (raphes at L/R and R/N commissures) \nPatient is being longitudinally monitored'),
    -- ('bavcta008', 'baseline', '59 year old male with variable interpretations of AV morphology on TTE, moderate central aortic regurgitation, mild to moderate aortic stenosis, aortic root and ascending aortic aneurysm \nAV Morphology: Surgically confirmed trileaflet AV with calcification of each leaflet, asymmetric root aneurysm \nSurgery: Transverse aortic arch graft; #27mm Bentall BioRoot Conduit graft using a #30/38 ValSalva graft prosthesis'),
    -- ('bavcta010', 'baseline', '56 year old female with mild aortic regurgitation, dilated ascending aorta \nAV Morphology: Suspected to be L/R fusion on CT \nPatient is being longitudinally monitored'),
    -- ('bavcta013', 'baseline', '34 year old male with moderate to severe aortic regurgitation, dilated aortic root \nAV Morphology: Surgically confirmed BAV with L/R fusion and cleft in conjoint leaflet \nSurgery: Aortic root re-implantation (David V) BAV sparing procedure with complex leaflet repair (bi-leaflet plication and cleft repair)'),
    -- ('bavcta015', 'baseline', '41 year old female with mild to moderate aortic regurgitation, mild enlargement of ascending aorta \nAV Morphology: Suspected BAV with R/N fusion \nPatient is being longitudinally monitored'),
    -- ('bavcta016', 'baseline', '34 year old male with mild aortic regurgitation, ascending aortic dilatation \nAV Morphology: Suspected L/R fusion \nPatient is being longitudinally monitored'),
    -- ('bav44', 'pre-op-TEE', '47 year old male with ascending aortic aneurysm, no aortic regurgitation \nAV Morphology: Surgically confirmed Sievers Type 0 A-P with commissural calcification, giving the appearance of unicuspid dynamics \nSurgery: Transverse aortic arch graft; ascending aortic aneurysm repair with graft; aortic valve resuspension/repair with normalization of the STJ to annular ratio'),
    -- ('bav38', 'pre-op-TEE', '59 year old male with severe eccentric aortic regurgitation \nAV Morphology: Surgically confirmed quadricuspid valve with vestigial cusp between the left and non-coronary cusps \nSurgery: Aortic valve replacement with a bioprosthetic valve (non-coronary leaflet surface area was insufficient for tricuspidization repair)'),
    -- ('bav16', 'pre-op-TEE', '56 year old male with severe eccentric aortic regurgitation \nAV morphology: Surgically confirmed BAV with L/R fusion and somewhat hypoplastic aortic sinus and ascending aorta \nSurgery: Aortic valve replacement with bioprosthetic valve; aortic root and ascending aortic enlargement with pericardial patch'),
    -- ('bav20', 'pre-op-TEE', '43 year old male with severe aortic regurgitation, moderate enlargement of aortic root and ascending aorta. \nAV morphology: Surgically confirmed BAV with L/R fusion \nSurgery: Transverse aortic arch graft, ascending aortic aneurysm repair with Dacron graft; bicuspid aortic valve repair with cleft closure, L/N commissural stitch, and sub-commissural annuloplasty'),
    -- ('bav32', 'pre-op-TEE', '29 year old male with mitral valve endocarditis, moderate to severe mitral regurgitation. Patient has a BAV, mild to moderate aortic regurgitation, status post remote balloon valvuloplasty \nAV morphology: Surgically confirmed BAV with R/N fusion \nSurgery: Patient preferred to undergo mitral surgery only: mitral valve edge-to-edge repair, removal of leaflet vegetation, closure of patent foramen ovale'),
    -- ('bav24', 'pre-op-TEE', '72 year old female with mild to moderate aortic regurgitation, and ascending aortic aneurysm \nAV morphology: Surgically confirmed BAV with L/R fusion \nSurgery: Transverse aortic arch graft; ascending aortic aneurysm repair with Dacron graft and resuspension/repair of the aortic valve with normalization of the STJ to annular ratio'),
    -- ('bav17', 'pre-op-TEE', '22 year old male with severe eccentric aortic regurgitation \nAV morphology: Surgically confirmed BAV with L/R fusion \nSurgery: Aortic valve repair (El-Khoury technique) with sub-commissural annuloplasty, bi-leaflet plication');

  update study s
  set notes = subquery.notes
  from (
    select s.study_id, t.notes
    from study s
    join surgery_case sc on s.case_id = sc.case_id
    join temp_study_notes t on sc.case_name = t.case_name and s.study_name = t.study_name
  ) subquery
  where s.study_id = subquery.study_id;
end;
$$;