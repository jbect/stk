% STK_PREDICT_LEAVEONEOUT_DIRECT [STK internal]

% Copyright Notice
%
%    Copyright (C) 2016-2018, 2020 CentraleSupelec
%
%    Author:  Julien Bect      <julien.bect@centralesupelec.fr>
%             Stefano Duhamel  <stefano.duhamel@supelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

function [LOO_pred, LOO_res] = stk_predict_leaveoneout_direct (M_post)

% Heteroscedatic noise ?
heteroscedastic = ~ isscalar (M_post.prior_model.lognoisevariance);

x_obs = stk_get_input_data (M_post.data);
z_obs = stk_get_output_data (M_post.data);

n = stk_get_sample_size (x_obs);
zp_mean = zeros (n, 1);
zp_var = zeros (n, 1);

prior_model = M_post.prior_model;

for i = 1:n
    
    xx = x_obs;  xx(i, :) = [];  xt = x_obs(i, :);
    zz = z_obs;  zz(i, :) = [];
    
    % In the heteroscedastic case, the vector of log-variances for the
    % noise is stored in prior_model.lognoisevariance.  This vector must be
    % modified too, when performing cross-validation.
    if heteroscedastic
        prior_model = M_post.prior_model;
        prior_model.lognoisevariance(i) = [];
    end
    
    zp = stk_predict (prior_model, xx, zz, xt);
    
    zp_mean(i) = zp.mean;
    zp_var(i) = zp.var;
    
end

% Prepare outputs
LOO_pred = stk_dataframe ([zp_mean zp_var], {'mean', 'var'});

% Compute residuals ?
if nargout ~= 1
    
    % Compute "raw" residuals
    raw_res = z_obs - zp_mean;
    
    % Compute normalized residual
    noisevariance = stk_get_observation_variances (M_post);
    norm_res = raw_res ./ (sqrt (noisevariance + zp_var));
    
    % Pack results into a dataframe
    LOO_res = stk_dataframe ([raw_res norm_res], ...
        {'residuals', 'norm_res'});
end

% Create LOO cross-validation plots?
if nargout == 0
    
    % Plot predictions VS observations (left planel)...
    stk_subplot (1, 2, 1);
    stk_plot_predvsobs (z_obs, LOO_pred);
    
    % ...and normalized residuals (right panel)
    stk_subplot (1, 2, 2);
    stk_plot_histnormres (LOO_res.norm_res);
    
end

end % function
