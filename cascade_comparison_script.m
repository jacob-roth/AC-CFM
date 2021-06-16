clc;clear;

%
%%
%%% cascade comparison script  (only line overload protection mechanism)
%%
%

% default settings
settings = get_default_settings();
settings.seed = 12345

% verbosity
settings.verbose = 0;
  
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

% zipf contingencies
Nsims = 1000;
zipf_alpha = 2.25;

%
%%
%%% cascades
c_1 = modifycase(case118_n1_lowdamp,'1_00__0__0__acopf__1_05',settings);
c_2 = modifycase(case118_n1_lowdamp,'1_00__0__0__scacopf__1_05',settings);
c_3 = modifycase(case118_n1_lowdamp,'1_00__0__0__exitrates__1e_15__1_05',settings);
z_1 = accfm_pdf_batch_comparison(c_1, 'zipf', zipf_alpha, Nsims, settings, 'cascades_118bus_n1_lowdamp_acopf.mat');
z_2 = accfm_pdf_batch_comparison(c_2, 'zipf', zipf_alpha, Nsims, settings, 'cascades_118bus_n1_lowdamp_scacopf.mat');
z_3 = accfm_pdf_batch_comparison(c_3, 'zipf', zipf_alpha, Nsims, settings, 'cascades_118bus_n1_lowdamp_fpacopf.mat');

%
%%
%%% plotting lines
plot_cascade_severity('cascades_118bus_n1_lowdamp_acopf.mat','118bus ACOPF','lines')
plot_cascade_severity('cascades_118bus_n1_lowdamp_scacopf.mat','118bus SC-ACOPF','lines')
plot_cascade_severity('cascades_118bus_n1_lowdamp_fpacopf.mat','118bus FP-ACOPF','lines')
plot_cascade_severity('cascades_118bus_n1_lowdamp_acopf.mat','118bus ACOPF','load')
plot_cascade_severity('cascades_118bus_n1_lowdamp_scacopf.mat','118bus SC-ACOPF','load')
plot_cascade_severity('cascades_118bus_n1_lowdamp_fpacopf.mat','118bus FP-ACOPF','load')

%
%%
%%% plotting survival
dispatch_types = {'N-0 ACOPF', 'N-1 SC-ACOPF', 'N-k FP-ACOPF'};
fnames = {'cascades_118bus_n1_lowdamp_acopf.mat', 'cascades_118bus_n1_lowdamp_scacopf.mat', 'cascades_118bus_n1_lowdamp_fpacopf.mat'};
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','proportion','survival_118bus_n1_lowdamp')
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','number','survival_118bus_n1_lowdamp')
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','load','proportion','survival_118bus_n1_lowdamp')
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','load','number','survival_118bus_n1_lowdamp')


%
%%
%%% cascade comparison script (all protection mechanisms)
%%
%

% default settings
settings = get_default_settings();
settings.seed = 12345

% verbosity
settings.verbose = 0;
  
% protection mechanisms
settings.ol  = 1;
settings.vls = 1;
settings.gl  = 1;
settings.xl  = 1;
settings.fls = 1;
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

% zipf contingencies
Nsims = 1000;
zipf_alpha = 2.25;

%
%%
%%% cascades
c_1 = modifycase(case118_n1_lowdamp,'1_00__0__0__acopf__1_05',settings);
c_2 = modifycase(case118_n1_lowdamp,'1_00__0__0__scacopf__1_05',settings);
c_3 = modifycase(case118_n1_lowdamp,'1_00__0__0__exitrates__1e_15__1_05',settings);
z_1 = accfm_pdf_batch_comparison(c_1, 'zipf', zipf_alpha, Nsims, settings, 'cascades_118bus_n1_lowdamp_acopf_allprotection.mat');
z_2 = accfm_pdf_batch_comparison(c_2, 'zipf', zipf_alpha, Nsims, settings, 'cascades_118bus_n1_lowdamp_scacopf_allprotection.mat');
z_3 = accfm_pdf_batch_comparison(c_3, 'zipf', zipf_alpha, Nsims, settings, 'cascades_118bus_n1_lowdamp_fpacopf_allprotection.mat');

%
%%
%%% plotting lines
plot_cascade_severity('cascades_118bus_n1_lowdamp_acopf_allprotection.mat','118bus ACOPF','lines')
plot_cascade_severity('cascades_118bus_n1_lowdamp_scacopf_allprotection.mat','118bus SC-ACOPF','lines')
plot_cascade_severity('cascades_118bus_n1_lowdamp_fpacopf_allprotection.mat','118bus FP-ACOPF','lines')
plot_cascade_severity('cascades_118bus_n1_lowdamp_acopf_allprotection.mat','118bus ACOPF','load')
plot_cascade_severity('cascades_118bus_n1_lowdamp_scacopf_allprotection.mat','118bus SC-ACOPF','load')
plot_cascade_severity('cascades_118bus_n1_lowdamp_fpacopf_allprotection.mat','118bus FP-ACOPF','load')

%
%%
%%% plotting survival
dispatch_types = {'N-0 ACOPF', 'N-1 SC-ACOPF', 'N-k FP-ACOPF'};
fnames = {'cascades_118bus_n1_lowdamp_acopf_allprotection.mat', 'cascades_118bus_n1_lowdamp_scacopf_allprotection.mat', 'cascades_118bus_n1_lowdamp_fpacopf_allprotection.mat'};
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','proportion','survival_118bus_n1_lowdamp_allprotection')
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','lines','number','survival_118bus_n1_lowdamp_allprotection')
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','load','proportion','survival_118bus_n1_lowdamp_allprotection')
plot_cascade_survival(fnames,dispatch_types,'118bus Survival Plots','load','number','survival_118bus_n1_lowdamp_allprotection')