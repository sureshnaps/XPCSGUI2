
dt=[1:6765]'*(exptime+readtime); % this is the number of frames. multiply by (exp time + readout time)
e=zeros(numel(g2),1);

[fit2data,baseline,contrast,gamma,exponent,baseline_err,contrast_err,gamma_err,exponent_err]= ...
                fit2stretchedexp(dt,g2,e);
            


F = baseline + contrast * exp( - 2 * (gamma * dt).^exponent );

figure(111);hold off;semilogx(dt,g2,'bo');hold on;
semilogx(dt,F,'k');
tau=1./gamma




