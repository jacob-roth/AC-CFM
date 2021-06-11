clc;clear;
define_constants;

% default settings
settings = get_default_settings();

% enable verbose output – just for testing
settings.verbose = 1;
 
% model outage of line 9; this can also be an array of branch indices
initial_contingency = 9; % [29,177];
 
% protection mechanisms
settings.ol  = 1;
settings.vls = 0;
settings.gl  = 0;
settings.xl  = 0;
settings.fls = 0;

% power flow modification settings
settings.lossless = 1;
settings.remove_bshunt = 1;
settings.remove_tap = 1;
settings.lineflows_current = 1;
settings.mpopt.opf.flow_lim = 'I';
settings.mpopt.pf.flow_lim = 'I';
settings.mpopt.cpf.flow_lim = 'I';

c_1 = modifycase(case118_n1_lowdamp,'1_00__0__0__acopf__1_05',settings)
c_2 = modifycase(case118_n1_lowdamp,'1_00__0__0__scacopf__1_05',settings)
c_3 = modifycase(case118_n1_lowdamp,'1_00__0__0__exitrates__1e_15__1_05',settings)

V_1 = c_1.bus(:,VM) .* exp(1i * c_1.bus(:,VA));
V_2 = c_2.bus(:,VM) .* exp(1i * c_2.bus(:,VA));
V_3 = c_3.bus(:,VM) .* exp(1i * c_3.bus(:,VA));
[Y_1, Y_f1, Y_t1] = makeYbus(c_1);
[Y_2, Y_f2, Y_t2] = makeYbus(c_2);
[Y_3, Y_f3, Y_t3] = makeYbus(c_3);
If_1 = Y_f1 * V_1;
It_1 = Y_t1 * V_1;
If_2 = Y_f2 * V_2;
It_2 = Y_t2 * V_2;
If_3 = Y_f3 * V_3;
It_3 = Y_t3 * V_3;
Imf_1 = abs(If_1).^2;
Imt_1 = abs(It_1).^2;
Imf_2 = abs(If_2).^2;
Imt_2 = abs(It_2).^2;
Imf_3 = abs(If_3).^2;
Imt_3 = abs(It_3).^2;

% writematrix(Imf_1,'I2f_1.csv');
% writematrix(Imt_1,'I2t_1.csv');
% writematrix(Imf_2,'I2f_2.csv');
% writematrix(Imt_2,'I2t_2.csv');
% writematrix(Imf_3,'I2f_3.csv');
% writematrix(Imt_3,'I2t_3.csv');

writematrix(max(Imf_1,Imt_1),'I2_1_matpower.csv');
writematrix(max(Imf_2,Imt_2),'I2_2_matpower.csv');
writematrix(max(Imf_3,Imt_3),'I2_3_matpower.csv');

nlines = size(c_1.branch,1);
nb = size(c_1.bus, 1);
flows_1 = zeros(nlines,1);
flows_2 = zeros(nlines,1);
flows_3 = zeros(nlines,1);
networks = [c_1,c_2,c_3];
flowss = [flows_1,flows_2,flows_3];
for i = 1:3
  network = networks(i);
  flows = flowss(:,i);
  for l = 1:nlines
      L = network.branch(l,:);
      f = L(F_BUS);
      t = L(T_BUS);
      ff = find(network.bus(:,BUS_I) == f);
      tt = find(network.bus(:,BUS_I) == t);
      Yabs2 = abs(L(BR_R) / (L(BR_R)^2 + L(BR_X)^2) - 1i * (L(BR_X) / (L(BR_R)^2 + L(BR_X)^2)))^2;
      Vm_f = network.bus(ff,VM);
      Vm_t = network.bus(tt,VM);
      Va_f = network.bus(ff,VA);
      Va_t = network.bus(tt,VA);
      if L(TAP) == 0.0
          t = exp(1i * L(SHIFT));
      else
          t = L(TAP) * exp(1i*pi/180 * L(SHIFT));
      end
      a = real(t);
      b = imag(t);
      %% NOT SQRT; leave as squared flow
      current2 = ( (Vm_f^2 + (a^2 + b^2) * Vm_t^2 - 2 * Vm_f * Vm_t * ( a * cos(Va_f - Va_t) + b * sin(Va_f - Va_t) ))*(Yabs2/(a^2 + b^2)^2) );
      flows(l) = current2;
  end
  writematrix(flows,strcat('I2_',num2str(i),'_julia.csv'));
end

e_1 = norm(table2array(readtable('I2_1_julia.csv'))-table2array(readtable('I2_1_matpower.csv')));
e_2 = norm(table2array(readtable('I2_2_julia.csv'))-table2array(readtable('I2_2_matpower.csv')));
e_3 = norm(table2array(readtable('I2_3_julia.csv'))-table2array(readtable('I2_3_matpower.csv')));

r1 = runpf(c_1)