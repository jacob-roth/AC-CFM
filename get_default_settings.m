function settings = get_default_settings()
%GET_DEFAULT_SETTINGS returns the default settings struct

%   AC-CFM
%   Copyright (c) 2020, Matthias Noebels
%   This file is part of AC-CFM.
%   Covered by the 3-clause BSD License (see LICENSE file for details).

    settings = struct;
    settings.verbose = 0;
    settings.mpopt = mpoption('verbose', 0, 'model', 'AC', 'out.all', 0);
    settings.max_recursion_depth = 100;
    settings.uvls_per_step = 0.05;
    settings.uvls_max_steps = 5;
    settings.dP_limit = 0.15;
    settings.P_overhead = 0.1;
    settings.Q_tolerance = 0.1;
    settings.grid_forming = {'PS', 'ST', 'GT'};
    settings.keep_networks_after_cascade = 0;
    settings.ol_scale = 1.01;
    settings.ol  = 1; % overload lines
    settings.vls = 1; % voltage load shed
    settings.gl  = 1; % generator limits
    settings.xl  = 1; % excitation limits
    settings.fls = 1; % frequency load shed
    settings.mpopt.opf.flow_lim = 'S'; % line flow limit type (S = apparent, P = real, I = current)
    settings.lineflows_current = 0; % 0 for lineflows_power
end

