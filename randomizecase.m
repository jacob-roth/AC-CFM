function mpc = randomizecase(mpc,settings)
  rng(settings.seed);
  define_constants;
  mpc.gen(:,PG) = max(mpc.gen(:,PG) + 100*normrnd(zeros(length(mpc.gen(:,PG)),1),0.1),0)
end