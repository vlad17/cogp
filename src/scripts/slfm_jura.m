clear all; clc; %close all;
rng(1110,'twister');

[x,y,xtest,ytest] = read_juraCu();
% pre-process y
y0 = y;
y = log(y);
[y,ymean,ystd] = standardize(y,[],[]);

%M = size(x,1);
M.g = 200; M.h = 5;
% ssvi
cf.covfunc_g  = 'covSEard';
cf.covfunc_h  = 'covNoise';
cf.lrate      = 1e-2;
cf.momentum   = 0.9;
cf.lrate_hyp  = 1e-5;
cf.lrate_beta = 1e-4;
cf.momentum_w = 0.9;
cf.lrate_w    = 1e-4;
cf.learn_z    = true;
cf.momentum_z = 0.0;
cf.lrate_z    = 1e-4;
cf.init_kmeans = false;
cf.maxiter = 500;
cf.nbatch = 10;

Q = 2;
par.task = cell(size(y,2),1);
par.g = cell(Q,1);
[elbo,par] = slfm_learn(x,y,M,par,cf);
[mu,var,mu_g,var_g] = slfm_predict(cf.covfunc_g,cf.covfunc_h,par,xtest);
mu = exp(mu.*repmat(ystd,size(mu,1),1) + repmat(ymean,size(mu,1),1));
disp('mae test = ')
disp(mean(abs(mu-ytest)))
% disp('smse = ')
% for i=1:size(ytest,2)
%   fprintf('%.4f\t',mysmse(ytest(:,i),mu(:,i),ymean(i)));
% end

disp('mae train = ')
[mu,var,mu_g,var_g] = slfm_predict(cf.covfunc_g,cf.covfunc_h,par,x);
mu = exp(mu.*repmat(ystd,size(mu,1),1) + repmat(ymean,size(mu,1),1));
y0(260:end,1) = ytest(:,1);
disp(mean(abs(mu-y0)));

figure;
%plot(1:numel(elbo),elbo);
semilogy(1:numel(elbo),-elbo);
ylabel('elbo')
xlabel('iteration')
title(['elbo vs. iteration, lrate = ' num2str(cf.lrate_z)])

disp('elbo = ')
disp(elbo(end))
disp('learned w = ')
disp(par.w)

figure; hold on;
scatter(x(:,1),x(:,2))
scatter(par.g{1}.z(:,1),par.g{1}.z(:,2),'xr')
scatter(par.g{1}.z0(:,1),par.g{1}.z0(:,2),'sm')
title('inducing of g')

% for i=1:size(ytest,2)
% figure; hold on;
% scatter(x(:,1),x(:,2))
% scatter(params.task{i}.z(:,1),params.task{i}.z(:,2),'xr')
% title(['inducing of task ' num2str(i)]);
% end

% standard full gp or standard gpsvi?
