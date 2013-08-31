% STK_SQUARED_SEMINORM...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@supelec.fr>

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

function s = stk_squared_seminorm (kreq, zi)

n = size (kreq.LS_Q, 1);
r = n - size (kreq.xi, 1);

% Extend the observation vector with zeros
zz = [double(zi); zeros(r, 1)];

% Compute the squared seminorm
s = zz' * (linsolve (kreq, zz));

% % Alternative (slower) implementation:
% ni = size (kreq.xi, 1);
% zi = double (zi);
% QU = kreq.LS_Q(1:ni, :);
% T  = kreq.LS_R \ (QU' * zi);
% s  = zi' * T(1:ni, :);

% Guard against numerical issues
if s < 0, s = 0; end

end % function stk_squared_seminorm