function model = learnDalalTriggs(data_set, cls, params)
% Learn a DalalTriggs template detector, with latent updates,
% perturbed assignments (which help avoid local minima), and
% ability to use different features.
%
% Copyright (C) 2011-12 by Tomasz Malisiewicz
% All rights reserved. 
%
% This file is part of the Exemplar-SVM library and is made
% available under the terms of the MIT license (see COPYING file).
% Project homepage: https://github.com/quantombone/exemplarsvm

addpath(genpath(pwd));

if ~exist('cls','var')
  error('Needs class as input');
end

if length(data_set) == 0
  fprintf(1,'No dataset provided, loading default DATA');
  
  data_directory = '/Users/tomasz/projects/pascal/';
  dataset_directory = 'VOC2007';  
  data_set = install_dataset(data_directory, dataset_directory);
end

if ~exist('params','var') || length(params) == 0
  %% Get default parameters
  params = esvm_get_default_params;
else
  params = esvm_get_default_params(params);
end

params.display = 0;  
params.dump_images = 0;
params.detect_max_windows_per_exemplar = 100;
params.train_max_negatives_in_cache = 5000;
params.train_max_mined_images = 500;
params.latent_iterations = 2;
% for dalaltriggs, it seams having same constant on positives as
% negatives is better than using 50
params.train_positives_constant = 1;
params.mine_from_negatives = 1;
params.mine_from_positives = 0;
params.mine_skip_positive_objects_os = .2;
params.train_max_scale = 1.0;
params.latent_os_thresh = 0.7;
params.dt_initialize_with_flips = 1;

%params.detect_pyramid_padding = 0;

starttime = tic;
model = esvm_initialize_dt(data_set, cls, params);
model = esvm_train(model);

for niter = 1:params.latent_iterations
  model = esvm_latent_update_dt(model);
  model = esvm_train(model);
end

model.learn_time = toc(starttime);
