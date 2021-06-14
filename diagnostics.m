clc;clear;

% load default settings
settings = get_default_settings();
settings.seed = 12345

% enable verbose output – just for testing
settings.verbose = 1;
 
% model outage of line 9; this can also be an array of branch indices
initial_contingency = 9;

%
%%
%%% 39bus

% protection mechanisms
settings.ol  = 1;
settings.vls = 1;
settings.gl  = 1;
settings.xl  = 1;
settings.fls = 1;
settings.intermediate_failures = 1;
settings.ol_scale = 1.0;

% power flow modification settings
settings.lossless = 0;
settings.remove_bshunt = 0;
settings.remove_tap = 0;
settings.lineflows_current = 0;
settings.mpopt.opf.flow_lim = 'S';
settings.mpopt.pf.flow_lim = 'S';
settings.mpopt.cpf.flow_lim = 'S';

c_1 = case39;
c_2 = case39_modified;
r_1_single = accfm_comparison(c_1, struct('branches', initial_contingency), settings);
r_2_single = accfm_comparison(c_2, struct('branches', initial_contingency), settings);

%
%%
%%% 118bus

% protection mechanisms
settings.ol  = 1;
settings.vls = 0;
settings.gl  = 0;
settings.xl  = 0;
settings.fls = 0;
settings.intermediate_failures = 0;
settings.ol_scale = 1.0;

% power flow modification settings
settings.lossless = 1;
settings.remove_bshunt = 1;
settings.remove_tap = 1;
settings.lineflows_current = 1;
settings.mpopt.opf.flow_lim = 'I';
settings.mpopt.pf.flow_lim = 'I';
settings.mpopt.cpf.flow_lim = 'I';

c_1 = modifycase(case118_n1_lowdamp,'1_00__0__0__acopf__1_05',settings);
c_3 = modifycase(case118_n1_lowdamp,'1_00__0__0__exitrates__1e_15__1_05',settings);
r_1_single = accfm_comparison(c_1, struct('branches', initial_contingency), settings);
r_3_single = accfm_comparison(c_3, struct('branches', initial_contingency), settings);