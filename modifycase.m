function mpc = modifycase(mpc,fname,settings)
  define_constants;
  % mpc = loadcase(mpc0);
  Vm = table2array(readtable(strcat('data/',fname,"/Vm.csv")));
  Va = table2array(readtable(strcat('data/',fname,"/Va.csv")));
  Pg = 100*table2array(readtable(strcat('data/',fname,"/Pg.csv")));
  Qg = 100*table2array(readtable(strcat('data/',fname,"/Qg.csv")));
  mpc.bus(:,VM) = Vm;
  mpc.bus(:,VA) = Va;
  mpc.gen(:,PG) = Pg;
  mpc.gen(:,QG) = Qg;
  mpc.gen(:,VG) = Vm(mpc.gen(:,GEN_BUS));
  if settings.remove_bshunt == 1
    mpc.bus(:,BS) = 0;
  end
  if settings.lossless == 1
    mpc.branch(:,BR_R) = 0;
  end
  if settings.remove_tap == 1
    mpc.branch(:,TAP) = 0;
  end
  % if strcmp(fname,'1_00__0__0__exitrates__1e_15__1_05')
  %   mpc.branch(:,RATE_A) = 10 * mpc.branch(:,RATE_A);
  % end
end