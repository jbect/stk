% STK_PARAM_ESTIM_OPTIMIZE [STK internal]
%
% INTERNAL FUNCTION WARNING:
%
%    This function is currently considered as internal.  API-breaking
%    changes are very likely to happen in future releases.

% Copyright Notice
%
%    Copyright (C) 2015-2021 CentraleSupelec
%    Copyright (C) 2014 Ashwin Ravisankar
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect        <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez   <emmanuel.vazquez@centralesupelec.fr>
%              Ashwin Ravisankar  <ashwinr1993@gmail.com>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (http://sourceforge.net/projects/kriging)
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

function [model_opt, info] = stk_param_estim_optim ...
    (model0, xi, zi, criterion, select)

% Starting point
v0 = stk_get_optimizable_parameters (model0);
w0 = v0(select);

% Bounds
[lb, ub] = stk_param_getdefaultbounds (model0, xi, zi);
lb = lb(select);
ub = ub(select);

% Sanity checks
assert (isequal (size (lb), size (w0)));
assert (isequal (size (ub), size (w0)));

% Define objective function
f = @(v)(crit_wrapper (model0, v, xi, zi, criterion, select));

finite_bounds_available = ~((any (lb == -inf) || any (ub == +inf)));

% Sanity check
crit0 = f (w0);
if ~ (isscalar (crit0) && isfinite (crit0))
    errmsg = '*** PANIC: crit0 is not a finite scalar value. ***';
    stk_error (errmsg, 'OptimizationFailure');
end

if finite_bounds_available
    A = stk_options_get ('stk_param_estim', 'minimize_box');
    [w_opt, crit_opt] = stk_minimize_boxconstrained (A, f, w0, lb, ub);
else
    A = stk_options_get ('stk_param_estim', 'minimize_unc');
    [w_opt, crit_opt] = stk_minimize_unconstrained (A, f, w0);
end

% Create 'model_opt' output
if crit_opt < crit0
    v_opt = v0;
    v_opt(select) = w_opt;
    model_opt = stk_set_optimizable_parameters (model0, v_opt);
else
    s1 = 'Something went wrong during the optimization';
    s2 = sprintf ('crit0 = %f,  crit_opt = %f:  crit0 < crit_opt', crit0, crit_opt);
    warning (sprintf ('%s\n%s\n', s1, s2));  % FIXME: warning id
    model_opt = model0;
end

% Create 'info' structure, if requested
if nargout > 1
    info.criterion = criterion;
    info.crit_opt = crit_opt;
    info.starting_point = w0;
    info.final_point = w_opt;
    info.lower_bounds = lb;
    info.upper_bounds = ub;
    info.select = select;
end

end % function

%#ok<*CTCH,*LERR,*SPWRN,*WNTAG>


function [C, dC] = crit_wrapper (model, w, xi, zi, criterion, select)

v = stk_get_optimizable_parameters (model);
v(select) = w;
model = stk_set_optimizable_parameters (model, v);

if nargout == 1
    
    % Compute only the value of the criterion
    C = criterion (model, xi, zi);
    
else
    
    % Compute the value of the criterion and the gradients
    % FIXME: We might be computing a lot of derivatives that we don't really need...
    [C, C_grad] = criterion (model, xi, zi);
    
    dC = C_grad(select);
    
end

end % function
