%
%%
%%% test 1: 39bus
%%
%
clc;clear;

% load default settings
settings = get_default_settings();
settings.seed = 12345

% enable verbose output – just for testing
settings.verbose = 2;
 
% model outage of line 9; this can also be an array of branch indices
initial_contingency = 9;

% protection mechanisms
settings.ol  = 1;
settings.vls = 1;
settings.gl  = 1;
settings.xl  = 1;
settings.fls = 1;
settings.intermediate_failures = 0;
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
%%% test 2: 2736 bus
clc;clear;

% load default settings
settings = get_default_settings();
settings.seed = 12345;

% enable verbose output – just for testing
settings.verbose = 1;

z_1 = accfm_pdf_batch(case2736sp, 'zipf', 3.0, 3, settings, 'z_1.mat');
z_r = accfm_pdf_batch(randomizecase(case2736sp,settings), 'zipf', 3.0, 3, settings, 'z_r.mat');

%
%%
%%% test 2: 2736bus (lossless + current)
%%
%
clc;clear;

% load default settings
settings = get_default_settings();
settings.seed = 12345;

% enable verbose output – just for testing
settings.verbose = 1;

settings.ol  = 1;
settings.vls = 0;
settings.gl  = 0;
settings.xl  = 0;
settings.fls = 0;
settings.intermediate_failures = 1;
settings.ol_scale = 1.0;

% power flow modification settings
settings.lossless = 1;
settings.remove_bshunt = 1;
settings.remove_tap = 1;
settings.lineflows_current = 1;
settings.mpopt.opf.flow_lim = 'I';
settings.mpopt.pf.flow_lim = 'I';
settings.mpopt.cpf.flow_lim = 'I';

z_1 = accfm_pdf_batch_comparison(case2736sp, 'zipf', 3.0, 3, settings, 'z_1.mat');
z_r = accfm_pdf_batch_comparison(modifycase(randomizecase(case2736sp,settings),'',settings), 'zipf', 3.0, 3, settings, 'z_r.mat');

z_1 = accfm_pdf_batch_comparison(case2736sp_Qmodified, 'zipf', 2.25, 10, settings, 'z_1.mat');
z_r = accfm_pdf_batch_comparison(modifycase(randomizecase(case2736sp_Qmodified,settings),'',settings), 'zipf', 2.25, 10, settings, 'z_r.mat');

%
%%
%%% 118bus test 3
%%
%
clc;clear;

% load default settings
settings = get_default_settings();
settings.seed = 12345

% enable verbose output – just for testing
settings.verbose = 1;
 
% model outage of line 9; this can also be an array of branch indices
initial_contingency = 9;

% protection mechanisms
settings.ol  = 1;
settings.vls = 0;
settings.gl  = 0;
settings.xl  = 0;
settings.fls = 0;
settings.intermediate_failures = 5;
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
c_2 = modifycase(case118_n1_lowdamp,'1_00__0__0__scacopf__1_05',settings);
c_3 = modifycase(case118_n1_lowdamp,'1_00__0__0__exitrates__1e_15__1_05',settings);
r_1_single = accfm_comparison(c_1, struct('branches', initial_contingency), settings);
r_2_single = accfm_comparison(c_2, struct('branches', initial_contingency), settings);
r_3_single = accfm_comparison(c_3, struct('branches', initial_contingency), settings);
