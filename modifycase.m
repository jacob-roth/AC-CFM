function mpc = modifycase(mpc,fname,settings)
  define_constants;
  Vm = table2array(readtable(strcat('data/',fname,"/Vm.csv")));
  Va = table2array(readtable(strcat('data/',fname,"/Va.csv")));
  Pg = table2array(readtable(strcat('data/',fname,"/Pg.csv")));
  Qg = table2array(readtable(strcat('data/',fname,"/Qg.csv")));
  mpc.bus(:,VM) = Vm;
  mpc.bus(:,VA) = Va;
  mpc.gen(:,PG) = Pg;
  mpc.gen(:,QG) = Qg;
  mpc.gen(:,VG) = Vm(mpc.gen(:,GEN_BUS));
  if settings.remove_bshunt == 1
    mpc.branch(:,BS) = 0;
  end
  if settings.lossless == 1
    mpc.branch(:,BR_R) = 0;
  end
  if settings.remove_tap == 1
    mpc.branch(:,TAP) = 0;
  end
end
% fname='1_00__0__0__scacopf__1_05'
% mpc = case118_n1_lowdamp
