function mpc = modifycase(mpc,fname)
  define_constants;
  Vm = table2array(readtable(strcat('data/',fname,"/Vm.csv")))
  Va = table2array(readtable(strcat('data/',fname,"/Va.csv")))
  Pg = table2array(readtable(strcat('data/',fname,"/Pg.csv")))
  Qg = table2array(readtable(strcat('data/',fname,"/Qg.csv")))
  mpc.bus(:,VM) = Vm
  mpc.bus(:,VA) = Va
  mpc.gen(:,PG) = Pg
  mpc.gen(:,QG) = Qg
  mpc.gen(:,VG) = Vm(mpc.gen(:,GEN_BUS))
end
% fname='1_00__0__0__acopf__1_05'
% mpc = case118_n1_lowdamp
