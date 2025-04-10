const axios = require('axios');

const path = require('path');
const fs = require('fs');
const FormData = require('form-data');

const args = process.argv.slice(2);

// Data group names
const DGN_MEDIAL_ROOT_STRAIN = 'medial-root-strain'
const DGN_GLOBAL_MEASUREMENTS = 'global-measurements'
const DGN_COAPTATION_SURFACE = 'coaptation-surface'


// Function to parse command line arguments
function parseArguments(args) {
  const options = {
    cn: '',
    sn: '',
    data: ''
  };

  for (let i = 0; i < args.length; i += 2) {
    const arg = args[i];
    const value = args[i + 1];

    switch (arg) {
      case '-cn':
        options.cn = value;
        break;
      case '-sn':
        options.sn = value;
        break;
      case '-data':
        options.data = value;
        break;
      default:
        console.log(`Invalid argument: ${arg}`);
        break;
    }
  }

  return options;
}

// Parse command line arguments
const options = parseArguments(args);

// Access the values
const { cn, sn, data } = options;
const outputFolder = data;

// Use the values as needed
console.log(`-- [batch_import.js] Case: ${cn}, Study: ${sn}, Data: ${data}`);

// =================================================================
// Configurations
// =================================================================

const gatewayUrl = "http://localhost:6060";
const user = {
  username: "avrpdev",
  password: "avrp@dev"
};

const dsUrl = "http://localhost:7070";

const createCase = async (_token) => {
  return fetch (`${gatewayUrl}/case`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${_token}`
    },
    body: JSON.stringify({
      "caseName": cn,
      "mrn": ""
    })
  }).then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok. Message: ' + response.statusText);
    }
    return response.json();
  }).then(data => {
    return data.caseId;
  }).catch(error => {
    console.error('Fetch error:', error);
  });
};


const createStudy = async (_token, _cid) => {
  return fetch (`${gatewayUrl}/study`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${_token}`
    },
    body: JSON.stringify({
      caseId: _cid,
      studyName: sn
    })
  }).then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok. Message: ' + response.statusText);
    }
    return response.json();
  }).then(data => {
    return data.studyId;
  }).catch(error => {
    console.error('Fetch error:', error);
  });
};


const createData = async (_token, _sid, _data) => {
  return fetch (`${gatewayUrl}/study-data-headers-vs?study_id=${_sid}`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${_token}`
    },
    body: JSON.stringify({
      dataArray: _data
    })
  }).then(response => {
    if (!response.ok) {
      throw new Error('Network response was not ok. Message: ' + response.statusText);
    }
    return response.json();
  }).then(data => {
    return data;
  }).catch(error => {
    console.error('Fetch error:', error);
  });
};


const uploadToDS = async (_filePath, _dsFolder) => {
  const filename = path.basename(_filePath);

  // check if file exists using HEAD request
  try {
    const response = await axios.head(`${dsUrl}/data/exist?folder=${_dsFolder}&filename=${filename}`);

    if (response.status == 200) {
      console.log(`[uploadToDS] ${_dsFolder}/${filename} exists`);
      return response.headers['ds-file-id'];
    }
  } catch (error) {
    console.log(`[uploadToDS] ${_dsFolder}/${filename} does not exist, will upload new file`);
  }

  // Create form data
  const form = new FormData();
  form.append('file', fs.createReadStream(_filePath)); // Ensure 'file' matches the field name expected by the server
  form.append('folder', _dsFolder); // Additional form fields
  form.append('filename', filename); // Additional form fields
  form.append('create_folder_if_not_exists', 'true'); // Additional form fields

  try {
    const response = await axios.post(`${dsUrl}/data`, form, {
      headers: {
        ...form.getHeaders(),
      },
    });

    if (!response.status === 200) {
      throw new Error('Network response was not ok. Message: ' + response.statusText);
    }

    return response.data.fileId;
  } catch (error) {
    console.error(`[uploadToDS] file_path: ${_filePath}. Error:`, error);
  }
};


const uploadModelSL = async () => {
  let headers = [];

  // iterate over the output folder in the data directory
  const files = fs.readdirSync(outputFolder);

  // for each file with model-sl*.vtp, process the upload
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    if (file.includes('model-sl')) {
      const filePath = path.join(outputFolder, file);

      console.log(`-- Uploading file: ${filePath}`);
      const fileId = await uploadToDS(filePath, `${cn}/${sn}/model-sl`);
      console.log(`---- File ID: ${fileId}`);

      // extract tp from the filename
      const tpStr = file.match(/\d+/)[0];
      const tp = parseInt(tpStr);
      console.log(`---- Timepoint: ${tp}`);

      headers.push({
        "data_group_name": "model-sl",
        "time_point": tp,
        "primary_index": null,
        "secondary_index": null,
        "data_server_id": fileId
      })
    }
  }

  return headers;
}

const uploadModelML = async () => {
  let headers = [];

  // iterate over the output folder in the data directory
  const files = fs.readdirSync(outputFolder);

  // for each file with mesh_lb*.vtp, process the upload
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    if (file.includes('mesh_lb')) {
      const filePath = path.join(outputFolder, file);

      console.log(`-- Uploading file: ${filePath}`);
      const fileId = await uploadToDS(filePath, `${cn}/${sn}/model-ml`);
      // const fileId = 0;
      console.log(`---- File ID: ${fileId}`);

      // extract tp from the filename (e.g. mesh_lb01_tp01.vtp)
      const tpStr = file.match(/tp\d+/)[0];
      const tp = parseInt(tpStr.match(/\d+/)[0]);
      console.log(`---- Timepoint: ${tp}`);

      // extract lb from the filename (e.g. mesh_lb01_tp01.vtp)
      const lbStr = file.match(/lb\d+/)[0];
      const lb = parseInt(lbStr.match(/\d+/)[0]);
      console.log(`---- Label: ${lb}`);

      headers.push({
        "data_group_name": "model-ml",
        "time_point": tp,
        "primary_index": lb,
        "secondary_index": null,
        "data_server_id": fileId
      })
    }
  }

  return headers;
};

const uploadVolume = async () => {
  let headers = [];

  // iterate over the output folder in the data directory
  const files = fs.readdirSync(outputFolder);

  // for each file with volume*.nii.gz, process the upload
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    if (file.includes('img') && file.includes('.vti')) {
      const filePath = path.join(outputFolder, file);

      console.log(`-- Uploading file: ${filePath}`);
      const fileId = await uploadToDS(filePath, `${cn}/${sn}/volume`);
      console.log(`---- File ID: ${fileId}`);

      // extract tp from the filename (e.g. volume_tp01.nii.gz)
      const tpStr = file.match(/\d+/)[0];
      const tp = parseInt(tpStr);
      console.log(`---- Timepoint: ${tp}`);

      headers.push({
        "data_group_name": "volume-main",
        "time_point": tp,
        "primary_index": null,
        "secondary_index": null,
        "data_server_id": fileId
      })
    }
  }

  return headers;
};

const uploadSegmentation = async () => {
  let headers = [];

  // iterate over the output folder in the data directory
  const files = fs.readdirSync(outputFolder);

  // for each file with seg*.nii.gz, process the upload
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    if (file.includes('seg') && file.includes('.vti')) {
      const filePath = path.join(outputFolder, file);

      console.log(`-- Uploading file: ${filePath}`);
      const fileId = await uploadToDS(filePath, `${cn}/${sn}/segmentation`);
      console.log(`---- File ID: ${fileId}`);

      // extract tp from the filename (e.g. seg_tp01.nii.gz)
      const tpStr = file.match(/\d+/)[0];
      const tp = parseInt(tpStr);
      console.log(`---- Timepoint: ${tp}`);

      headers.push({
        "data_group_name": "volume-segmentation",
        "time_point": tp,
        "primary_index": null,
        "secondary_index": null,
        "data_server_id": fileId
      })
    }
  }

  return headers;
};

const morphCodeLookup = {'LN': 1, 'NR': 2, 'LR': 3};

const uploadCoaptationSurface = async () => {
  let headers = [];

  // iterate over the output folder in the data directory
  const files = fs.readdirSync(outputFolder);

  // for each file with coaptation_surface*.vtp, process the upload
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    if (file.includes('coaptation_surface')) {
      const filePath = path.join(outputFolder, file);

      console.log(`-- Uploading file: ${filePath}`);
      const fileId = await uploadToDS(filePath, `${cn}/${sn}/${DGN_COAPTATION_SURFACE}`);
      console.log(`---- File ID: ${fileId}`);

      // extract morph code (LN, NR, LR) from the filename (e.g. coaptation_surface_NR_tp01.vtp)
      const morphCode = file.match(/LN|NR|LR/)[0];
      console.log(`---- Morph Code: ${morphCode}`);
      const morphCodeId = morphCodeLookup[morphCode];

      if (!morphCodeId) {
        throw new Error(`Invalid morph code: ${morphCode}`);
      }

      // extract tp from the filename (e.g. coaptation_surface_NR_tp01.vtp)
      const tpStr = file.match(/\d+/)[0];
      const tp = parseInt(tpStr);
      console.log(`---- Timepoint: ${tp}`);

      headers.push({
        "data_group_name": DGN_COAPTATION_SURFACE,
        "time_point": tp,
        "primary_index": morphCodeId,
        "secondary_index": null,
        "data_server_id": fileId
      })
    }
  }
  
  return headers;
}

const uploadGlobalMeasurements = async () => {
  let headers = [];

  // iterate over the output folder in the data directory
  const files = fs.readdirSync(outputFolder);

  // look for _global_measurements.json
  const file = files.find(file => file.includes('hdl_gm_values'));

  if (!file || file.length === 0) {
    console.log(`-- No global measurements file found`);
    return headers;
  }

  const filePath = path.join(outputFolder, file);

  console.log(`-- Uploading file: ${filePath}`);
  const fileId = await uploadToDS(filePath, `${cn}/${sn}/${DGN_GLOBAL_MEASUREMENTS}`);
  console.log(`---- File ID: ${fileId}`);


  // extract tp from the filename (e.g. coaptation_surface_NR_tp01.vtp)
  // const tpStr = file.match(/tp\d+/)[0];
  // const tp = parseInt(tpStr.match(/\d+/)[0]);
  // console.log(`---- Timepoint: ${tp}`);

  headers.push({
    "data_group_name": DGN_GLOBAL_MEASUREMENTS,
    "time_point": -1,
    "primary_index": null,
    "secondary_index": null,
    "data_server_id": fileId
  });

  return headers;
}

const uploadGlobalMeasurementsModels = async () => {
  let headers = [];

  // iterate over the output folder in the data directory
  const files = fs.readdirSync(outputFolder);

  // for each file with coaptation_surface*.vtp, process the upload
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    if (file.includes('hdl_gm') && !file.includes('hdl_gm_values')) {
      const filePath = path.join(outputFolder, file);

      console.log(`-- Uploading file: ${filePath}`);
      const fileId = await uploadToDS(filePath, `${cn}/${sn}/${DGN_GLOBAL_MEASUREMENTS}`);
      console.log(`---- File ID: ${fileId}`);

      // extract data group name from the filename (e.g. cs in "hdl_gm_cs_lb02.vtp")
      // -- extract between the 2nd and 3rd underscore
      const dataGroupName = `${DGN_GLOBAL_MEASUREMENTS}_${file.split('_')[2]}`;
      console.log(`---- Data group name: ${dataGroupName}`);

      // extract label from the filename (e.g. hdl_gm_cs_lb02.vtp)
      const lbStr = file.match(/lb\d+/)[0];
      const lb = parseInt(lbStr.match(/\d+/)[0]);
      console.log(`---- Label: ${lb}`);

      // extract tp from the filename (e.g. coaptation_surface_NR_tp01.vtp)
      const tpStr = file.match(/tp\d+/)[0];
      const tp = parseInt(tpStr.match(/\d+/)[0]);
      console.log(`---- Timepoint: ${tp}`);

      headers.push({
        "data_group_name": dataGroupName,
        "time_point": tp,
        "primary_index": lb,
        "secondary_index": null,
        "data_server_id": fileId
      })
    }
  }
    
  return headers;
}

const uploadMedialRootStrain = async () => {
  let headers = [];

  // iterate over the output folder in the data directory
  const files = fs.readdirSync(outputFolder);

  // for each file with model-sl*.vtp, process the upload
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    if (file.includes(DGN_MEDIAL_ROOT_STRAIN)) {
      const filePath = path.join(outputFolder, file);

      console.log(`-- Uploading file: ${filePath}`);
      const fileId = await uploadToDS(filePath, `${cn}/${sn}/${DGN_MEDIAL_ROOT_STRAIN}`);
      console.log(`---- File ID: ${fileId}`);

      // extract tp from the filename
      const tpStr = file.match(/\d+/)[0];
      const tp = parseInt(tpStr);
      console.log(`---- Timepoint: ${tp}`);

      headers.push({
        "data_group_name": `${DGN_MEDIAL_ROOT_STRAIN}`,
        "time_point": tp,
        "primary_index": null,
        "secondary_index": null,
        "data_server_id": fileId
      })
    }
  }

  return headers;
}

async function importStudy() {
  const response = await fetch(`${gatewayUrl}/login`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(user),
  }).then(response => {
    return response.json();
  })
  
  const token = response.token;
  // console.log(token);

  // Create case
  const cid = await createCase(token);
  console.log(`-- Case ID: ${cid}`);

  // Create study
  const sid = await createStudy(token, cid);
  console.log(`-- Study ID: ${sid}`);

  // Upload data
  const modelSLHeaders = await uploadModelSL();
  // console.log(`-- Model SL headers: `, modelSLHeaders);

  const modelMLHeaders = await uploadModelML();
  // console.log(`-- Model ML headers: `, modelMLHeaders);

  const volumeHeaders = await uploadVolume();
  // console.log(`-- Volume headers: `, volumeHeaders);

  const segmentationHeaders = await uploadSegmentation();
  // console.log(`-- Segmentation headers: `, segmentationHeaders);

  const coaptationSurfaceHeaders = await uploadCoaptationSurface();
  // console.log(`-- Coaptation Surface headers: `, coaptationSurfaceHeaders);

  const globalMeasurementsHeaders = await uploadGlobalMeasurements();
  // console.log(`-- Global Measurements headers: `, globalMeasurementsHeaders);

  const medialRootStrainHeaders = await uploadMedialRootStrain();
  // console.log(`-- Medial Root Strain headers: `, medialRootStrainHeaders);

  const globalMeasurementsModelHeaders = await uploadGlobalMeasurementsModels();
  // console.log(`-- Global Measurements Model headers: `, globalMeasurementsModelHeaders);

  // assemble all the headers
  const headers = modelSLHeaders.concat(modelMLHeaders)
                                .concat(volumeHeaders)
                                .concat(segmentationHeaders)
                                .concat(coaptationSurfaceHeaders)
                                .concat(globalMeasurementsHeaders)
                                .concat(medialRootStrainHeaders)
                                .concat(globalMeasurementsModelHeaders);

  const res = await createData(token, sid, headers);
  console.log(`-- Data posted: `, res);
}

importStudy();